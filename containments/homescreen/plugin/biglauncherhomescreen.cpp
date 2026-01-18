/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "biglauncherhomescreen.h"
#include "applicationlistmodel.h"
#include "favslistmodel.h"
#include "shortcuts.h"

#include <QProcess>
#include <QQmlEngine>
#include <QQmlContext>
#include <sessionmanagement.h>


static QObject *favsManagerSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine);

    //singleton managed internally, qml should never delete it
    engine->setObjectOwnership(FavsManager::instance(), QQmlEngine::CppOwnership);
    return FavsManager::instance();
}

static QObject *shortcutsSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine);

    //singleton managed internally, qml should never delete it
    engine->setObjectOwnership(Shortcuts::instance(), QQmlEngine::CppOwnership);
    return Shortcuts::instance();
}

static QObject *dbusSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine);

    engine->setObjectOwnership(BigLauncherDbusAdapterInterface::instance(), QQmlEngine::CppOwnership);
    return BigLauncherDbusAdapterInterface::instance();
}

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
    , m_applicationListModel(new ApplicationListModel(this))
    , m_session(new SessionManagement(this))
    , m_favsListModel(new FavsListModel(FavsManager::instance(), this))
{
    // Ensure DBus adapter is initialized
    BigLauncherDbusAdapterInterface::instance()->init();

    const char *uri = "org.kde.private.biglauncher";
    qmlRegisterSingletonType<Shortcuts>(uri, 1, 0, "Shortcuts", shortcutsSingletonProvider);
    qmlRegisterSingletonType<FavsManager>(uri, 1, 0, "FavsManager", favsManagerSingletonProvider);
    qmlRegisterSingletonType<BigLauncherDbusAdapterInterface>(uri, 1, 0, "BigLauncherDbusAdapterInterface", dbusSingletonProvider);
    qmlRegisterUncreatableType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", QStringLiteral("Cannot create an item of type ApplicationListModel"));
    qmlRegisterUncreatableType<FavsListModel>(uri, 1, 0, "FavsListModel", QStringLiteral("Cannot create an item of type FavsListModel"));

    // setHasConfigurationInterface(true);
}

HomeScreen::~HomeScreen()
{
}

ApplicationListModel *HomeScreen::applicationListModel() const
{
    return m_applicationListModel;
}

FavsListModel *HomeScreen::favsListModel() const
{
    return m_favsListModel;
}

void HomeScreen::openSettings(QString module)
{
    if (module.isEmpty()) {
        executeCommand(QStringLiteral("plasma-bigscreen-settings"));
    } else {
        executeCommand(QStringLiteral("plasma-bigscreen-settings -m ") + module);
    }
}

void HomeScreen::executeCommand(const QString &command)
{
    qInfo() << "Executing" << command;
    QStringList split = QProcess::splitCommand(command);
    QProcess::startDetached(split.takeFirst(), split);
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
    BigLauncherDbusAdapterInterface::instance()->setColoredTilesActive(coloredTiles);
}

void HomeScreen::setUseWallpaperBlur(bool wallpaperBlur)
{
    BigLauncherDbusAdapterInterface::instance()->setWallpaperBlurActive(wallpaperBlur);
}

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "metadata.json")

#include "biglauncherhomescreen.moc"
#include "moc_biglauncherhomescreen.cpp"
