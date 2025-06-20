// SPDX-FileCopyrightText: 2020-2021 Jonah Brüchert <jbb.prv@gmx.de>
//
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "webappcreator.h"
#include "webappmanager.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QProcess>
#include <QQmlEngine>
#include <QQuickImageProvider>
#include <QStandardPaths>

#include <KConfigGroup>
#include <KDesktopFile>

#include <QCoroSignal>
#include <QCoroTask>

WebAppCreator::WebAppCreator(QObject *parent)
    : QObject(parent)
    , m_webAppMngr(WebAppManager::instance())
{
    connect(this, &WebAppCreator::websiteNameChanged, this, &WebAppCreator::existsChanged);
    connect(&m_webAppMngr, &WebAppManager::applicationsChanged, this, &WebAppCreator::existsChanged);
}

bool WebAppCreator::exists() const
{
    return m_webAppMngr.exists(m_websiteName);
}

const QString &WebAppCreator::websiteName() const
{
    return m_websiteName;
}

void WebAppCreator::setWebsiteName(const QString &websiteName)
{
    m_websiteName = websiteName;
    Q_EMIT websiteNameChanged();
}

QCoro::Task<> WebAppCreator::addEntry(const QString name, const QString url, const QString iconUrl, const QString &userAgent)
{
    // QPointer self = this;
    // auto image = co_await fetchIcon(iconUrl);
    // if (!self) {
    //     co_return;
    // }

    // m_webAppMngr.addApp(name, url, image, userAgent);
    m_webAppMngr.addApp(name, url, iconUrl, userAgent);

    // Refresh homescreen entries
    QProcess buildsycoca;
    buildsycoca.setProgram(QStringLiteral("kbuildsycoca6"));
    buildsycoca.startDetached();
    co_return;
}

QCoro::QmlTask WebAppCreator::createDesktopFile(const QString name, QString url, QString icon, const QString &userAgent)
{
    return addEntry(name, url, icon, userAgent);
}

QCoro::Task<QImage> WebAppCreator::fetchIcon(const QString &url)
{
    auto *provider = static_cast<QQuickAsyncImageProvider *>(qmlEngine(this)->imageProvider(QStringLiteral("favicon")));
    if (!provider) {
        qDebug() << "Failed to access favicon provider";
        co_return QImage();
    }

    const QStringView prefixFavicon = QStringView(u"image://favicon/");
    const QString providerIconName = url.mid(prefixFavicon.size());

    const QSize szRequested;

    switch (provider->imageType()) {
    case QQmlImageProviderBase::Image: {
        co_return provider->requestImage(providerIconName, nullptr, szRequested);
    }
    case QQmlImageProviderBase::Pixmap: {
        co_return provider->requestPixmap(providerIconName, nullptr, szRequested).toImage();
    }
    case QQmlImageProviderBase::Texture: {
        co_return provider->requestTexture(providerIconName, nullptr, szRequested)->image();
    }
    case QQmlImageProviderBase::ImageResponse: {
        auto response = provider->requestImageResponse(providerIconName, szRequested);
        co_await qCoro(response, &QQuickImageResponse::finished);
        co_return response->textureFactory()->image();
    }
    default:
        qDebug() << "Failed to save unhandled image type";
    }

    co_return QImage();
}
