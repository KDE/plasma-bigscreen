
// SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

class BrowserManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl initialUrl READ initialUrl WRITE setInitialUrl NOTIFY initialUrlChanged)
    QML_ELEMENT
    QML_SINGLETON

public:
    static BrowserManager *instance();
    static BrowserManager *create(QQmlEngine *, QJSEngine *)
    {
        return BrowserManager::instance();
    }
    QUrl initialUrl() const;
    void setInitialUrl(const QUrl &initialUrl);

Q_SIGNALS:
    void updated();
    void initialUrlChanged();

public Q_SLOTS:
    void addToHistory(const QVariantMap &pagedata);
    void removeFromHistory(const QString &url);
    void clearHistory();
    void updateLastVisited(const QString &url);
    void updateIcon(const QString &url, const QString &iconSource);
    QString tempDirectory() const;
    QString downloadDirectory() const;

private:
    BrowserManager(QObject *parent = nullptr);
    QUrl m_initialUrl;
    static BrowserManager *s_instance;
};
