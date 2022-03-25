/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>


    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <Plasma/Containment>
#include "biglauncher_dbus.h"

class ApplicationListModel;
class KcmsListModel;
class SessionManagement;
class BigLauncherDbusAdapterInterface;

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(ApplicationListModel *applicationListModel READ applicationListModel CONSTANT)
    Q_PROPERTY(KcmsListModel *kcmsListModel READ kcmsListModel CONSTANT)
    Q_PROPERTY(BigLauncherDbusAdapterInterface *bigLauncherDbusAdapterInterface READ bigLauncherDbusAdapterInterface CONSTANT)

public:
    HomeScreen(QObject *parent, const QVariantList &args);
    ~HomeScreen() override;

    ApplicationListModel *applicationListModel() const;
    KcmsListModel *kcmsListModel() const;
    BigLauncherDbusAdapterInterface *bigLauncherDbusAdapterInterface() const;

public Q_SLOTS:
    void executeCommand(const QString &command);
    void requestShutdown();
    void setUseColoredTiles(bool coloredTiles);
    void setUseExpandableTiles(bool expandableTiles);

private:
    ApplicationListModel *m_applicationListModel;
    KcmsListModel *m_kcmsListModel;
    SessionManagement *m_session;
    BigLauncherDbusAdapterInterface* m_bigLauncherDbusAdapterInterface;
};
