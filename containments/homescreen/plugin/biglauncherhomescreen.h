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
    Q_PROPERTY(BigLauncherDbusAdapterInterface *bigLauncherDbusAdapterInterface READ bigLauncherDbusAdapterInterface CONSTANT)
    Q_PROPERTY(FavsListModel *favsListModel READ favsListModel CONSTANT)

public:
    HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~HomeScreen() override;

    ApplicationListModel *applicationListModel() const;
    BigLauncherDbusAdapterInterface *bigLauncherDbusAdapterInterface() const;
    FavsListModel *favsListModel() const;

    Q_INVOKABLE void openSettings(QString module = QString{});

public Q_SLOTS:
    void executeCommand(const QString &command);
    void requestShutdown();
    void setUseColoredTiles(bool coloredTiles);

private:
    ApplicationListModel *m_applicationListModel;
    SessionManagement *m_session;
    BigLauncherDbusAdapterInterface* m_bigLauncherDbusAdapterInterface;
    FavsManager *m_favsManager;
    FavsListModel *m_favsListModel;
    Shortcuts *m_shortcuts;
};
