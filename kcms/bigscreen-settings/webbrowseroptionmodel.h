/*
    SPDX-FileCopyrightText: 2022 Méven Car <meven@kde.org>
    SPDX-FIleCopyrightText: 2026 User8395 <therealuser8395@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef APPLICATION_MODEL_H
#define APPLICATION_MODEL_H

#include <KService>
#include <QAbstractListModel>

class WebBrowserOptionModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit WebBrowserOptionModel(QObject *parent = nullptr);

    enum Roles {
        Icon = Qt::UserRole + 1, // TODO: make ComboBoxDelegate able to take icon roles
        StorageId = Qt::UserRole + 2
    };
    Q_ENUMS(Roles)
    
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int findByStorageId(const QString &storageId) const;
    void addApplication(const QString &name, const QString &iconName, const QString &storageId);

private:
    bool isValid(const QModelIndex &index) const;

    QList<QVariantMap> m_applications;
};

#endif // APPLICATION_MODEL_H
