/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "biglauncherhomescreen.h"
#include "applicationlistmodel.h"
#include "biglauncher_dbus.h"
#include "kcmslistmodel.h"

#include <QDebug>
#include <QProcess>
#include <QtQml>

#include <sessionmanagement.h>

HomeScreen::HomeScreen(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
    , m_session(new SessionManagement(this))
{
    const QByteArray uri("org.kde.private.biglauncher");
    qmlRegisterUncreatableType<KcmsListModel>(uri, 1, 0, "KcmsListModel", QStringLiteral("KcmsListModel is uncreatable"));
    qmlRegisterUncreatableType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", QStringLiteral("Cannot create an item of type ApplicationListModel"));
    qmlRegisterUncreatableType<BigLauncherDbusAdapterInterface>(uri, 1, 0, "BigLauncherDbusAdapterInterface", QStringLiteral("Cannot create an item of type BigLauncherDbusAdapterInterface"));

    // setHasConfigurationInterface(true);
    m_bigLauncherDbusAdapterInterface = new BigLauncherDbusAdapterInterface(this);
    m_applicationListModel = new ApplicationListModel(this);
    m_kcmsListModel = new KcmsListModel(this);
}

HomeScreen::~HomeScreen()
{
}

KcmsListModel *HomeScreen::kcmsListModel() const
{
    return m_kcmsListModel;
}

ApplicationListModel *HomeScreen::applicationListModel() const
{
    return m_applicationListModel;
}

BigLauncherDbusAdapterInterface *HomeScreen::bigLauncherDbusAdapterInterface() const
{
    return m_bigLauncherDbusAdapterInterface;
}

void HomeScreen::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    QProcess::startDetached(command);
}

void HomeScreen::requestShutdown()
{
    if (m_session->state() == SessionManagement::State::Loading) {
        connect(m_session, &SessionManagement::stateChanged, this, [this]() {
            if (m_session->state() == SessionManagement::State::Ready) {
                m_session->requestShutdown();
                disconnect(m_session, nullptr, this, nullptr);
            }
        });
    }
    m_session->requestShutdown();
}

void HomeScreen::setUseColoredTiles(bool coloredTiles)
{
    m_bigLauncherDbusAdapterInterface->setColoredTilesActive(coloredTiles);
}

void HomeScreen::setUseExpandableTiles(bool expandableTiles)
{
    m_bigLauncherDbusAdapterInterface->setExpandableTilesActive(expandableTiles);
}

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "metadata.json")

#include "biglauncherhomescreen.moc"
