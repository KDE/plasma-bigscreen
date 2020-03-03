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
#include <QTimer>
#include <cmath>


ImagePalette::ImagePalette(QObject *parent)
    : QObject(parent)
{
    m_imageSyncTimer = new QTimer(this);
    m_imageSyncTimer->setSingleShot(true);
    m_imageSyncTimer->setInterval(100);
    connect(m_imageSyncTimer, &QTimer::timeout, this, [this]() {
       generatePalette();
    });
}

ImagePalette::~ImagePalette()
{}

void ImagePalette::setSource(const QVariant &source)
{
    if (source.canConvert<QQuickItem *>()) {
        setSourceItem(source.value<QQuickItem *>());
    } else if (source.canConvert<QImage>()) {
        setSourceImage(source.value<QImage>());
    } else if (source.canConvert<QIcon>()) {
        setSourceImage(source.value<QIcon>().pixmap(32,32).toImage());
    } else if (source.canConvert<QString>()) {
        setSourceImage(QIcon::fromTheme(source.toString()).pixmap(32,32).toImage());
    } else {
        return;
    }

    m_source = source;
    emit sourceChanged();
}

QVariant ImagePalette::source() const
{
    return m_source;
}

void ImagePalette::setSourceImage(const QImage &image)
{
    if (m_window) {
        disconnect(m_window.data(), nullptr, this, nullptr);
    }
    if (m_sourceItem) {
        disconnect(m_sourceItem.data(), nullptr, this, nullptr);
    }
    if (m_grabResult) {
        disconnect(m_grabResult.data(), nullptr, this, nullptr);
        m_grabResult.clear();
    }

    m_sourceItem.clear();

    if (m_sourceImage.isNull()) {
        m_sourceImage = image;
        generatePalette();
    } else {
        m_sourceImage = image;
        m_imageSyncTimer->start();
    }
}

QImage ImagePalette::sourceImage() const
{
    return m_sourceImage;
}

void ImagePalette::setSourceItem(QQuickItem *source)
{
    if (m_sourceItem == source) {
        return;
    }

    if (m_window) {
        disconnect(m_window.data(), nullptr, this, nullptr);
    }
    if (m_sourceItem) {
        disconnect(m_sourceItem, nullptr, this, nullptr);
    }
    m_sourceItem = source;
    update();

    if (m_sourceItem) {
        auto syncWindow = [this] () {
            if (m_window) {
                disconnect(m_window.data(), nullptr, this, nullptr);
            }
            m_window = m_sourceItem->window();
            if (m_window) {
                connect(m_window, &QWindow::visibleChanged,
                        this, &ImagePalette::update);
            }
        };

        connect(m_sourceItem, &QQuickItem::windowChanged,
                this, syncWindow);
        syncWindow();
    }
}

QQuickItem *ImagePalette::sourceItem() const
{
    return m_sourceItem;
}

void ImagePalette::update()
{
    if (!m_sourceItem || !m_window) {
        return;
    }

    if (m_grabResult) {
        disconnect(m_grabResult.data(), nullptr, this, nullptr);
        m_grabResult.clear();
    }

    m_grabResult = m_sourceItem->grabToImage(QSize(32,32));

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
    if (m_samples.isEmpty()) {
        return;
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

    std::sort(m_clusters.begin(), m_clusters.end(), [](const colorStat &a, const colorStat &b) {
        return a.colors.size() > b.colors.size();   
    });

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

    m_mostSaturated = QColor();
    m_dominant = QColor(m_clusters.first().centroid);
    m_suggestedContrast = QColor(255 - m_dominant.red(), 255 - m_dominant.green(), 255 - m_dominant.blue());
    m_suggestedContrast.setHsl(m_suggestedContrast.hslHue(),
                               m_suggestedContrast.hslSaturation(),
                               128 + (128 - m_suggestedContrast.lightness()));
    m_closestToBlack = Qt::white;
    m_closestToWhite = Qt::black;
    int minimumDistance = 4681800; //max distance: 4*3*2*3*255*255

    QColor tempContrast;
    m_palette.clear();
    for (const auto &stat : m_clusters) {
        QVariantMap entry;
        const QColor color(stat.centroid);
        entry["color"] = color;
        entry["ratio"] = stat.ratio;

        const int distance = squareDistance(m_suggestedContrast.rgb(), stat.centroid);

        if (distance < minimumDistance) {
            tempContrast = QColor(stat.centroid);
            minimumDistance = distance;
        }
        if (color.saturation() + (158-qAbs(158-color.value())) > m_mostSaturated.saturation() + (158-qAbs(158-m_mostSaturated.value()))) {
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

    // TODO: replace m_clusters.size() > 3 with entropy calculation
    if (m_clusters.size() > 3 && squareDistance(m_suggestedContrast.rgb(), tempContrast.rgb()) < s_minimumSquareDistance * 1.5) {
        m_suggestedContrast = tempContrast;
    } else if (m_clusters.size() > 2) {
        m_suggestedContrast = QColor(m_clusters[1].centroid);
    } else if (m_clusters.size() > 1) {
        m_suggestedContrast = QColor(m_clusters[1].centroid);
        m_suggestedContrast.setHsl(m_suggestedContrast.hslHue(),
                               m_suggestedContrast.hslSaturation(),
                               m_suggestedContrast.lightness() > 128
                                  ? m_suggestedContrast.lightness()+20
                                  : m_suggestedContrast.lightness()-20);
    } else if (qGray(m_dominant.rgb()) < 120) {
        m_suggestedContrast = QColor(230, 230, 230);
    } else {
        m_suggestedContrast = QColor(20, 20, 20);
    }
    
    emit paletteChanged();
    emit mostSaturatedChanged();
    emit closestToBlackChanged();
    emit closestToWhiteChanged();
    emit suggestedContrastChanged();
}

QVariantList ImagePalette::palette() const
{
    return m_palette;
}

QColor ImagePalette::suggestedContrast() const
{
    return m_suggestedContrast;
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
