// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "webprofile.h"

#include <KLocalizedString>
#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickWindow>
#include <QWebEngineNotification>

#include <KNotification>

class QQuickWebEngineDownloadRequest : public DownloadItem
{
};

WebProfile::WebProfile(QObject *parent)
    : QQuickWebEngineProfile(parent)
    , m_urlInterceptor(nullptr)
{
    connect(this, &QQuickWebEngineProfile::downloadRequested, this, &WebProfile::handleDownload);
    connect(this, &QQuickWebEngineProfile::downloadFinished, this, &WebProfile::handleDownloadFinished);
    connect(this, &QQuickWebEngineProfile::presentNotification, this, &WebProfile::showNotification);
}

void WebProfile::handleDownload(QQuickWebEngineDownloadRequest *downloadItem)
{
    // TODO: do we handle downloads?
}

void WebProfile::handleDownloadFinished(DownloadItem *downloadItem)
{
    // TODO: do we handle downloads?
}

void WebProfile::showNotification(QWebEngineNotification *webNotification)
{
    auto *notification = new KNotification(QStringLiteral("web-notification"));
    notification->setComponentName(QStringLiteral("plasma-bigscreen"));
    notification->setTitle(webNotification->title());
    notification->setText(webNotification->message());
    notification->setPixmap(QPixmap::fromImage(webNotification->icon()));

    connect(notification, &KNotification::closed, webNotification, &QWebEngineNotification::close);

    auto defaultAction = notification->addDefaultAction(i18n("Open"));
    connect(defaultAction, &KNotificationAction::activated, webNotification, &QWebEngineNotification::click);

    notification->sendEvent();
}

QWebEngineUrlRequestInterceptor *WebProfile::urlInterceptor() const
{
    return m_urlInterceptor;
}

void WebProfile::setUrlInterceptor(QWebEngineUrlRequestInterceptor *urlRequestInterceptor)
{
    setUrlRequestInterceptor(urlRequestInterceptor);
    m_urlInterceptor = urlRequestInterceptor;
    Q_EMIT urlInterceptorChanged();
}

#include "moc_webprofile.cpp"
