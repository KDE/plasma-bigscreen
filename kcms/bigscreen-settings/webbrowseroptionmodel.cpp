/*
    SPDX-FileCopyrightText: 2022 Méven Car <meven@kde.org>
    SPDX-FIleCopyrightText: 2026 User8395 <therealuser8395@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "webbrowseroptionmodel.h"

#include <KApplicationTrader>
#include <KLocalizedString>

WebBrowserOptionModel::WebBrowserOptionModel(QObject *parent)
    : QAbstractListModel(parent)
{
    beginResetModel();

    m_applications.clear();

    KApplicationTrader::query([this](const KService::Ptr &service) {
        if (service->exec().isEmpty() || (!service->categories().contains(QStringLiteral("WebBrowser")))) {
            return false;
        }

        const auto icon = service->icon().isEmpty() ? QStringLiteral("application-x-shellscript") : service->icon();

        addApplication(service->name(), icon, service->storageId());

        return true;
    });

    endResetModel();
}

void WebBrowserOptionModel::addApplication(const QString &name, const QString &iconName, const QString &storageId)
{
    QVariantMap application;
    application[QStringLiteral("name")] = name;
    application[QStringLiteral("icon")] = iconName;
    application[QStringLiteral("storageId")] = storageId;
    m_applications += application;
}

int WebBrowserOptionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_applications.length();
}

QVariant WebBrowserOptionModel::data(const QModelIndex &index, int role) const
{
    if (!isValid(index))
        return {};

    int row = index.row();
    const auto map = m_applications.at(row);
    switch (role) {
    case Qt::DisplayRole:
        return map[QStringLiteral("name")];
    case Icon:
        return map[QStringLiteral("icon")];
    case StorageId:
        return map[QStringLiteral("storageId")];
    }

    qInfo() << map;
 
    return {};
}

bool WebBrowserOptionModel::isValid(const QModelIndex &index) const
{
    return index.column() == 0 && index.row() >= 0 && index.row() < m_applications.length();
}

int WebBrowserOptionModel::findByStorageId(const QString &storageId) const
{
    int i = 0;
    for (const auto &application : std::as_const(m_applications)) {
        if (application[QStringLiteral("storageId")] == storageId) {
            return i;
        }
        ++i;
    }
    return -1;
}

QHash<int, QByteArray> WebBrowserOptionModel::roleNames() const
{
    return {
        {Qt::DisplayRole, QByteArrayLiteral("name")},
        {Icon, QByteArrayLiteral("icon")},
        {StorageId, QByteArrayLiteral("storageId")}
    };
}

#include "moc_webbrowseroptionmodel.cpp"