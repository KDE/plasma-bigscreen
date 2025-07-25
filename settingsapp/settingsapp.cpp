// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

#include "settingsapp.h"

SettingsApp::SettingsApp(QObject *parent)
    : QObject{parent}
{
}

SettingsApp *SettingsApp::instance()
{
    static SettingsApp *singleton = new SettingsApp();
    return singleton;
}

SettingsApp *SettingsApp::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine);
    Q_UNUSED(jsEngine);
    auto *model = instance();
    QQmlEngine::setObjectOwnership(model, QQmlEngine::CppOwnership);
    return model;
}

QString SettingsApp::launchModule() const
{
    return m_launchModule;
}

void SettingsApp::setLaunchModule(QString launchModule)
{
    m_launchModule = launchModule;
}
