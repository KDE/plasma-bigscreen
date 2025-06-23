// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractListModel>

#include <qqmlregistration.h>

class WebAppManager;

class WebAppManagerModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    enum Role {
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

    Q_INVOKABLE void removeApp(int index);

private:
    WebAppManager &m_webAppMngr;
};
