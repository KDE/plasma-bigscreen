/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "kcmslistmodel.h"
#include <QFile>
#include <KPluginMetaData>

KcmsListModel::KcmsListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

KcmsListModel::~KcmsListModel() = default;

QVariantMap KcmsListModel::get(int index) const
{
    if (index < 0 || index >= m_kcms.count()) {
        return QVariantMap();
    }

    QVariantMap map;
    map["kcmId"] = m_kcms.at(index).id;
    map["kcmIconName"] = m_kcms.at(index).iconName;
    map["kcmDescription"] = m_kcms.at(index).description;
    map["kcmName"] = m_kcms.at(index).name;
    map["kcmPath"] = m_kcms.at(index).path;
    return map;
}

QHash<int, QByteArray> KcmsListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[KcmIdRole] = "kcmId";
    roles[KcmIconNameRole] = "kcmIconName";
    roles[KcmDescriptionRole] = "kcmDescription";
    roles[KcmNameRole] = "kcmName";
    roles[KcmRole] = "kcm";
    roles[KcmPathRole] = "kcmMetaData";
    return roles;
}

int KcmsListModel::count() const
{
    return m_kcms.count();
}

void KcmsListModel::loadKcms()
{
    beginResetModel();
    m_kcms.clear();

    QMap<int, KcmData> orderedList;
    QList<KcmData> unorderedList;

    auto filter = [this](const KPluginMetaData &data) {
        // TODO: one day, filter by form factor and not name (once kcms are updated with proper form factor)
        if (data.pluginId().contains("mediacenter")) {
            return true;
        }
        return false;
    };

    QList<KPluginMetaData> kcms = KPluginMetaData::findPlugins("kcms", filter);
    kcms << KPluginMetaData::findPlugins("plasma/kcms", filter);
    kcms << KPluginMetaData::findPlugins("plasma/kcms/systemsettings", filter);

    for (const auto &kcm : kcms) {
        KcmData kcmData;
        kcmData.name = kcm.name();
        kcmData.description = kcm.description();
        kcmData.iconName = kcm.iconName();
        kcmData.id = kcm.pluginId();
        kcmData.path = kcm.fileName();

        auto it = m_appPositions.constFind(kcm.pluginId());
        if (it != m_appPositions.constEnd()) {
            orderedList.insert(it.value(), kcmData);
        } else {
            unorderedList.append(kcmData);
        }
    }

    KcmData wallpaperData;
    wallpaperData.name = "Wallpaper";
    wallpaperData.iconName = "preferences-desktop-wallpaper";
    wallpaperData.description = "Change the desktop wallpaper";
    wallpaperData.id = "kcm_mediacenter_wallpaper";
    unorderedList.append(wallpaperData);

    m_kcms << orderedList.values();
    m_kcms << unorderedList;

    // Sort alphabetically
    std::sort(m_kcms.begin(), m_kcms.end(), [](const KcmData &k1, const KcmData &k2) {
        return k1.name < k2.name;
    });

    endResetModel();
    Q_EMIT countChanged();
}

QVariant KcmsListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case KcmIdRole:
        return m_kcms.at(index.row()).id;
    case KcmIconNameRole:
        return m_kcms.at(index.row()).iconName;
    case KcmDescriptionRole:
        return m_kcms.at(index.row()).description;
    case KcmNameRole:
        return m_kcms.at(index.row()).name;
    case KcmRole:
        return m_kcms.at(index.row()).id;
    case KcmPathRole:
        return m_kcms.at(index.row()).path;
    default:
        return QVariant();
    }
}

void KcmsListModel::moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild)
{
    Q_UNUSED(sourceParent);
    Q_UNUSED(destinationParent);
    moveItem(sourceRow, destinationChild);
}

void KcmsListModel::moveItem(int row, int destination)
{
    if (row < 0 || destination < 0 || row >= m_kcms.length() || destination >= m_kcms.length() || row == destination) {
        return;
    }
    if (destination > row) {
        ++destination;
    }

    beginMoveRows(QModelIndex(), row, row, QModelIndex(), destination);
    if (destination > row) {
        KcmData data = m_kcms.at(row);
        m_kcms.insert(destination, data);
        m_kcms.takeAt(row);
    } else {
        KcmData data = m_kcms.takeAt(row);
        m_kcms.insert(destination, data);
    }

    m_appOrder.clear();
    m_appPositions.clear();
    int i = 0;
    for (const auto &app : std::as_const(m_kcms)) {
        m_appOrder << app.id;
        m_appPositions[app.id] = i;
        ++i;
    }

    Q_EMIT appOrderChanged();
    endMoveRows();
}

int KcmsListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_kcms.count();
}

Qt::ItemFlags KcmsListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }
    return Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QStringList KcmsListModel::appOrder() const
{
    return m_appOrder;
}

void KcmsListModel::setAppOrder(const QStringList &order)
{
    if (m_appOrder == order) {
        return;
    }

    m_appOrder = order;
    m_appPositions.clear();
    int i = 0;
    for (const auto &app : std::as_const(m_appOrder)) {
        m_appPositions[app] = i;
        ++i;
    }
    Q_EMIT appOrderChanged();
}
