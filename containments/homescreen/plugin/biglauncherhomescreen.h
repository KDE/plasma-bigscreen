/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <Plasma/Containment>
#include "biglauncher_dbus.h"

class ApplicationListModel;
class FavsManager;
class FavsListModel;
class SessionManagement;
class Shortcuts;
class BigLauncherDbusAdapterInterface;

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(ApplicationListModel *applicationListModel READ applicationListModel CONSTANT)
    Q_PROPERTY(FavsListModel *favsListModel READ favsListModel CONSTANT)

public:
    HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~HomeScreen() override;

    ApplicationListModel *applicationListModel() const;
    BigLauncherDbusAdapterInterface *bigLauncherDbusAdapterInterface() const;
    FavsListModel *favsListModel() const;
    Shortcuts *shortcuts() const;

    Q_INVOKABLE void openSettings(QString module = QString{});
    Q_INVOKABLE void openSearch();
    Q_INVOKABLE void openTasks();
    Q_INVOKABLE void openHomeOverlay();
    Q_INVOKABLE void showOSD(const QString &text, const QString &iconName);

Q_SIGNALS:
    void openSearchRequested();
    void openTasksRequested();
    void openHomeOverlayRequested();

public Q_SLOTS:
    void executeCommand(const QString &command);
    void setUseColoredTiles(bool coloredTiles);
    void setUseWallpaperBlur(bool wallpaperBlur);

private:
    ApplicationListModel *m_applicationListModel;
    SessionManagement *m_session;
    FavsListModel *m_favsListModel;
};
