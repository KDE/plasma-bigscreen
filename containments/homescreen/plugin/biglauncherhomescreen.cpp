/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "biglauncherhomescreen.h"
#include "applicationlistmodel.h"
#include "biglauncher_dbus.h"

#include <QDebug>
#include <QProcess>
#include <QtQml>

#include <sessionmanagement.h>

HomeScreen::HomeScreen(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
    , m_session(new SessionManagement(this))
{
    const QByteArray uri("org.kde.private.biglauncher");
    qmlRegisterUncreatableType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", QStringLiteral("Cannot create an item of type ApplicationListModel"));

    // setHasConfigurationInterface(true);
    auto bigLauncherDbusAdapterInterface = new BigLauncherDbusAdapterInterface(this);
    m_applicationListModel = new ApplicationListModel(this);
}

HomeScreen::~HomeScreen()
{
}

ApplicationListModel *HomeScreen::applicationListModel() const
{
    return m_applicationListModel;
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

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "metadata.json")

#include "biglauncherhomescreen.moc"
