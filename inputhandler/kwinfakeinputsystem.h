/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "abstractsystem.h"

class FakeInput;

class KWinFakeInputSystem : public AbstractSystem
{
    Q_OBJECT

public:
    bool init() override;
    void emitKey(int key, bool pressed) override;
    void emitPointerMotion(double deltaX, double deltaY) override;
    void emitPointerButton(int button, bool pressed) override;

private:
    FakeInput *m_ext = nullptr;
};
