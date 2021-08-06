/*
 * ThemeListModel
 * SPDX-FileCopyrightText: 2002 Karol Szwed <gallium@kde.org>
 * SPDX-FileCopyrightText: 2002 Daniel Molkentin <molkentin@kde.org>
 * SPDX-FileCopyrightText: 2007 Urs Wolfer <uwolfer @ kde.org>
 * SPDX-FileCopyrightText: 2009 Davide Bettio <davide.bettio@kdemail.net>
 * SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

 * Portions SPDX-FileCopyrightText: 2007 Paolo Capriotti <p.capriotti@gmail.com>
 * Portions SPDX-FileCopyrightText: 2007 Ivan Cukic <ivan.cukic+kde@gmail.com>
 * Portions SPDX-FileCopyrightText: 2008 Petri Damsten <damu@iki.fi>
 * Portions SPDX-FileCopyrightText: 2000 TrollTech AS.
 *
 * SPDX-License-Identifier: GPL-2.0-only
 */

#ifndef THEMELISTMODEL_H
#define THEMELISTMODEL_H

#include <QAbstractListModel>

namespace Plasma
{
class FrameSvg;
}

// Theme selector code by Andre Duffeck (modified to add package description)
class ThemeInfo
{
public:
    QString package;
    QString pluginName;
    QString description;
    QString author;
    QString version;
    QString themeRoot;
    QString type;
};

class ThemeListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum { PackageNameRole = Qt::UserRole, PluginNameRole = Qt::UserRole + 1, PackageDescriptionRole = Qt::UserRole + 2, PackageAuthorRole = Qt::UserRole + 3, PackageVersionRole = Qt::UserRole + 4, ColorTypeRole =  Qt::UserRole + 5 };

    enum ColorType {
        LightTheme,
        DarkTheme,
        FollowsColorTheme,
    };

    ThemeListModel(QObject *parent = nullptr);
    ~ThemeListModel() override;

    QHash<int, QByteArray> roleNames() const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QModelIndex indexOf(const QString &path) const;
    void reload();
    void clearThemeList();

    Q_INVOKABLE QVariantMap get(int index) const;

private:
    QHash<int, QByteArray> m_roleNames;

    QMap<QString, ThemeInfo> m_themes;
};

#endif
