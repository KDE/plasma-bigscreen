// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "webappskcm.h"

#include "webappcreator.h"
#include "webappmanager.h"
#include "webappmanagermodel.h"

WebAppsKCM::WebAppsKCM(QObject *parent, const KPluginMetaData &data)
    : KQuickConfigModule(parent, data)
{
    WebAppManager::instance();
    WebAppManagerModel *model = new WebAppManagerModel{this};

    qmlRegisterSingletonType<WebAppManager>("org.kde.bigscreen.webappskcm", 1, 0, "WebAppManager", [this](QQmlEngine *, QJSEngine *) -> QObject * {
        return new WebAppManager{this};
    });
    qmlRegisterSingletonType<WebAppManagerModel>("org.kde.bigscreen.webappskcm", 1, 0, "WebAppManagerModel", [this](QQmlEngine *, QJSEngine *) -> QObject * {
        return new WebAppManagerModel{this};
    });
}

WebAppsKCM::~WebAppsKCM() = default;

K_PLUGIN_CLASS_WITH_JSON(WebAppsKCM, "kcm_mediacenter_webapps.json")

#include "moc_webappskcm.cpp"
#include "webappskcm.moc"
