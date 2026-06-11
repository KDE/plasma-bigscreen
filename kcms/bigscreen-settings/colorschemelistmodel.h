/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>         *
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>                *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QObject>

class ColorSchemeInfo;

class ColorSchemeListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ColorSchemeRoles {
        PackageNameRole = Qt::UserRole,
        SchemeNameRole,
        WindowColorRole,
        TextColorRole,
        ButtonColorRole,
        HighlightColorRole,
        HighlightedTextColorRole,
        ActiveTitleBarBackgroundRole,
        ActiveTitleBarForegroundRole,
    };

    ColorSchemeListModel(QObject *parent = nullptr);
    ~ColorSchemeListModel() override;

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QModelIndex indexOf(const QString &schemeName) const;
    void reload();

    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void setColorScheme(const QString &schemeName);

Q_SIGNALS:
    void colorSchemeChanged();

private:
    QHash<int, QByteArray> m_roleNames;
    QList<ColorSchemeInfo> m_colorSchemes;
};

class ColorSchemeInfo
{
public:
    QString package;
    QString schemeName;
    QColor windowColor;
    QColor textColor;
    QColor buttonColor;
    QColor highlightColor;
    QColor highlightedTextColor;
    QColor activeTitleBarBackground;
    QColor activeTitleBarForeground;
};
