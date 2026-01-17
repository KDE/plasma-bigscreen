// SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

// Create a singleton class instance for managing all bigscreen qactions and shortcuts.

#ifndef SHORTCUTS_H
#define SHORTCUTS_H

#include <QObject>
#include <KGlobalAccel>
#include <QKeySequence>

class Shortcuts : public QObject
{
    Q_OBJECT

public:
    static Shortcuts* instance();

    void initializeShortcuts();

    QKeySequence activateSettingsShortcut() const;
    QKeySequence activateTasksShortcut() const;
    QKeySequence displayHomeScreenShortcut() const;

    void setActivateSettingsShortcut(const QKeySequence &shortcut);
    void setActivateTasksShortcut(const QKeySequence &shortcut);
    void setDisplayHomeScreenShortcut(const QKeySequence &shortcut);

    void resetActivateSettingsShortcut();
    void resetActivateTasksShortcut();
    void resetDisplayHomeScreenShortcut();

Q_SIGNALS:
    void toggleSettingsOverlay();
    void toggleTasksOverlay();
    void toggleHomeScreen();

private:
    explicit Shortcuts(QObject *parent = nullptr);
    QAction* toggleActivateSettingsAction;
    QAction* toggleActivateTasksAction;
    QAction* toggleDisplayHomeScreenAction;
};

#endif // SHORTCUTS_H
