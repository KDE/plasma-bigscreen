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
#include <QRandomGenerator>

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

    m_source = source;
    update();
    emit sourceItemChanged();
}

QQuickItem *ImagePalette::sourceItem() const
{
    return m_source;
}

void ImagePalette::update()
{
    if (m_source) {
        m_source->grabToImage(QSize(128,128));
    
        if (m_grabResult) {
            disconnect(m_grabResult.data(), nullptr, this, nullptr);
        }

        m_grabResult = m_source->grabToImage();
        if (m_grabResult) {
            connect(m_grabResult.data(), &QQuickItemGrabResult::ready, this, [this]() {
                m_sourceImage = m_grabResult->image();
                generatePalette();
                m_grabResult.reset();
            });
        }
    }
}

void ImagePalette::generatePalette2()
{
    
    m_sourceImage = m_sourceImage.convertToFormat(QImage::Format_Indexed8);
    qWarning()<<m_sourceImage.colorTable();
    m_sourceImage.setColorCount(m_numColors);
    m_palette.clear();
    qWarning()<<m_sourceImage.colorTable();
    for (int i = 0; i < m_numColors; ++i) {
        m_palette<<QColor(m_sourceImage.colorTable()[i]);
    }
    emit paletteChanged();
}

inline int distance(QRgb color1, QRgb color2)
{
    return pow(qRed(color1) - qRed(color2), 2) +
           pow(qGreen(color1) - qGreen(color2), 2) +
           pow(qBlue(color1) - qBlue(color2), 2);
}

void ImagePalette::generatePalette()
{
    m_clusters.fill({});
    // Take the random samples

    for (int i = 0; i < m_sampleNumber; ++i) {
        int attempt = 0;
        while (attempt < 5 && m_samples[i] == 0) {
            m_samples[i] = m_sourceImage.pixel(
                QRandomGenerator::global()->bounded(0, m_sourceImage.width()), 
                QRandomGenerator::global()->bounded(0, m_sourceImage.height()));
            ++attempt;
        }
    }

    // Take random initial centroids
    for (int i = 0; i < m_numColors; ++i) {
        QRgb centroid = m_samples[QRandomGenerator::global()->bounded(0, m_samples.size()-1)];
        int attempt = 0;
        for (int j = 0; j < i && attempt < 10; ++j) {
            while (attempt < 10 && distance(centroid, m_clusters[j].first()) < 20000) {
                centroid = m_samples[QRandomGenerator::global()->bounded(0, m_samples.size()-1)];
                j = 0;
                ++attempt;
            }
        }
        m_clusters[i].append(centroid);
    }

    for (int iteration = 0; iteration < 15; ++iteration) {
        int minSquaredDistance = 196608; // 3x256x256
        int nearestCluster = 0;
        int squaredDistance;
        QRgb sample;
        for (int i = 0; i < m_sampleNumber; ++i) {
            sample = m_samples[i];
            for (int j = 0; j < m_numColors; ++j) {
                squaredDistance = distance(sample, m_clusters[j].first());

                if (squaredDistance < minSquaredDistance) {
                    minSquaredDistance = squaredDistance;
                    nearestCluster = j;
                }
            }
            m_clusters[nearestCluster].append(sample);
            minSquaredDistance = 196608;
            nearestCluster = 0;
        }
        std::sort(m_clusters.begin(), m_clusters.end(), [](const QList<QRgb> &a, const QList<QRgb> &b) {
            return a.size() > b.size();   
        });
        /*break;
        if (iteration < 14)
        for (int i = 0; i < m_numColors; ++i) {
            if (m_clusters[i].count() > m_sampleNumber/4) {
                m_clusters[i] = QList<QRgb>({m_clusters[i].first()});
            } else {
                QRgb centroid = m_samples[QRandomGenerator::global()->bounded(0, m_samples.size()-1)];
                int attempt = 0;
                for (int j = 0; j < i && attempt < 10; ++j) {
                    while (attempt < 10 && distance(centroid, m_clusters[j].first()) < 1000) {
                        centroid = m_samples[QRandomGenerator::global()->bounded(0, m_samples.size()-1)];
                        j = 0;
                        ++attempt;
                    }
                }
                m_clusters[i] = QList<QRgb>({centroid});
            }
        }*/
        for (int i = 0; i < m_numColors; ++i) {
            int r = 0;
            int g = 0;
            int b = 0;
            int c = 0;
            for (auto color : m_clusters[i]) {
                c++;
                r += qRed(color);
                g += qGreen(color);
                b += qBlue(color);
            }
            r = r / c;
            g = g / c;
            b = b / c;
            m_clusters[i] = QList<QRgb>({qRgb(r, g, b)});
        }
    }
    m_palette.clear();
    for (int i = 0; i < m_numColors; ++i) {
        qWarning()<<QColor(m_clusters[i].first())<<m_clusters[i].size();
        m_palette<<QColor(m_clusters[i].first());
    }
    emit paletteChanged();
}

#include "moc_imagepalette.cpp"
