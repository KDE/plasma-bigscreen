/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>         *
 *   SPDX-FileCopyrightText: 2015 Sebastian Kügler <sebas@kde.org>         *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#include "bigscreensettings.h"
#include "themelistmodel.h"

#include <QQuickItem>
#include <QDBusConnection>
#include <QDBusMessage>

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>

#include <Plasma/Svg>
#include <Plasma/Theme>

#include "timedated_interface.h"

BigscreenSettings::BigscreenSettings(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
    , m_themeListModel(new ThemeListModel(this))
{
    KAboutData *about = new KAboutData(QStringLiteral("kcm_mediacenter_bigscreen_settings"), //
                                       i18n("Appearance"),
                                       QStringLiteral("2.0"),
                                       QString(),
                                       KAboutLicense::LGPL);
    setAboutData(about);
    setButtons(Apply | Default);

    qmlRegisterAnonymousType<ThemeListModel>("ThemeListModel", 1);
    m_theme = new Plasma::Theme(this);
    m_theme->setUseGlobalSettings(true);
    m_themeName = m_theme->themeName();

    OrgFreedesktopTimedate1Interface timedateIface(QStringLiteral("org.freedesktop.timedate1"),
                                                   QStringLiteral("/org/freedesktop/timedate1"),
                                                   QDBusConnection::systemBus());
    m_useNtp = timedateIface.nTP();
}

void BigscreenSettings::load()
{
}

void BigscreenSettings::applyPlasmaTheme(QQuickItem *item, const QString &themeName)
{
    if (!item) {
        return;
    }

    Plasma::Theme *theme = m_themes[themeName];
    if (!theme) {
        theme = new Plasma::Theme(themeName, this);
        m_themes[themeName] = theme;
    }

    Q_FOREACH (Plasma::Svg *svg, item->findChildren<Plasma::Svg *>()) {
        svg->setTheme(theme);
        svg->setUsingRenderingCache(false);
    }
}

BigscreenSettings::~BigscreenSettings() = default;

void BigscreenSettings::setThemeName(const QString &theme)
{
    if (theme != m_themeName) {
        m_themeName = theme;
        m_theme->setThemeName(theme);
        emit themeNameChanged();
    }
}

QString BigscreenSettings::themeName() const
{
    return m_themeName;
}

ThemeListModel *BigscreenSettings::themeListModel()
{
    return m_themeListModel;
}

bool BigscreenSettings::useColoredTiles() const
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "coloredTilesActive");
    QDBusMessage response = QDBusConnection::sessionBus().call(msg);
    QList<QVariant> responseArg = response.arguments();
    return responseArg.at(0).toBool();
}

bool BigscreenSettings::useExpandingTiles() const
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "expandableTilesActive");
    QDBusMessage response = QDBusConnection::sessionBus().call(msg);
    QList<QVariant> responseArg = response.arguments();
    return responseArg.at(0).toBool();
}

bool BigscreenSettings::mycroftIntegrationActive() const
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "mycroftIntegrationActive");
    QDBusMessage response = QDBusConnection::sessionBus().call(msg);
    QList<QVariant> responseArg = response.arguments();
    return responseArg.at(0).toBool();
}

bool BigscreenSettings::pmInhibitionActive() const
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "pmInhibitionActive");
    QDBusMessage response = QDBusConnection::sessionBus().call(msg);
    QList<QVariant> responseArg = response.arguments();
    return responseArg.at(0).toBool();
}

void BigscreenSettings::setUseColoredTiles(bool useColoredTiles)
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "useColoredTiles");
    msg << useColoredTiles;
    QDBusConnection::sessionBus().send(msg);
}

void BigscreenSettings::setUseExpandingTiles(bool useExpandingTiles)
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "useExpandableTiles");
    msg << useExpandingTiles;
    QDBusConnection::sessionBus().send(msg);
}

void BigscreenSettings::setMycroftIntegrationActive(bool mycroftIntegrationActive)
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "enableMycroftIntegration");
    msg << mycroftIntegrationActive;
    QDBusConnection::sessionBus().send(msg);
}

void BigscreenSettings::setPmInhibitionActive(bool pmInhibitionActive)
{
    QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.biglauncher", "/BigLauncher", "", "enablePmInhibition");
    msg << pmInhibitionActive;
    QDBusConnection::sessionBus().send(msg);
}

void BigscreenSettings::saveTimeZone(const QString &newtimezone)
{
    qDebug() << "Saving timezone to config: " << newtimezone;
    OrgFreedesktopTimedate1Interface timedateIface(QStringLiteral("org.freedesktop.timedate1"),
                                                   QStringLiteral("/org/freedesktop/timedate1"),
                                                   QDBusConnection::systemBus());

    if (!newtimezone.isEmpty()) {
        qDebug() << "Setting timezone: " << newtimezone;
        auto reply = timedateIface.SetTimezone(newtimezone, true);
        reply.waitForFinished();
        if (reply.isError()) {
            qDebug() << "Failed to set timezone" << reply.error().name() << reply.error().message();
        }
    }
}

void BigscreenSettings::setCurrentTime(const QTime &currentTime)
{
    if (m_currentTime != currentTime) {
        m_currentTime = currentTime;
        emit currentTimeChanged();
    }
}


void BigscreenSettings::setCurrentDate(const QDate &currentDate)
{
    if (m_currentDate != currentDate) {
        m_currentDate = currentDate;
        emit currentDateChanged();
    }
}

QTime BigscreenSettings::currentTime() const
{
    return m_currentTime;
}


QDate BigscreenSettings::currentDate() const
{
    return m_currentDate;
}

bool BigscreenSettings::useNtp() const
{
    return m_useNtp;
}

void BigscreenSettings::setUseNtp(bool ntp)
{
    if (m_useNtp != ntp) {
        m_useNtp = ntp;
        saveTime();
        emit useNtpChanged();
    }
}

bool BigscreenSettings::saveTime()
{
    OrgFreedesktopTimedate1Interface timedateIface(QStringLiteral("org.freedesktop.timedate1"),
                                                   QStringLiteral("/org/freedesktop/timedate1"),
                                                   QDBusConnection::systemBus());

    bool rc = true;
    // final arg in each method is "user-interaction" i.e whether it's OK for polkit to ask for auth

    // we cannot send requests up front then block for all replies as we need NTP to be disabled before we can make a call to SetTime
    // timedated processes these in parallel and will return an error otherwise

    auto reply = timedateIface.SetNTP(m_useNtp, true);
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Failed to enable NTP" << reply.error().name() << reply.error().message();
        rc = false;
    }

    if (!useNtp()) {
        QDateTime userTime;
        userTime.setTime(currentTime());
        userTime.setDate(currentDate());
        qDebug() << "Setting userTime: " << userTime;
        qint64 timeDiff = userTime.toMSecsSinceEpoch() - QDateTime::currentMSecsSinceEpoch();
        auto reply = timedateIface.SetTime(timeDiff * 1000, true, true);
        reply.waitForFinished();
        if (reply.isError()) {
            qWarning() << "Failed to set current time" << reply.error().name() << reply.error().message();
            rc = false;
        }
    }
    return rc;
}

K_PLUGIN_FACTORY_WITH_JSON(BigscreenSettingsFactory, "bigscreensettings.json", registerPlugin<BigscreenSettings>();)

#include "bigscreensettings.moc"
