/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "remotecontroller.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

static const QString configFile = QStringLiteral("plasma-localerc");
static const QString lcLanguage = QStringLiteral("LANGUAGE");

RemoteController::RemoteController(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
{
    KAboutData *about = new KAboutData(QStringLiteral("kcm_mediacenter_remotecontroller"), //
                                       i18n("Configure Remote Controllers"),
                                       QStringLiteral("2.0"),
                                       QString(),
                                       KAboutLicense::LGPL);
    setAboutData(about);

    setButtons(Apply | Default);
}

RemoteController::~RemoteController()
{
}

void RemoteController::load()
{
}

void RemoteController::save()
{
}

void RemoteController::defaults()
{
}

QString RemoteController::getCecKeyConfig(const QString key)
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("plasma-remotecontrollersrc"));
    static KConfigGroup grp(config, QLatin1String("General"));

    if (grp.isValid()) {
        return grp.readEntry(key, QString());
    }

    return "Null";
}

void RemoteController::setCecKeyConfig(const QString button, const QString key)
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("plasma-remotecontrollersrc"));
    static KConfigGroup grp(config, QLatin1String("General"));

    if (grp.isValid()) {
        grp.writeEntry(button, key);
        grp.sync();
        emit cecConfigChanged(button);
    }
}

K_PLUGIN_CLASS_WITH_JSON(RemoteController, "mediacenter_remotecontroller.json")

#include "remotecontroller.moc"
