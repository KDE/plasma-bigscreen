// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QCoroQml>
#include <QCoroTask>

#include <qqmlregistration.h>

#include "webappcreator.h"

class WebAppManager;

class WebAppManagerModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    enum Role {
        IdRole,
        NameRole,
        IconRole,
        UrlRole,
        UserAgentRole
    };

public:
    explicit WebAppManagerModel(QObject *parent = nullptr);
    ~WebAppManagerModel();

    int rowCount(const QModelIndex &index) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QCoro::QmlTask addEntry(const QString &name, const QString &url, const QString &iconUrl, const QString &userAgent);
    Q_INVOKABLE void removeApp(const QString &id);

private:
    QCoro::Task<> addEntryInternal(const QString &name, const QString &url, const QString &iconUrl, const QString &userAgent);

    WebAppManager &m_webAppMngr;
    WebAppCreator m_webAppCreator;
};
