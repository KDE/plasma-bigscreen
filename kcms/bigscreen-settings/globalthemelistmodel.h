
/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>         *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#ifndef GLOBALTHEMELISTMODEL_H
#define GLOBALTHEMELISTMODEL_H

#include <KPackage/Package>
#include <QAbstractListModel>
#include <QObject>

class GlobalThemeInfo;
class GlobalThemeListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ThemeRoles {
        PackageNameRole = Qt::UserRole,
        PluginIdRole,
        PackageDescriptionRole,
        PreviewPathRole,
    };

    GlobalThemeListModel(QObject *parent = nullptr);
    ~GlobalThemeListModel() override;

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QModelIndex indexOf(const QString &path) const;
    void reload();
    KPackage::Package packageForPluginId(const QString &pluginId) const;

    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void setTheme(const QString &pluginId);

    Q_INVOKABLE void verifyPackage(const QString &packageName);

private:
    QHash<int, QByteArray> m_roleNames;
    QList<GlobalThemeInfo> m_themes;
};

class GlobalThemeInfo
{
public:
    QString package;
    QString pluginId;
    QString description;
    QUrl previewPath;
};

#endif // GLOBALTHEMELISTMODEL_H
