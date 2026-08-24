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

    QList<QKeySequence> activateSettingsShortcut() const;
    QList<QKeySequence> activateTasksShortcut() const;
    QList<QKeySequence> displayHomeScreenShortcut() const;
    QList<QKeySequence> displayHomeOverlayShortcut() const;
    QList<QKeySequence> displaySearchShortcut() const;

    bool setActivateSettingsShortcut(const QKeySequence &shortcut);
    bool setActivateTasksShortcut(const QKeySequence &shortcut);
    bool setDisplayHomeScreenShortcut(const QKeySequence &shortcut);
    bool setDisplayHomeOverlayShortcut(const QKeySequence &shortcut);
    bool setDisplaySearchShortcut(const QKeySequence &shortcut);

    void resetActivateSettingsShortcut();
    void resetActivateTasksShortcut();
    void resetDisplayHomeScreenShortcut();
    void resetDisplayHomeOverlayShortcut();
    void resetDisplaySearchShortcut();

Q_SIGNALS:
    void toggleSettingsOverlay();
    void toggleTasksOverlay();
    void toggleHomeScreen();
    void toggleHomeOverlay();
    void toggleSearch();

private:
    explicit Shortcuts(QObject *parent = nullptr);
    QAction* toggleActivateSettingsAction;
    QAction* toggleActivateTasksAction;
    QAction* toggleDisplayHomeScreenAction;
    QAction *toggleDisplayHomeOverlayAction;
    QAction *toggleDisplaySearchAction;
};

#endif // SHORTCUTS_H
