// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

#pragma once

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>
#include <qqmlregistration.h>

class SettingsApp : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString launchModule READ launchModule CONSTANT)

public:
    SettingsApp(QObject *parent = nullptr);

    static SettingsApp *instance();
    static SettingsApp *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    QString launchModule() const;
    void setLaunchModule(QString launchModule);

private:
    QString m_launchModule;
};
