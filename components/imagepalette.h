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

#pragma once

#include <QObject>
#include <QColor>
#include <QImage>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QPointer>

class ImagePalette : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem *sourceItem READ sourceItem WRITE setSourceItem NOTIFY sourceItemChanged)
    Q_PROPERTY(QVariantList palette MEMBER m_palette NOTIFY paletteChanged)

public:
    explicit ImagePalette(QObject* parent = nullptr);
    ~ImagePalette();
    
    void setSourceItem(QQuickItem *source);
    QQuickItem *sourceItem() const;

    Q_INVOKABLE void update();
Q_SIGNALS:
    void sourceItemChanged();
    void paletteChanged();

private:
    inline void positionColor(QRgb rgb);
    void generatePalette();

    struct colorStat {
        QList<QRgb> colors;
        QRgb centroid = 0;
        qreal ratio = 0;
    };

    QPointer<QQuickItem> m_source;
    QSharedPointer<QQuickItemGrabResult> m_grabResult;
    QImage m_sourceImage;
    QList<QRgb> m_samples;
    QList<colorStat> m_clusters;
    QVariantList m_palette;
};

