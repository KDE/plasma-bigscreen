/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef FAVSLISTMODEL_H
#define FAVSLISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QObject>

class FavsManager : public QObject
{
    Q_OBJECT

public:
    static FavsManager* instance();
    ~FavsManager() override;
    bool isFav(const QString &storageId, const QString &entryPath);
    QList<QVariantMap> favsList();
    
public Q_SLOTS:
    void addFav(QVariantMap fav);
    void removeFav(QVariantMap fav);
    void moveFav(QVariantMap fav, int destinationIndex);
    void clearFavs();

Q_SIGNALS:
    void favOrderChanged();
    void favsCleared();
    void favsListChanged();

private:
    explicit FavsManager(QObject *parent = nullptr);
    QList<QVariantMap> m_favsList;
    void saveFavsList();
    void loadFavsList();
};

class FavsListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    FavsListModel(FavsManager *favsManager, QObject *parent = nullptr);
    ~FavsListModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;
    void moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild);
    int count();
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    void resetModel();
    Q_INVOKABLE QVariantMap itemMap(int index);

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

Q_SIGNALS:
    void countChanged();

private:
    FavsManager *m_favsManager;
};

#endif // FAVSLISTMODEL_H