#include "kcmslistmodel.h"
#include <KPluginMetaData>
#include <QFile>

KcmsListModel::KcmsListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(&m_configuration, &Configuration::mycroftEnabledChanged, this, &KcmsListModel::loadKcms);
}

KcmsListModel::~KcmsListModel() = default;

QHash<int, QByteArray> KcmsListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[KcmIdRole] = "kcmId";
    roles[KcmIconNameRole] = "kcmIconName";
    roles[KcmDescriptionRole] = "kcmDescription";
    roles[KcmNameRole] = "kcmName";
    roles[KcmRole] = "kcm";
    return roles;
}

int KcmsListModel::count()
{
    return m_kcms.count();
}

void KcmsListModel::loadKcms()
{
    qDebug() << "Loading kcms";
    beginResetModel();
    m_kcms.clear();

    m_mycroftEnabled = m_configuration.mycroftEnabled();

    QMap<int, KcmData> orderedList;
    QList<KcmData> unorderedList;

    const auto kcmPlugins = KPluginMetaData::findPlugins("kcms");
    // only get the mediacenter kcms
    for (const auto &kcm : kcmPlugins) {
        if (kcm.pluginId().contains("mediacenter")) {
            KcmData kcmData;
            kcmData.name = kcm.name();
            kcmData.description = kcm.description();
            kcmData.iconName = kcm.iconName();
            kcmData.id = kcm.pluginId();

            auto it = m_appPositions.constFind(kcm.pluginId());
            if (it != m_appPositions.constEnd()) {
                orderedList.insert(it.value(), kcmData);
            } else {
                unorderedList.append(kcmData);
            }
        }
    }

    KcmData wallpaperData;
    wallpaperData.name = "Wallpaper";
    wallpaperData.iconName = "preferences-desktop-wallpaper";
    wallpaperData.description = "Change the desktop wallpaper";
    wallpaperData.id = "kcm_mediacenter_wallpaper";
    unorderedList.append(wallpaperData);

    KcmData mycroftSkillInstallerData;
    mycroftSkillInstallerData.name = "Mycroft Skill Installer";
    mycroftSkillInstallerData.iconName = "download";
    mycroftSkillInstallerData.description = "Install Mycroft skills";
    mycroftSkillInstallerData.id = "kcm_mediacenter_mycroft_skill_installer";

    if (m_mycroftEnabled) {
        unorderedList.append(mycroftSkillInstallerData);
    }

    m_kcms << orderedList.values();
    m_kcms << unorderedList;

    endResetModel();
    emit countChanged();

    qDebug() << "KCM's discovered: " << m_kcms.size();
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
    default:
        return QVariant();
    }
}

void KcmsListModel::moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild)
{
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
    for (auto app : m_kcms) {
        m_appOrder << app.id;
        m_appPositions[app.id] = i;
        ++i;
    }

    emit appOrderChanged();
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
    for (auto app : m_appOrder) {
        m_appPositions[app] = i;
        ++i;
    }
    emit appOrderChanged();
}