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
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QIcon>

#include <KConfigGroup>
#include <KDesktopFile>

#include <QCoroSignal>
#include <QCoroTask>

#define FAVICON_API_URL "https://icons.duckduckgo.com/ip3/"

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

QCoro::Task<> WebAppCreator::addEntry(const QString name, const QString url, const QString &userAgent)
{
    QPointer self = this;
    QUrl fixedUrl = QUrl::fromUserInput(url);
    fixedUrl.setScheme("https");
    auto image = co_await fetchIcon(fixedUrl.toString());
    if (!self) {
        co_return;
    }

    m_webAppMngr.addApp(name, fixedUrl.toString(), image, userAgent);;

    // Refresh homescreen entries
    QProcess buildsycoca;
    buildsycoca.setProgram(QStringLiteral("kbuildsycoca6"));
    buildsycoca.startDetached();
    co_return;
}

QCoro::Task<QImage> WebAppCreator::fetchIcon(const QString &url)
{ 
    QNetworkAccessManager manager;
    QImage image;
    QEventLoop loop;
    
    QUrl iconUrl(FAVICON_API_URL + (new QUrl(url))->authority() + ".ico"); // chop off the http:// so that DDG can understand the url

    QNetworkRequest request(iconUrl);
    QNetworkReply *reply = manager.get(request);

    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    
    if (reply->error() == QNetworkReply::NoError) {
        image.loadFromData(reply->readAll());
    } else {
        qWarning() << reply->errorString();
        image = QIcon::fromTheme(QStringLiteral("internet-web-browser")).pixmap(QSize(32, 32)).toImage();
    }

    reply->deleteLater();

    co_return image;
}
