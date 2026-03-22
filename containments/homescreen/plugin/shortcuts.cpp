// SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "shortcuts.h"
#include <KLocalizedString>
#include <QAction>

Shortcuts* Shortcuts::instance()
{
    static Shortcuts* s_self = nullptr;
    if (!s_self) {
        s_self = new Shortcuts;
    }
    return s_self;
}

Shortcuts::Shortcuts(QObject *parent)
    : QObject(parent)
{
    initializeShortcuts();
}

void Shortcuts::initializeShortcuts()
{
    toggleActivateSettingsAction = new QAction(this);
    toggleActivateSettingsAction->setObjectName(QStringLiteral("Toggle Bigscreen Settings"));
    toggleActivateSettingsAction->setText(i18n("Toggle Bigscreen Settings"));
    KGlobalAccel::self()->setGlobalShortcut(toggleActivateSettingsAction, Qt::Key_Settings);

    toggleActivateTasksAction = new QAction(this);
    toggleActivateTasksAction->setObjectName(QStringLiteral("Toggle Bigscreen Tasks Overview"));
    toggleActivateTasksAction->setText(i18n("Toggle Bigscreen Tasks Overview"));
    KGlobalAccel::self()->setGlobalShortcut(toggleActivateTasksAction, Qt::Key_Menu);

    toggleDisplayHomeScreenAction = new QAction(this);
    toggleDisplayHomeScreenAction->setObjectName(QStringLiteral("Toggle Bigscreen Home Screen"));
    toggleDisplayHomeScreenAction->setText(i18n("Toggle Bigscreen Home Screen"));
    KGlobalAccel::self()->setGlobalShortcut(toggleDisplayHomeScreenAction, Qt::Key_HomePage);

    toggleDisplayHomeOverlayAction = new QAction(this);
    toggleDisplayHomeOverlayAction->setObjectName(QStringLiteral("Toggle Bigscreen Home Overlay"));
    toggleDisplayHomeOverlayAction->setText(i18n("Toggle Bigscreen Home Overlay"));
    KGlobalAccel::self()->setGlobalShortcut(toggleDisplayHomeOverlayAction, Qt::META | Qt::Key_O);

    connect(toggleActivateSettingsAction, &QAction::triggered, this, [this]() {
        Q_EMIT toggleSettingsOverlay();
    });

    connect(toggleActivateTasksAction, &QAction::triggered, this, [this]() {
        Q_EMIT toggleTasksOverlay();
    });

    connect(toggleDisplayHomeScreenAction, &QAction::triggered, this, [this]() {
        Q_EMIT toggleHomeScreen();
    });

    connect(toggleDisplayHomeOverlayAction, &QAction::triggered, this, [this]() {
        Q_EMIT toggleHomeOverlay();
    });
}

QList<QKeySequence> Shortcuts::activateSettingsShortcut() const
{
    return KGlobalAccel::self()->shortcut(toggleActivateSettingsAction);
}

QList<QKeySequence> Shortcuts::activateTasksShortcut() const
{
    return KGlobalAccel::self()->shortcut(toggleActivateTasksAction);
}

QList<QKeySequence> Shortcuts::displayHomeScreenShortcut() const
{
    return KGlobalAccel::self()->shortcut(toggleDisplayHomeScreenAction);
}

QList<QKeySequence> Shortcuts::displayHomeOverlayShortcut() const
{
    return KGlobalAccel::self()->shortcut(toggleDisplayHomeOverlayAction);
}

bool Shortcuts::setActivateSettingsShortcut(const QKeySequence &shortcut)
{
    return KGlobalAccel::self()->setShortcut(toggleActivateSettingsAction, {shortcut}, KGlobalAccel::NoAutoloading);
}

bool Shortcuts::setActivateTasksShortcut(const QKeySequence &shortcut)
{
    return KGlobalAccel::self()->setShortcut(toggleActivateTasksAction, {shortcut}, KGlobalAccel::NoAutoloading);
}

bool Shortcuts::setDisplayHomeScreenShortcut(const QKeySequence &shortcut)
{
    return KGlobalAccel::self()->setShortcut(toggleDisplayHomeScreenAction, {shortcut}, KGlobalAccel::NoAutoloading);
}

bool Shortcuts::setDisplayHomeOverlayShortcut(const QKeySequence &shortcut)
{
    return KGlobalAccel::self()->setShortcut(toggleDisplayHomeOverlayAction, {shortcut}, KGlobalAccel::NoAutoloading);
}

void Shortcuts::resetActivateSettingsShortcut()
{
    auto defaultShortcuts = KGlobalAccel::self()->defaultShortcut(toggleActivateSettingsAction);
    for (const auto &shortcut : defaultShortcuts) {
        setActivateSettingsShortcut(shortcut);
    }
}

void Shortcuts::resetActivateTasksShortcut()
{
    auto defaultShortcuts = KGlobalAccel::self()->defaultShortcut(toggleActivateTasksAction);
    for (const auto &shortcut : defaultShortcuts) {
        setActivateTasksShortcut(shortcut);
    }
}

void Shortcuts::resetDisplayHomeScreenShortcut()
{
    auto defaultShortcuts = KGlobalAccel::self()->defaultShortcut(toggleDisplayHomeScreenAction);
    for (const auto &shortcut : defaultShortcuts) {
        setDisplayHomeScreenShortcut(shortcut);
    }
}

void Shortcuts::resetDisplayHomeOverlayShortcut()
{
    auto defaultShortcuts = KGlobalAccel::self()->defaultShortcut(toggleDisplayHomeOverlayAction);
    for (const auto &shortcut : defaultShortcuts) {
        setDisplayHomeOverlayShortcut(shortcut);
    }
}
