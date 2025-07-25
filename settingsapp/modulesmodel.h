/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QAbstractListModel>
#include <QVector>

#include <KPluginMetaData>
#include <KQuickConfigModule>

struct Data {
    KPluginMetaData plugin;
    QPointer<KQuickConfigModule> kcm;
    bool operator<(const Data &other) const
    {
        return plugin.name() < other.plugin.name();
    }
};

class ModulesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ModelRoles {
        NameRole = Qt::DisplayRole,
        IconNameRole = Qt::DecorationRole,
        DescriptionRole = Qt::UserRole + 1,
        IdRole = Qt::UserRole + 2,
        KeywordsRole = Qt::UserRole + 3,
        KcmRole,
    };

public:
    ModulesModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QHash<int, QByteArray> roleNames() const override;

private:
    QVector<Data> m_plugins;
};
