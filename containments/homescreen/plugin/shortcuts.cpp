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
    KGlobalAccel::self()->setGlobalShortcut(toggleDisplayHomeScreenAction, Qt::Key_HomePage | Qt::Key_Back);

    connect(toggleActivateSettingsAction, &QAction::triggered, this, [this]() {
        Q_EMIT toggleSettingsOverlay();
    });

    connect(toggleActivateTasksAction, &QAction::triggered, this, [this]() {
        Q_EMIT toggleTasksOverlay();
    });

    connect(toggleDisplayHomeScreenAction, &QAction::triggered, this, [this]() {
        Q_EMIT toggleHomeScreen();
    });
}

QKeySequence Shortcuts::activateSettingsShortcut() const
{
    const QList<QKeySequence> shortcuts = KGlobalAccel::self()->shortcut(toggleActivateSettingsAction);
    if (shortcuts.count() > 0) {
        return shortcuts.first();
    }
    return QKeySequence();
}

QKeySequence Shortcuts::activateTasksShortcut() const
{
    const QList<QKeySequence> shortcuts = KGlobalAccel::self()->shortcut(toggleActivateTasksAction);
    if (shortcuts.count() > 0) {
        return shortcuts.first();
    }
    return QKeySequence();
}

QKeySequence Shortcuts::displayHomeScreenShortcut() const
{
    const QList<QKeySequence> shortcuts = KGlobalAccel::self()->shortcut(toggleDisplayHomeScreenAction);
    if (shortcuts.count() > 0) {
        return shortcuts.first();
    }
    return QKeySequence();
}


void Shortcuts::setActivateSettingsShortcut(const QKeySequence &shortcut)
{
    KGlobalAccel::self()->setGlobalShortcut(toggleActivateSettingsAction, shortcut);
}

void Shortcuts::setActivateTasksShortcut(const QKeySequence &shortcut)
{
    KGlobalAccel::self()->setGlobalShortcut(toggleActivateTasksAction, shortcut);
}

void Shortcuts::setDisplayHomeScreenShortcut(const QKeySequence &shortcut)
{
    KGlobalAccel::self()->setGlobalShortcut(toggleDisplayHomeScreenAction, shortcut);
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
        setActivateSettingsShortcut(shortcut);
    }
}

void Shortcuts::resetDisplayHomeScreenShortcut()
{
    auto defaultShortcuts = KGlobalAccel::self()->defaultShortcut(toggleDisplayHomeScreenAction);
    for (const auto &shortcut : defaultShortcuts) {
        setActivateSettingsShortcut(shortcut);
    }
}
