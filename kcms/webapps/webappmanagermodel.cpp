// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "webappmanagermodel.h"

#include "webappmanager.h"

WebAppManagerModel::WebAppManagerModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_webAppMngr(WebAppManager::instance())
{
}

WebAppManagerModel::~WebAppManagerModel() = default;

int WebAppManagerModel::rowCount(const QModelIndex &index) const
{
    return index.isValid() ? 0 : int(m_webAppMngr.applications().size());
}

QVariant WebAppManagerModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case Role::NameRole:
        return m_webAppMngr.applications()[index.row()].name;
    case Role::IconRole:
        return QString(WebAppManager::iconDirectory() + QString(QDir::separator()) + m_webAppMngr.applications()[index.row()].icon);
    case Role::UrlRole:
        return m_webAppMngr.applications()[index.row()].url;
    case Role::UserAgentRole:
        return m_webAppMngr.applications()[index.row()].userAgent;
    }

    Q_UNREACHABLE();

    return {};
}

QHash<int, QByteArray> WebAppManagerModel::roleNames() const
{
    return {
        {Role::NameRole, QByteArrayLiteral("name")},
        {Role::IconRole, QByteArrayLiteral("desktopIcon")},
        {Role::UrlRole, QByteArrayLiteral("url")},
        {Role::UserAgentRole, QByteArrayLiteral("userAgent")},
    };
}

void WebAppManagerModel::removeApp(int index)
{
    beginRemoveRows({}, index, index);
    m_webAppMngr.removeApp(m_webAppMngr.applications()[index].name);
    endRemoveRows();
}

#include "moc_webappmanagermodel.cpp"
