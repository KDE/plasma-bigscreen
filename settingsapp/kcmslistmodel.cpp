/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "kcmslistmodel.h"
#include <KPluginMetaData>
#include <QFile>

KcmsListModel::KcmsListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

KcmsListModel::~KcmsListModel() = default;

KcmsListModel *KcmsListModel::instance()
{
    static KcmsListModel *singleton = new KcmsListModel();
    return singleton;
}

KcmsListModel *KcmsListModel::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine);
    Q_UNUSED(jsEngine);
    auto *model = instance();
    QQmlEngine::setObjectOwnership(model, QQmlEngine::CppOwnership);
    return model;
}

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
