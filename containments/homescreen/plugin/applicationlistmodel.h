/*
    SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QSortFilterProxyModel>

#include <KService>

QStringList applicationsBlacklist();
bool isApplicationBlacklisted(const KService::Ptr &service, const QStringList &blacklist);

namespace TaskManager
{
class TasksModel;
}

struct ApplicationData {
    QString name;
    QString comment;
    QString icon;
    QStringList categories;
    QString storageId;
    QString entryPath;
    QString desktopPath;
    bool startupNotify = true;
};

class ApplicationListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    ApplicationListModel(QObject *parent = nullptr);
    ~ApplicationListModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override;

    enum Roles {
        ApplicationNameRole = Qt::UserRole + 1,
        ApplicationCommentRole,
        ApplicationIconRole,
        ApplicationCategoriesRole,
        ApplicationStorageIdRole,
        ApplicationEntryPathRole,
        ApplicationDesktopRole,
        ApplicationStartupNotifyRole,
        ApplicationOriginalRowRole
    };
    Q_ENUM(Roles)

    void loadApplications();

public Q_SLOTS:
    void sycocaDbChanged();

Q_SIGNALS:
    void applicationRemoved(const QString &storageId);

private:
    KService::List queryApplications();

    QList<ApplicationData> m_applicationList;
};

class ApplicationListSearchModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    ApplicationListSearchModel(QObject *parent = nullptr, ApplicationListModel *model = nullptr);

    Q_INVOKABLE void runApplication(const QString &storageId);
    Q_INVOKABLE bool isApplicationBlocklisted(const QString &storageId) const;
    Q_INVOKABLE bool isApplicationRunning(const QString &storageId) const;
    Q_INVOKABLE void maximizeApplication(const QString &storageId);
    Q_INVOKABLE QVariantMap itemMap(int index);

private:
    TaskManager::TasksModel *m_tasksModel = nullptr;
};
