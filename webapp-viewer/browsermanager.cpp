// SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "browsermanager.h"

#include <QDebug>
#include <QQmlEngine>
#include <QSettings>
#include <QStandardPaths>
#include <QUrl>

BrowserManager *BrowserManager::s_instance = nullptr;

BrowserManager::BrowserManager(QObject *parent)
    : QObject(parent)
{
}

void BrowserManager::addToHistory(const QVariantMap &pagedata)
{
    // m_dbmanager->addToHistory(pagedata);
}

void BrowserManager::removeFromHistory(const QString &url)
{
    // m_dbmanager->removeFromHistory(url);
}

void BrowserManager::clearHistory()
{
    // m_dbmanager->clearHistory();
}

void BrowserManager::updateLastVisited(const QString &url)
{
    // m_dbmanager->updateLastVisited(url);
}

void BrowserManager::updateIcon(const QString &url, const QString &iconSource)
{
    auto *engine = qmlEngine(this);
    Q_ASSERT(engine);
    // TODO
    // m_dbmanager->updateIcon(engine, url, iconSource);
}

QUrl BrowserManager::initialUrl() const
{
    return m_initialUrl;
}

QString BrowserManager::tempDirectory() const
{
    return QStandardPaths::writableLocation(QStandardPaths::TempLocation);
}

QString BrowserManager::downloadDirectory() const
{
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}

void BrowserManager::setInitialUrl(const QUrl &initialUrl)
{
    m_initialUrl = initialUrl;
    Q_EMIT initialUrlChanged();
}

BrowserManager *BrowserManager::instance()
{
    if (!s_instance)
        s_instance = new BrowserManager();

    return s_instance;
}

#include "moc_browsermanager.cpp"
