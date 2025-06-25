// SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QAbstractListModel>
#include <QDBusArgument>
#include <QProcess>

#include <kscreen/config.h>
#include <kscreen/output.h>

class DisplayModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int selectedDisplayId READ selectedDisplayId WRITE setSelectedDisplayId NOTIFY selectedDisplayChanged)
    Q_PROPERTY(QString selectedDisplayName READ selectedDisplayName NOTIFY selectedDisplayChanged)
    Q_PROPERTY(bool selectedDisplayEnabled READ selectedDisplayEnabled WRITE setSelectedDisplayEnabled NOTIFY selectedDisplayChanged)
    Q_PROPERTY(double selectedDisplayScale READ selectedDisplayScale WRITE setSelectedDisplayScale NOTIFY selectedDisplayChanged)
    Q_PROPERTY(QStringList selectedDisplayAvailableModes READ selectedDisplayAvailableModes NOTIFY selectedDisplayChanged)
    Q_PROPERTY(QString selectedDisplayMode READ selectedDisplayMode WRITE setSelectedDisplayMode NOTIFY selectedDisplayChanged)

public:
    enum DisplayRoles {
        IdRole = Qt::UserRole + 1,
        OutputNameRole = Qt::UserRole + 2,
        EnabledRole = Qt::UserRole + 3,
        OutputRole = Qt::UserRole + 4,
    };
    Q_ENUM(DisplayRoles);

    DisplayModel(QObject *parent = nullptr);
    ~DisplayModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    KScreen::OutputPtr selectedDisplay() const;
    int selectedDisplayId() const;
    void setSelectedDisplayId(int id);

    QString selectedDisplayName() const;

    bool selectedDisplayEnabled() const;
    void setSelectedDisplayEnabled(bool enabled);

    double selectedDisplayScale() const;
    void setSelectedDisplayScale(double scale);

    QStringList selectedDisplayAvailableModes() const;
    QString selectedDisplayMode() const;
    void setSelectedDisplayMode(const QString &modeName);

    Q_INVOKABLE void syncDisplayOptions();

Q_SIGNALS:
    void countChanged();
    void displayConfigurationChanged();
    void displayScaleChanged();
    void selectedDisplayChanged();

private:
    void loadDisplayInformation();
    QList<KScreen::OutputPtr> m_displays;
    QHash<int, QByteArray> m_roleNames;

    KScreen::ConfigPtr m_config;

    int m_selectedDisplayId = -1;
};

