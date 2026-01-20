/*
 *   SPDX-FileCopyrightText: 2022 Bart Ribbers <bribbers@disroot.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "inputhandlerdbus.h"

#ifdef HAS_LIBCEC
#include "libcec/ceccontroller.h"
#endif
#include "sdlcontroller.h"

#include <KConfigGroup>
#include <KLocalizedString>
#include <KSharedConfig>
#include <QCommandLineParser>
#include <QDBusConnection>
#include <QDebug>

#include <KAboutData>
#include <KDBusService>
#include <KRuntimePlatform>
#include <fcntl.h>
#include <unistd.h>

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("plasma-bigscreen-inputhandler");

    KAboutData about(QStringLiteral("plasma-inputhandler"),
                     i18n("Plasma Bigscreen Input Handler"),
                     PROJECT_VERSION,
                     {},
                     KAboutLicense::GPL,
                     i18n("© 2026 Plasma Development Team"));
    about.setProductName("Plasma Bigscreen Input Handler");

    KAboutData::setApplicationData(about);

    bool isBigscreen = KRuntimePlatform::runtimePlatform().contains(u"mediacenter"_s);
    if (!isBigscreen) {
        qWarning() << "Not running in Plasma Bigscreen, exiting ($PLASMA_PLATFORM is not \"mediacenter\")...";
        return 0;
    }

    KDBusService::StartupOptions startup = {};
    {
        QCommandLineParser parser;
        QCommandLineOption replaceOption({QStringLiteral("replace")}, i18n("Replace an existing instance"));
        parser.addOption(replaceOption);
        about.setupCommandLine(&parser);
        parser.process(app);
        about.processCommandLine(&parser);

        if (parser.isSet(replaceOption)) {
            startup |= KDBusService::Replace;
        }
    }

    KDBusService service(KDBusService::Unique | startup);

    if (!QDBusConnection::sessionBus().isConnected()) {
        qWarning() << "Cannot connect to the D-Bus session bus.\nPlease check your system settings and try again.";
        return 1;
    }

    // Create DBus interface
    InputHandlerDBus *dbusInterface = new InputHandlerDBus(&app);

    // Create SDL controller
    SdlController *sdlController = new SdlController();
    dbusInterface->setSdlController(sdlController);

#ifdef HAS_LIBCEC
    // Create CEC controller
    CECController *cecController = new CECController();
    dbusInterface->setCecController(cecController);
#endif

    return app.exec();
}
