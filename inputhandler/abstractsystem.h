/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <QSet>

class AbstractSystem : public QObject
{
    Q_OBJECT
public:
    virtual bool init() = 0;
    virtual void emitKey(int key, bool pressed) = 0;
    virtual void emitPointerMotion(double deltaX, double deltaY) = 0;
    virtual void emitPointerButton(int button, bool pressed) = 0;

    virtual void setSupportedKeys(const QSet<int> &keys)
    {
        Q_UNUSED(keys);
    }
};
