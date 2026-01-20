// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KPluginFactory>

#include "start.h"

K_PLUGIN_FACTORY_WITH_JSON(StartFactory, "kded_plasma_bigscreen_start.json", registerPlugin<Start>();)

Start::Start(QObject *parent, const QList<QVariant> &)
    : KDEDModule{parent}
{
    auto *envmanagerJob = new KIO::CommandLauncherJob(QStringLiteral("plasma-bigscreen-envmanager --apply-settings"), {});
    envmanagerJob->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    envmanagerJob->setDesktopName(QStringLiteral("org.kde.plasma.bigscreen.envmanager"));
    envmanagerJob->start();

    auto *inputmanagerJob = new KIO::CommandLauncherJob(QStringLiteral("plasma-bigscreen-inputhandler"), {});
    inputmanagerJob->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    inputmanagerJob->setDesktopName(QStringLiteral("org.kde.plasma.bigscreen.inputhandler"));
    inputmanagerJob->start();
}

#include "start.moc"
