/*
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <KPluginFactory>
#include <KQuickConfigModule>

#include <QDBusInterface>

class Wallpaper : public KQuickConfigModule
{
    Q_OBJECT

public:
    explicit Wallpaper(QObject *parent, const KPluginMetaData &data)
        : KQuickConfigModule(parent, data)
    {
    }

    Q_INVOKABLE void activateWallpaperSelector()
    {
        QDBusInterface("org.kde.biglauncher", "/BigLauncher", "org.kde.biglauncher", QDBusConnection::sessionBus()).call("activateWallpaperSelector");
    }
};

K_PLUGIN_CLASS_WITH_JSON(Wallpaper, "kcm_mediacenter_wallpaper.json")

#include "wallpaper.moc"
