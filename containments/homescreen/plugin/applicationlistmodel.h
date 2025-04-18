/*
    SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef APPLICATIONLISTMODEL_H
#define APPLICATIONLISTMODEL_H

// Qt
#include <QAbstractListModel>
#include <QList>
#include <QObject>

class QString;

struct ApplicationData {
    QString name;
    QString comment;
    QString icon;
    QStringList categories;
    QString storageId;
    QString entryPath;
    QString desktopPath;
    bool startupNotify = true;
};

class ApplicationListModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QStringList appOrder READ appOrder WRITE setAppOrder NOTIFY appOrderChanged)
    Q_PROPERTY(QStringList voiceAppSkills READ voiceAppSkills NOTIFY voiceAppSkillsChanged)

public:
    ApplicationListModel(QObject *parent = nullptr);
    ~ApplicationListModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    void moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild);

    int count()
    {
        return m_applicationList.count();
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override;

    QStringList voiceAppSkills() const;

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
    Q_ENUM(Roles)

    QStringList appOrder() const;
    void setAppOrder(const QStringList &order);

    Q_INVOKABLE void moveItem(int row, int order);
    Q_INVOKABLE void runApplication(const QString &storageId);
    Q_INVOKABLE void loadApplications();
    Q_INVOKABLE void executeCommand(const QString &command);
    Q_INVOKABLE QVariantMap itemMap(int index);
    
public Q_SLOTS:
    void sycocaDbChanged();

Q_SIGNALS:
    void countChanged();
    void appOrderChanged();
    void voiceAppSkillsChanged();

private:
    QStringList m_voiceAppSkills;
    QList<ApplicationData> m_applicationList;

    QStringList m_appOrder;
    QHash<QString, int> m_appPositions;
};

#endif // APPLICATIONLISTMODEL_H
