/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "favslistmodel.h"
#include <KConfigGroup>
#include <KSharedConfig>
#include <QVariantMap>


FavsManager *FavsManager::instance()
{
    static FavsManager* s_self = nullptr;
    if (!s_self) {
        s_self = new FavsManager;
    }
    return s_self;
}

FavsManager::FavsManager(QObject *parent)
    : QObject(parent)
{
    loadFavsList();
}

FavsManager::~FavsManager()
{
}

bool FavsManager::isFav(const QString &storageId, const QString &entryPath)
{
    for (const QVariantMap &fav : std::as_const(m_favsList)) {
        if (fav.value(QLatin1String("storageId")) == storageId && fav.value(QLatin1String("entryPath")) == entryPath) {
            return true;
        }
    }

    return false;
}

QList<QVariantMap> FavsManager::favsList()
{
    return m_favsList;
}

void FavsManager::addFav(QVariantMap fav)
{
    if (isFav(fav.value(QLatin1String("storageId")).toString(), fav.value(QLatin1String("entryPath")).toString())) {
        return;
    }

    m_favsList.append(fav);
    saveFavsList();
}

void FavsManager::removeFav(QVariantMap fav)
{
    for (int i = 0; i < m_favsList.count(); ++i) {
        const QVariantMap &favMap = m_favsList.at(i);
        if (favMap.value(QLatin1String("storageId")) == fav.value(QLatin1String("storageId")) && favMap.value(QLatin1String("entryPath")) == fav.value(QLatin1String("entryPath"))) {
            m_favsList.removeAt(i);
            saveFavsList();
            return;
        }
    }
}

void FavsManager::moveFav(QVariantMap fav, int destinationIndex)
{
    if (destinationIndex < 0 || destinationIndex >= m_favsList.count()) {
        return;
    }

    m_favsList.removeOne(fav);
    m_favsList.insert(destinationIndex, fav);
    saveFavsList();
    Q_EMIT favOrderChanged();
}

void FavsManager::clearFavs()
{
    m_favsList.clear();
    saveFavsList();
    Q_EMIT favsCleared();
}

void FavsManager::saveFavsList()
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("bigscreen-favs"));
    static KConfigGroup grp(config, QLatin1String("Favs"));
    
    if (grp.isValid()) {
        grp.deleteGroup();
    }

    // Create a separate group for each fav entry within the Favs group
    // And again m_favsList is a QList of QVariantMap be careful
    for (int i = 0; i < m_favsList.count(); ++i) {
        const QVariantMap &fav = m_favsList.at(i);
        KConfigGroup favGrp = grp.group(QString::number(i));
        favGrp.writeEntry(QLatin1String("storageId"), fav.value(QLatin1String("storageId")));
        favGrp.writeEntry(QLatin1String("entryPath"), fav.value(QLatin1String("entryPath")));
        favGrp.writeEntry(QLatin1String("desktopPath"), fav.value(QLatin1String("desktopPath")));
        favGrp.writeEntry(QLatin1String("name"), fav.value(QLatin1String("name")));
        favGrp.writeEntry(QLatin1String("comment"), fav.value(QLatin1String("comment")));
        favGrp.writeEntry(QLatin1String("icon"), fav.value(QLatin1String("icon")));
        favGrp.writeEntry(QLatin1String("categories"), fav.value(QLatin1String("categories")));
        favGrp.writeEntry(QLatin1String("startupNotify"), fav.value(QLatin1String("startupNotify")));
    }
    
    grp.sync();
    Q_EMIT favsListChanged();
}

void FavsManager::loadFavsList()
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("bigscreen-favs"));
    static KConfigGroup grp(config, QLatin1String("Favs"));

    if (!grp.isValid()) {
        return;
    }

    m_favsList.clear();
    const QStringList favs = grp.groupList();

    for (const QString &fav : favs) {
        KConfigGroup favGrp = grp.group(fav);
        QVariantMap favMap;
        favMap[QLatin1String("storageId")] = favGrp.readEntry(QLatin1String("storageId"));
        favMap[QLatin1String("entryPath")] = favGrp.readEntry(QLatin1String("entryPath"));
        favMap[QLatin1String("desktopPath")] = favGrp.readEntry(QLatin1String("desktopPath"));
        favMap[QLatin1String("name")] = favGrp.readEntry(QLatin1String("name"));
        favMap[QLatin1String("comment")] = favGrp.readEntry(QLatin1String("comment"));
        favMap[QLatin1String("icon")] = favGrp.readEntry(QLatin1String("icon"));
        favMap[QLatin1String("categories")] = favGrp.readEntry(QLatin1String("categories"));
        favMap[QLatin1String("startupNotify")] = favGrp.readEntry(QLatin1String("startupNotify"));

        m_favsList.append(favMap);
    }

}

