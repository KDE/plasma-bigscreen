/*
    SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
    SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Self
#include "applicationlistmodel.h"

// Qt
#include <QByteArray>
#include <QModelIndex>
#include <QProcess>
#include <QRegularExpression>

// KDE
#include <KApplicationTrader>
#include <KConfigGroup>
#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <KServiceGroup>
#include <KSharedConfig>
#include <KShell>
#include <KSycoca>
#include <KSycocaEntry>
#include <PlasmaActivities/ResourceInstance>

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(KSycoca::self(), static_cast<void (KSycoca::*)()>(&KSycoca::databaseChanged), this, &ApplicationListModel::sycocaDbChanged);
    loadApplications();
}

ApplicationListModel::~ApplicationListModel() = default;

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[ApplicationNameRole] = "ApplicationNameRole";
    roleNames[ApplicationCommentRole] = "ApplicationCommentRole";
    roleNames[ApplicationIconRole] = "ApplicationIconRole";
    roleNames[ApplicationCategoriesRole] = "ApplicationCategoriesRole";
    roleNames[ApplicationStorageIdRole] = "ApplicationStorageIdRole";
    roleNames[ApplicationEntryPathRole] = "ApplicationEntryPathRole";
    roleNames[ApplicationDesktopRole] = "ApplicationDesktopRole";
    roleNames[ApplicationStartupNotifyRole] = "ApplicationStartupNotifyRole";
    roleNames[ApplicationOriginalRowRole] = "ApplicationOriginalRowRole";

    return roleNames;
}

void ApplicationListModel::sycocaDbChanged()
{
    loadApplications();
}

KService::List ApplicationListModel::queryApplications()
{
    auto cfg = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    const QStringList blacklist = blgroup.readEntry("blacklist", QStringList());
    auto filter = [blacklist](const KService::Ptr &service) -> bool {
        if (service->noDisplay()) {
            return false;
        }
        if (!service->showOnCurrentPlatform()) {
            return false;
        }
        if (blacklist.contains(service->desktopEntryName())) {
            return false;
        }
        if (service->property<bool>("Terminal")) {
            return false;
        }
        if (!service->isApplication()) {
            return false;
        }

        return true;
    };

    return KApplicationTrader::query(filter);
}

void ApplicationListModel::loadApplications()
{
    qDebug() << "Reloading app list...";

    // This function supports dynamic insertions and deletions to the existing
    // list depending on what is given from queryApplications().

    QMap<QString, int> storageIdMap; // <storageId, index>
    for (int i = 0; i < m_applicationList.size(); ++i) {
        const auto &data = m_applicationList[i];
        storageIdMap.insert(data.storageId, i);
    }

    const KService::List currentApps = queryApplications();
    QList<KService::Ptr> toInsert;

    for (const KService::Ptr &service : currentApps) {
        auto it = storageIdMap.find(service->storageId());
        if (it != storageIdMap.end()) {
            // Service already in m_applicationList
            storageIdMap.erase(it);
        } else {
            // Service needs to be inserted into m_applicationList
            toInsert.append(std::move(service));
        }
    }

    QList<int> toRemove;
    for (int index : storageIdMap.values()) {
        toRemove.append(index);
    }

    std::sort(toRemove.begin(), toRemove.end());

    // Remove indices first, from end to start to avoid indices changing
    for (int i = toRemove.size() - 1; i >= 0; --i) {
        int ind = toRemove[i];

        QString storageId = m_applicationList[ind].storageId;

        beginRemoveRows({}, ind, ind);
        m_applicationList.removeAt(ind);
        endRemoveRows();

        Q_EMIT applicationRemoved(storageId);
    }

    // Append new elements
    for (const KService::Ptr &service : toInsert) {
        ApplicationData data;
        data.name = service->name();
        data.comment = service->comment();
        data.icon = service->icon();
        data.categories = service->categories();
        data.storageId = service->storageId();
        data.entryPath = service->exec();
        data.desktopPath = service->entryPath();
        data.startupNotify = service->property<bool>("StartupNotify");

        beginInsertRows({}, m_applicationList.size(), m_applicationList.size());
        m_applicationList.append(data);
        endInsertRows();
    }
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case ApplicationNameRole:
        return m_applicationList.at(index.row()).name;
    case ApplicationCommentRole:
        return m_applicationList.at(index.row()).comment;
    case ApplicationIconRole:
        return m_applicationList.at(index.row()).icon;
    case ApplicationCategoriesRole:
        return m_applicationList.at(index.row()).categories;
    case ApplicationStorageIdRole:
        return m_applicationList.at(index.row()).storageId;
    case ApplicationEntryPathRole:
        return m_applicationList.at(index.row()).entryPath;
    case ApplicationDesktopRole:
        return m_applicationList.at(index.row()).desktopPath;
    case ApplicationStartupNotifyRole:
        return m_applicationList.at(index.row()).startupNotify;
    case ApplicationOriginalRowRole:
        return index.row();

    default:
        return QVariant();
    }
}

Qt::ItemFlags ApplicationListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }
    return Qt::ItemIsDragEnabled | QAbstractItemModel::flags(index);
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}

void ApplicationListModel::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    QStringList args = command.split(QStringLiteral(" "));
    QString app = args.takeFirst();
    QProcess::startDetached(app, args);
}

void ApplicationListModel::runApplication(const QString &storageId)
{
    if (storageId.isEmpty()) {
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);
    if (!service) {
        return;
    }

    KIO::ApplicationLauncherJob *job = new KIO::ApplicationLauncherJob(service);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->start();

    KActivities::ResourceInstance::notifyAccessed(QUrl(QStringLiteral("applications:") + service->storageId()), QStringLiteral("org.kde.plasma.kicker"));
}

QVariantMap ApplicationListModel::itemMap(int index)
{
    QVariantMap map;
    map[QStringLiteral("name")] = m_applicationList.at(index).name;
    map[QStringLiteral("comment")] = m_applicationList.at(index).comment;
    map[QStringLiteral("icon")] = m_applicationList.at(index).icon;
    map[QStringLiteral("categories")] = m_applicationList.at(index).categories;
    map[QStringLiteral("storageId")] = m_applicationList.at(index).storageId;
    map[QStringLiteral("entryPath")] = m_applicationList.at(index).entryPath;
    map[QStringLiteral("desktopPath")] = m_applicationList.at(index).desktopPath;
    map[QStringLiteral("startupNotify")] = m_applicationList.at(index).startupNotify;

    return map;
}

ApplicationListSearchModel::ApplicationListSearchModel(QObject *parent, ApplicationListModel *model)
    : QSortFilterProxyModel(parent)
{
    setSourceModel(model);

    setFilterRole(ApplicationListModel::ApplicationNameRole);
    setFilterCaseSensitivity(Qt::CaseInsensitive);

    setSortRole(ApplicationListModel::ApplicationNameRole);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);

    sort(0, Qt::AscendingOrder);
}
