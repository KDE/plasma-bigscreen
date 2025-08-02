/*
    SPDX-FileCopyrightText: 2014-2015 David Rosca <nowrep@gmail.com>
    SPDX-FileCopyrightText: 2025 User8935 <therealuser8395@proton.me>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

#include "devicesproxymodel.h"

#include <BluezQt/Adapter>
#include <BluezQt/Device>

DevicesProxyModel::DevicesProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    sort(0, Qt::DescendingOrder);
}

bool DevicesProxyModel::hideBlockedDevices() const
{
    return m_hideBlockedDevices;
}

void DevicesProxyModel::setHideBlockedDevices(bool shouldHide)
{
    if (m_hideBlockedDevices != shouldHide) {
        m_hideBlockedDevices = shouldHide;

        invalidateFilter();

        Q_EMIT hideBlockedDevicesChanged();
    }
}

bool DevicesProxyModel::pairedOnly() const
{
    return m_pairedOnly;
}

void DevicesProxyModel::setPairedOnly(bool pairedOnly)
{
    if (m_pairedOnly != pairedOnly) {
        m_pairedOnly = pairedOnly;
        invalidateFilter();
    }
}

QHash<int, QByteArray> DevicesProxyModel::roleNames() const
{
    QHash<int, QByteArray> roles = QSortFilterProxyModel::roleNames();
    roles[SectionRole] = QByteArrayLiteral("Section");
    roles[DeviceFullNameRole] = QByteArrayLiteral("DeviceFullName");
    return roles;
}

QVariant DevicesProxyModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case SectionRole:
        if (index.data(BluezQt::DevicesModel::PairedRole).toBool()) {
            return QStringLiteral("Paired");
        }
        return QStringLiteral("Available");

    case DeviceFullNameRole:
        if (duplicateIndexAddress(index)) {
            const QString &name = QSortFilterProxyModel::data(index, BluezQt::DevicesModel::NameRole).toString();
            const QString &ubi = QSortFilterProxyModel::data(index, BluezQt::DevicesModel::UbiRole).toString();
            const QString &hci = adapterHciString(ubi);

            if (!hci.isEmpty()) {
                return QStringLiteral("%1 - %2").arg(name, hci);
            }
        }
        return QSortFilterProxyModel::data(index, BluezQt::DevicesModel::NameRole);

    default:
        return QSortFilterProxyModel::data(index, role);
    }
}

bool DevicesProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    bool leftBlocked = left.data(BluezQt::DevicesModel::BlockedRole).toBool();
    bool rightBlocked = right.data(BluezQt::DevicesModel::BlockedRole).toBool();

    // Blocked are checked first, but they go last.
    if (!leftBlocked && rightBlocked) {
        return false;
    } else if (leftBlocked && !rightBlocked) {
        return true;
    }

    bool leftConnected = left.data(BluezQt::DevicesModel::ConnectedRole).toBool();
    bool rightConnected = right.data(BluezQt::DevicesModel::ConnectedRole).toBool();

    // Conencted go above disconnected but available (not blocked)
    if (!leftConnected && rightConnected) {
        return true;
    } else if (leftConnected && !rightConnected) {
        return false;
    }

    const QString &leftName = left.data(BluezQt::DevicesModel::NameRole).toString();
    const QString &rightName = right.data(BluezQt::DevicesModel::NameRole).toString();

    return QString::localeAwareCompare(leftName, rightName) > 0;
}

bool DevicesProxyModel::duplicateIndexAddress(const QModelIndex &idx) const
{
    const QModelIndexList &list = match(index(0, 0), //
                                        BluezQt::DevicesModel::AddressRole,
                                        idx.data(BluezQt::DevicesModel::AddressRole).toString(),
                                        2,
                                        Qt::MatchExactly);
    return list.size() > 1;
}

bool DevicesProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    const QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
    const QString name = sourceModel()->data(index, BluezQt::DevicesModel::NameRole).toString();
    const QString address = sourceModel()->data(index, BluezQt::DevicesModel::AddressRole).toString().replace(QLatin1Char(':'), QLatin1Char('-'));
    if (m_pairedOnly) {
        return !(name == address) && sourceModel()->data(index, BluezQt::DevicesModel::PairedRole).toBool();
    } else {
        return !(name == address) && !sourceModel()->data(index, BluezQt::DevicesModel::PairedRole).toBool();
    }
    return !(name == address);
}

QString DevicesProxyModel::adapterHciString(const QString &ubi)
{
    int startIndex = ubi.indexOf(QLatin1String("/hci")) + 1;

    if (startIndex < 1) {
        return QString();
    }

    int endIndex = ubi.indexOf(QLatin1Char('/'), startIndex);

    if (endIndex == -1) {
        return ubi.mid(startIndex);
    }
    return ubi.mid(startIndex, endIndex - startIndex);
}

#include "moc_devicesproxymodel.cpp"
