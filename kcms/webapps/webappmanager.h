// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDir>
#include <QObject>

#include <memory>

struct WebApp {
    QString name;
    QString icon;
    QString url;
    QString userAgent;
};

class WebAppManager : public QObject
{
    Q_OBJECT

public:
    explicit WebAppManager(QObject *parent = nullptr);

    static QString desktopFileDirectory();
    static QString iconDirectory();
    const std::vector<WebApp> &applications() const;

    void addApp(const QString &name, const QString &url, const QImage &icon, const QString &userAgent);
    bool exists(const QString &name);
    bool removeApp(const QString &name);

    static WebAppManager &instance();

Q_SIGNALS:
    void applicationsChanged();

private:
    static QString generateFileName(const QString &name);
    static QString generateDesktopFileName(const QString &name);
    static QString webAppCommand();

private:
    QDir m_desktopFileDirectory;
    std::vector<WebApp> m_webApps;
};
