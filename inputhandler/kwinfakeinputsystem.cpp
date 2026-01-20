/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *   SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "kwinfakeinputsystem.h"
#include "qwayland-fake-input.h"
#include <KLocalizedString>
#include <QDebug>
#include <QWaylandClientExtensionTemplate>
#include <QtGlobal>

class FakeInput : public QWaylandClientExtensionTemplate<FakeInput>, public QtWayland::org_kde_kwin_fake_input
{
public:
    FakeInput()
        : QWaylandClientExtensionTemplate<FakeInput>(ORG_KDE_KWIN_FAKE_INPUT_KEYBOARD_KEY_SINCE_VERSION)
    {
        initialize();
    }
};

bool KWinFakeInputSystem::init()
{
    m_ext = new FakeInput;
    if (!m_ext->isInitialized()) {
        qWarning() << "Could not initialise the org_kde_kwin_fake_input implementation";
        return false;
    }
    m_ext->setParent(this);
    if (!m_ext->isActive()) {
        qWarning() << "Could not initialise the org_kde_kwin_fake_input implementation, not active";
        return false;
    }
    m_ext->authenticate({}, {});

    qDebug() << "Using KWin fakeinput input system";
    return true;
}

void KWinFakeInputSystem::emitKey(int key, bool pressed)
{
    m_ext->keyboard_key(key, pressed);
}

void KWinFakeInputSystem::emitPointerMotion(double deltaX, double deltaY)
{
    m_ext->pointer_motion(wl_fixed_from_double(deltaX), wl_fixed_from_double(deltaY));
}

void KWinFakeInputSystem::emitPointerButton(int button, bool pressed)
{
    m_ext->button(button, pressed ? 1 : 0);
}

#include "moc_kwinfakeinputsystem.cpp"
