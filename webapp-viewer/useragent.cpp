// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "useragent.h"

#include <QQuickWebEngineProfile>

UserAgent *UserAgent::s_instance = nullptr;

UserAgent::UserAgent(QObject *parent)
    : QObject(parent)
    , m_defaultProfile(QQuickWebEngineProfile::defaultProfile())
    , m_defaultUserAgent(m_defaultProfile->httpUserAgent())
    , m_chromeVersion(extractValueFromAgent(u"Chrome"))
    , m_appleWebKitVersion(extractValueFromAgent(u"AppleWebKit"))
    , m_webEngineVersion(extractValueFromAgent(u"QtWebEngine"))
    , m_safariVersion(extractValueFromAgent(u"Safari"))
{
}

QString UserAgent::userAgent() const
{
    if (m_userAgent.isEmpty()) {
        return QStringView(
                   u"Mozilla/5.0 (%1) AppleWebKit/%2 (KHTML, like Gecko) QtWebEngine/%3 "
                   u"Chrome/%4 %5 Safari/%6")
            .arg(u"X11; Linux x86_64", m_appleWebKitVersion, m_webEngineVersion, m_chromeVersion, u"Desktop", m_safariVersion);
    }

    return m_userAgent;
}

void UserAgent::setUserAgent(QString userAgent)
{
    m_userAgent = userAgent;
    Q_EMIT userAgentChanged();
}

QStringView UserAgent::extractValueFromAgent(const QStringView key)
{
    const int index = m_defaultUserAgent.indexOf(key) + key.length() + 1;
    int endIndex = m_defaultUserAgent.indexOf(u' ', index);
    if (endIndex == -1) {
        endIndex = m_defaultUserAgent.size();
    }
    return QStringView(m_defaultUserAgent).mid(index, endIndex - index);
}

UserAgent *UserAgent::instance()
{
    if (!s_instance)
        s_instance = new UserAgent();

    return s_instance;
}

#include "moc_useragent.cpp"
