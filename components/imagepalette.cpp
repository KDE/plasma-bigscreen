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
    emit sourceItemChanged();
}

QQuickItem *ImagePalette::sourceItem() const
{
    return m_source;
}


#include "moc_imagepalette.cpp"
