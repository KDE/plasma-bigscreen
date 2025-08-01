// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QCoroQml>
#include <QCoroTask>
#include <QObject>
#include <qqmlregistration.h>

class QQmlEngine;
class WebAppManager;

class WebAppCreator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString websiteName READ websiteName WRITE setWebsiteName NOTIFY websiteNameChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY existsChanged)

public:
    explicit WebAppCreator(QObject *parent = nullptr);

    const QString &websiteName() const;
    void setWebsiteName(const QString &websiteName);
    Q_SIGNAL void websiteNameChanged();

    bool exists() const;
    Q_SIGNAL void existsChanged();

    Q_INVOKABLE QCoro::Task<> addEntry(const QString name, const QString url, const QString icon, const QString &userAgent);
    Q_INVOKABLE QCoro::QmlTask createDesktopFile(const QString name, QString url, QString icon, const QString &userAgent);

private:
    QString m_websiteName;
    QCoro::Task<QImage> fetchIcon(const QString &url);
    WebAppManager &m_webAppMngr;
};
