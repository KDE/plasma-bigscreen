/*
    SPDX-FileCopyrightText: 2014 David Rosca <nowrep@gmail.com>
    SPDX-FileCopyrightText: 2025 User8935 <therealuser8395@proton.me>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

#pragma once

#include <BluezQt/DevicesModel>
#include <QSortFilterProxyModel>

#include <qqmlregistration.h>

class DevicesProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool hideBlockedDevices READ hideBlockedDevices WRITE setHideBlockedDevices NOTIFY hideBlockedDevicesChanged FINAL)
    Q_PROPERTY(bool pairedOnly READ pairedOnly WRITE setPairedOnly)
    Q_PROPERTY(int count READ rowCount NOTIFY rowCountChanged)

public:
    enum AdditionalRoles {
        SectionRole = BluezQt::DevicesModel::LastRole + 10,
        DeviceFullNameRole = BluezQt::DevicesModel::LastRole + 11,

        LastRole = DeviceFullNameRole,
    };

    explicit DevicesProxyModel(QObject *parent = nullptr);

    bool hideBlockedDevices() const;
    void setHideBlockedDevices(bool Hide);

    bool pairedOnly() const;
    void setPairedOnly(bool pairedOnly);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    Q_INVOKABLE static QString adapterHciString(const QString &ubi);

Q_SIGNALS:
    void hideBlockedDevicesChanged();
    void rowCountChanged();

private:
    bool duplicateIndexAddress(const QModelIndex &idx) const;

    bool m_hideBlockedDevices = false;
    bool m_pairedOnly = false;
};
