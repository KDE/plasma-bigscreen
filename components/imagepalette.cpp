/*
 *  Copyright 2020 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

#include "imagepalette.h"

#include <QColor>
#include <QDebug>
#include <cmath>


ImagePalette::ImagePalette(QObject *parent)
    : QObject(parent)
{
}

ImagePalette::~ImagePalette()
{}

void ImagePalette::setSourceItem(QQuickItem *source)
{
    if (m_source == source) {
        return;
    }

    if (m_window) {
        disconnect(m_window.data(), nullptr, this, nullptr);
    }
    m_source = source;
    update();

    if (m_source) {
        auto syncWindow = [this] () {
            if (m_window) {
                disconnect(m_window.data(), nullptr, this, nullptr);
            }
            m_window = m_source->window();
            if (m_window) {
                connect(m_window, &QWindow::visibleChanged,
                        this, &ImagePalette::update);
            }
        };

        connect(m_source, &QQuickItem::windowChanged,
                this, syncWindow);
        syncWindow();
    }

    emit sourceItemChanged();
}

QQuickItem *ImagePalette::sourceItem() const
{
    return m_source;
}

void ImagePalette::update()
{
    if (!m_source || !m_window) {
        return;
    }

    if (m_grabResult) {
        disconnect(m_grabResult.data(), nullptr, this, nullptr);
        m_grabResult.clear();
    }

    m_grabResult = m_source->grabToImage(QSize(32,32));

    if (m_grabResult) {
        connect(m_grabResult.data(), &QQuickItemGrabResult::ready, this, [this]() {
            m_sourceImage = m_grabResult->image();
            m_grabResult.clear();
            generatePalette();
        });
    }
}

inline int squareDistance(QRgb color1, QRgb color2)
{
    // https://en.wikipedia.org/wiki/Color_difference
    if (qRed(color1) - qRed(color2) < 128) {
        return 2 * pow(qRed(color1) - qRed(color2), 2) +
            4 * pow(qGreen(color1) - qGreen(color2), 2) +
            3 * pow(qBlue(color1) - qBlue(color2), 2);
    } else {
        return 3 * pow(qRed(color1) - qRed(color2), 2) +
            4 * pow(qGreen(color1) - qGreen(color2), 2) +
            2 * pow(qBlue(color1) - qBlue(color2), 2);
    }
}

void ImagePalette::positionColor(QRgb rgb)
{
    for (auto &stat : m_clusters) {
        if (squareDistance(rgb, stat.centroid) < s_minimumSquareDistance) {
            stat.colors.append(rgb);
            return;
        }
    }

    colorStat stat;
    stat.colors.append(rgb);
    stat.centroid = rgb;
    m_clusters << stat;
}

void ImagePalette::generatePalette()
{
    m_clusters.clear();
    m_samples.clear();

    QColor sampleColor;
    for (int x = 0; x < m_sourceImage.width(); ++x) {
        for (int y = 0; y < m_sourceImage.height(); ++y) {
            sampleColor = m_sourceImage.pixelColor(x, y);
            if (sampleColor.alpha() == 0) {
                continue;
            }
            m_samples << sampleColor.rgb();
            positionColor(sampleColor.rgb());
        }
    }

    for (int iteration = 0; iteration < 5; ++iteration) {
        for (auto &stat : m_clusters) {
            int r = 0;
            int g = 0;
            int b = 0;
            int c = 0;

            for (auto color : stat.colors) {
                c++;
                r += qRed(color);
                g += qGreen(color);
                b += qBlue(color);
            }
            r = r / c;
            g = g / c;
            b = b / c;
            stat.centroid = qRgb(r, g, b);
            stat.ratio = qreal(stat.colors.count()) / qreal(m_samples.count());
            stat.colors = QList<QRgb>({stat.centroid});
        }

        for (auto color : m_samples) {
            positionColor(color);
        }
    }

    // compress blocks that became too similar
    auto sourceIt = m_clusters.end();
    QList<QList<colorStat>::iterator> itemsToDelete;
    while (sourceIt != m_clusters.begin()) {
        sourceIt--;
        for (auto destIt = m_clusters.begin(); destIt != m_clusters.end() && destIt != sourceIt; destIt++) {
            if (squareDistance((*sourceIt).centroid, (*destIt).centroid) < s_minimumSquareDistance) {
                const qreal ratio = (*sourceIt).ratio / (*destIt).ratio;
                const int r = ratio * qreal(qRed((*sourceIt).centroid)) +
                    (1 - ratio) * qreal(qRed((*destIt).centroid));
                const int g = ratio * qreal(qGreen((*sourceIt).centroid)) +
                    (1 - ratio) * qreal(qGreen((*destIt).centroid));
                const int b = ratio * qreal(qBlue((*sourceIt).centroid)) +
                    (1 - ratio) * qreal(qBlue((*destIt).centroid));
                (*destIt).ratio += (*sourceIt).ratio;
                (*destIt).centroid = qRgb(r, g, b);
                itemsToDelete << sourceIt;
                break;
            }
        }
    }
    for (const auto &i : itemsToDelete) {
        m_clusters.erase(i);
    }


    std::sort(m_clusters.begin(), m_clusters.end(), [](const colorStat &a, const colorStat &b) {
        return a.colors.size() > b.colors.size();   
    });


    m_mostSaturated = QColor();
    m_closestToBlack = Qt::white;
    m_closestToWhite = Qt::black;

    m_palette.clear();
    for (const auto &stat : m_clusters) {
        QVariantMap entry;
        const QColor color(stat.centroid);
        entry["color"] = color;
        entry["ratio"] = stat.ratio;
        QColor complementary(255 - qRed(stat.centroid), 255 - qGreen(stat.centroid), 255 - qBlue(stat.centroid));
        entry["complementary"] = complementary;
        for (const auto &stat : m_clusters) {
            if (squareDistance(complementary.rgb(), stat.centroid) < s_minimumSquareDistance) {
                entry["complementary"] = QColor(stat.centroid);
                break;
            }
        }
        if (color.saturation() + (128-qAbs(128-color.value())) > m_mostSaturated.saturation() + (128-qAbs(128-m_mostSaturated.value()))) {
            m_mostSaturated = color;
        }
        if (qGray(color.rgb()) > qGray(m_closestToWhite.rgb())) {
            m_closestToWhite = color;
        }
        if (qGray(color.rgb()) < qGray(m_closestToBlack.rgb())) {
            m_closestToBlack = color;
        }
        m_palette << entry;
    }
    emit paletteChanged();
    emit mostSaturatedChanged();
    emit closestToBlackChanged();
    emit closestToWhiteChanged();
}

QVariantList ImagePalette::palette() const
{
    return m_palette;
}

QColor ImagePalette::mostSaturated() const
{
    return m_mostSaturated;
}

QColor ImagePalette::closestToWhite() const
{
   return m_closestToWhite;
}

QColor ImagePalette::closestToBlack() const
{
    return m_closestToBlack;
}

#include "moc_imagepalette.cpp"