FavsListModel::FavsListModel(FavsManager *favsManager, QObject *parent)
    : QAbstractListModel(parent)
{
    m_favsManager = favsManager;
    QObject::connect(m_favsManager, &FavsManager::favsListChanged, this, &FavsListModel::resetModel);
    resetModel();
}

FavsListModel::~FavsListModel()
{
}

int FavsListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_favsManager->favsList().count();
}

void FavsListModel::moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild)
{
    Q_UNUSED(sourceParent)
    Q_UNUSED(destinationParent)
    m_favsManager->moveFav(m_favsManager->favsList().at(sourceRow), destinationChild);
}

int FavsListModel::count()
{
    return m_favsManager->favsList().count();
}

QVariant FavsListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    const QList<QVariantMap> favsList = m_favsManager->favsList();
    if (index.row() >= favsList.count()) {
        return QVariant();
    }

    const QVariantMap fav = favsList.at(index.row());
    switch (role) {
        case ApplicationNameRole:
            return fav.value(QLatin1String("name"));
        case ApplicationCommentRole:
            return fav.value(QLatin1String("comment"));
        case ApplicationIconRole:
            return fav.value(QLatin1String("icon"));
        case ApplicationCategoriesRole:
            return fav.value(QLatin1String("categories"));
        case ApplicationStorageIdRole:
            return fav.value(QLatin1String("storageId"));
        case ApplicationEntryPathRole:
            return fav.value(QLatin1String("entryPath"));
        case ApplicationDesktopRole:
            return fav.value(QLatin1String("desktopPath"));
        case ApplicationStartupNotifyRole:
            return fav.value(QLatin1String("startupNotify"));
        case ApplicationOriginalRowRole:
            return index.row();

        default:
            return QVariant();
    }
}

Qt::ItemFlags FavsListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }

    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled;
}

QHash<int, QByteArray> FavsListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ApplicationNameRole] = "ApplicationNameRole";
    roles[ApplicationCommentRole] = "ApplicationCommentRole";
    roles[ApplicationIconRole] = "ApplicationIconRole";
    roles[ApplicationCategoriesRole] = "ApplicationCategoriesRole";
    roles[ApplicationStorageIdRole] = "ApplicationStorageIdRole";
    roles[ApplicationEntryPathRole] = "ApplicationEntryPathRole";
    roles[ApplicationDesktopRole] = "ApplicationDesktopRole";
    roles[ApplicationStartupNotifyRole] = "ApplicationStartupNotifyRole";
    roles[ApplicationOriginalRowRole] = "ApplicationOriginalRowRole";
    return roles;
}

void FavsListModel::resetModel()
{
    beginResetModel();
    endResetModel();
    Q_EMIT countChanged();
}

QVariantMap FavsListModel::itemMap(int index)
{
    QVariantMap map;
    map[QLatin1String("name")] = data(createIndex(index, 0), ApplicationNameRole);
    map[QLatin1String("comment")] = data(createIndex(index, 0), ApplicationCommentRole);
    map[QLatin1String("icon")] = data(createIndex(index, 0), ApplicationIconRole);
    map[QLatin1String("categories")] = data(createIndex(index, 0), ApplicationCategoriesRole);
    map[QLatin1String("storageId")] = data(createIndex(index, 0), ApplicationStorageIdRole);
    map[QLatin1String("entryPath")] = data(createIndex(index, 0), ApplicationEntryPathRole);
    map[QLatin1String("desktopPath")] = data(createIndex(index, 0), ApplicationDesktopRole);
    map[QLatin1String("startupNotify")] = data(createIndex(index, 0), ApplicationStartupNotifyRole);
    return map;
}