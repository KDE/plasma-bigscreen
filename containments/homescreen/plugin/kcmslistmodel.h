/*
    SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef KCMSLISTMODEL_H
#define KCMSLISTMODEL_H

#include <KPluginMetaData>
#include <QAbstractListModel>

#include "configuration.h"
#include <QList>
#include <QObject>

class QString;

struct KcmData {
    QString name;
    QString description;
    QString iconName;
    QString id;
    QString path;
};

class KcmsListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles { KcmIdRole = Qt::UserRole + 1, KcmIconNameRole, KcmDescriptionRole, KcmNameRole, KcmRole, KcmPathRole};
    Q_ENUM(Roles)

    KcmsListModel(QObject *parent = nullptr);
    ~KcmsListModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild);

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    Q_INVOKABLE void moveItem(int row, int destination);
    Q_INVOKABLE void loadKcms();

    QHash<int, QByteArray> roleNames() const override;

    int count() const;

    QStringList appOrder() const;
    void setAppOrder(const QStringList &order);

    Q_INVOKABLE QVariantMap get(int index) const;

Q_SIGNALS:
    void countChanged();
    void appOrderChanged();

private:
    QList<KcmData> m_kcms;

    QStringList m_appOrder;
    QHash<QString, int> m_appPositions;

    Configuration m_configuration;
};

#endif // KCMSLISTMODEL_H
