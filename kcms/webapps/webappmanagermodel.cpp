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
    case Role::IdRole:
        return m_webAppMngr.applications()[index.row()].id;
    case Role::NameRole:
        return m_webAppMngr.applications()[index.row()].name;
    case Role::IconRole:
        return m_webAppMngr.applications()[index.row()].icon;
        // return QString(WebAppManager::iconDirectory() + QString(QDir::separator()) + m_webAppMngr.applications()[index.row()].icon);
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
        {Role::IdRole, QByteArrayLiteral("id")},
        {Role::NameRole, QByteArrayLiteral("name")},
        {Role::IconRole, QByteArrayLiteral("desktopIcon")},
        {Role::UrlRole, QByteArrayLiteral("url")},
        {Role::UserAgentRole, QByteArrayLiteral("userAgent")},
    };
}

QCoro::QmlTask WebAppManagerModel::addEntry(const QString &name, const QString &url, const QString &iconUrl, const QString &userAgent)
{
    return addEntryInternal(name, url, iconUrl, userAgent);
}

void WebAppManagerModel::removeApp(const QString &id)
{
    int index = -1;
    for (int i = 0; i < m_webAppMngr.applications().size(); ++i) {
        if (m_webAppMngr.applications()[i].id == id) {
            index = i;
            break;
        }
    }

    if (index != -1) {
        beginRemoveRows({}, index, index);
        m_webAppMngr.removeApp(id);
        endRemoveRows();
    }
}

QCoro::Task<> WebAppManagerModel::addEntryInternal(const QString &name, const QString &url, const QString &iconUrl, const QString &userAgent)
{
    beginResetModel();
    co_await m_webAppCreator.addEntry(name, url, iconUrl, userAgent);
    endResetModel();
}

#include "moc_webappmanagermodel.cpp"
