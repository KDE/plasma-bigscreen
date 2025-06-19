// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>
#include <QtQml/qqmlregistration.h>

class QQuickWebEngineProfile;

class UserAgent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString userAgent READ userAgent WRITE setUserAgent NOTIFY userAgentChanged)
    QML_ELEMENT
    QML_SINGLETON

public:
    static UserAgent *instance();
    static UserAgent *create(QQmlEngine *, QJSEngine *)
    {
        return UserAgent::instance();
    }
    explicit UserAgent(QObject *parent = nullptr);
    QString userAgent() const;
    void setUserAgent(QString userAgent);

Q_SIGNALS:
    void userAgentChanged();

private:
    QStringView extractValueFromAgent(const QStringView key);

    const QQuickWebEngineProfile *m_defaultProfile;
    const QString m_defaultUserAgent;
    const QStringView m_chromeVersion;
    const QStringView m_appleWebKitVersion;
    const QStringView m_webEngineVersion;
    const QStringView m_safariVersion;

    QString m_userAgent;
    static UserAgent *s_instance;
};
