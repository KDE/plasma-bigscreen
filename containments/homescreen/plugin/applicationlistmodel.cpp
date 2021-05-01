/*
    SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Self
#include "applicationlistmodel.h"

// Qt
#include <QByteArray>
#include <QDebug>
#include <QModelIndex>
#include <QProcess>
#include <QRegularExpression>

// KDE
#include <KActivities/ResourceInstance>
#include <KConfigGroup>
#include <KIOWidgets/KRun>
#include <KService>
#include <KServiceGroup>
#include <KSharedConfig>
#include <KShell>
#include <KSycoca>
#include <KSycocaEntry>

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // can't use the new syntax as this signal is overloaded
    connect(KSycoca::self(), SIGNAL(databaseChanged(const QStringList &)), this, SLOT(sycocaDbChanged(const QStringList &)));
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

void ApplicationListModel::sycocaDbChanged(const QStringList &changes)
{
    if (!changes.contains("apps") && !changes.contains("xdgdata-apps")) {
        return;
    }

    m_applicationList.clear();
    m_voiceAppSkills.clear();

    loadApplications();
}

bool appNameLessThan(const ApplicationData &a1, const ApplicationData &a2)
{
    return a1.name.toLower() < a2.name.toLower();
}

QStringList ApplicationListModel::voiceAppSkills() const
{
    return m_voiceAppSkills;
}

void ApplicationListModel::loadApplications()
{
    auto cfg = KSharedConfig::openConfig("applications-blacklistrc");
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    // This is only temporary to get a clue what those apps' desktop files are called
    // I'll remove it once I've done a blacklist
    QStringList bl;

    QStringList blacklist = blgroup.readEntry("blacklist", QStringList());

    beginResetModel();

    m_applicationList.clear();

    KServiceGroup::Ptr group = KServiceGroup::root();
    if (!group || !group->isValid()) {
        return;
    }
    KServiceGroup::List subGroupList = group->entries(true);

    QMap<int, ApplicationData> orderedList;
    QList<ApplicationData> unorderedList;

    // Iterate over all entries in the group
    while (!subGroupList.isEmpty()) {
        KSycocaEntry::Ptr groupEntry = subGroupList.first();
        subGroupList.pop_front();

        if (groupEntry->isType(KST_KServiceGroup)) {
            KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup *>(groupEntry.data()));

            if (!serviceGroup->noDisplay()) {
                KServiceGroup::List entryGroupList = serviceGroup->entries(true);

                for (KServiceGroup::List::ConstIterator it = entryGroupList.constBegin(); it != entryGroupList.constEnd(); it++) {
                    KSycocaEntry::Ptr entry = (*it);

                    if (entry->isType(KST_KServiceGroup)) {
                        KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup *>(entry.data()));
                        subGroupList << serviceGroup;

                    } else if (entry->property("Exec").isValid()) {
                        qDebug() << entry->property("Categories");
                        KService::Ptr service(static_cast<KService *>(entry.data()));
                        qDebug() << " desktopEntryName: " << service->desktopEntryName();

                        // else if (entry->property("Exec").isValid()) {
                        //  KService::Ptr service(static_cast<KService* >(entry.data()));

                        //  qDebug() << " desktopEntryName: " << service->desktopEntryName();

                        if (service->isApplication() && !blacklist.contains(service->desktopEntryName()) && service->showOnCurrentPlatform()
                            && !service->property("Terminal", QVariant::Bool).toBool()) {
                            QRegularExpression voiceExpr(QStringLiteral("mycroft-gui-app .* --skill=(.*)\\.home"));

                            if (service->categories().contains(QStringLiteral("VoiceApp")) && voiceExpr.match(service->exec()).hasMatch()) {
                                QString exec = service->exec();
                                exec.replace(voiceExpr, QStringLiteral("\\1"));
                                if (!exec.isEmpty()) {
                                    m_voiceAppSkills << exec;
                                }
                            }

                            bl << service->desktopEntryName();

                            ApplicationData data;
                            data.name = service->name();
                            data.comment = service->comment();
                            data.icon = service->icon();
                            data.categories = service->categories();
                            data.storageId = service->storageId();
                            data.entryPath = service->exec();
                            data.desktopPath = service->entryPath();
                            data.startupNotify = service->property("StartupNotify").toBool();

                            auto it = m_appPositions.constFind(service->storageId());
                            if (it != m_appPositions.constEnd()) {
                                orderedList[*it] = data;
                            } else {
                                unorderedList << data;
                            }
                        }
                    }
                }
            }
        }
    }

    emit voiceAppSkillsChanged();

    blgroup.writeEntry("allapps", bl);
    blgroup.writeEntry("blacklist", blacklist);
    cfg->sync();

    std::sort(unorderedList.begin(), unorderedList.end(), appNameLessThan);
    m_applicationList << orderedList.values();
    m_applicationList << unorderedList;

    endResetModel();
    emit countChanged();
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
        return nullptr;
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

void ApplicationListModel::moveRow(const QModelIndex & /* sourceParent */, int sourceRow, const QModelIndex & /* destinationParent */, int destinationChild)
{
    moveItem(sourceRow, destinationChild);
}

Q_INVOKABLE void ApplicationListModel::moveItem(int row, int destination)
{
    if (row < 0 || destination < 0 || row >= m_applicationList.length() || destination >= m_applicationList.length() || row == destination) {
        return;
    }
    if (destination > row) {
        ++destination;
    }

    beginMoveRows(QModelIndex(), row, row, QModelIndex(), destination);
    if (destination > row) {
        ApplicationData data = m_applicationList.at(row);
        m_applicationList.insert(destination, data);
        m_applicationList.takeAt(row);
    } else {
        ApplicationData data = m_applicationList.takeAt(row);
        m_applicationList.insert(destination, data);
    }

    m_appOrder.clear();
    m_appPositions.clear();
    int i = 0;
    for (auto app : m_applicationList) {
        m_appOrder << app.storageId;
        m_appPositions[app.storageId] = i;
        ++i;
    }

    emit appOrderChanged();
    endMoveRows();
}

void ApplicationListModel::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    QProcess::startDetached(command);
}

void ApplicationListModel::runApplication(const QString &storageId)
{
    if (storageId.isEmpty()) {
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);

    KRun::runApplication(*service, QList<QUrl>(), nullptr);

    KActivities::ResourceInstance::notifyAccessed(QUrl(QStringLiteral("applications:") + service->storageId()), QStringLiteral("org.kde.plasma.kicker"));
}

QStringList ApplicationListModel::appOrder() const
{
    return m_appOrder;
}

void ApplicationListModel::setAppOrder(const QStringList &order)
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
