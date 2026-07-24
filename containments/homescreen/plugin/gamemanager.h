#ifndef GAMEMANAGER_H
#define GAMEMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <qcontainerfwd.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qtypes.h>

class GameManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit GameManager(QObject *parent = nullptr);
    static GameManager *instance();
    bool init();

    bool createTable();

    bool addGame(const QString &name,
                 const QString &command,
                 const QString &gridPath = "",
                 const QString &heroPath = "",
                 const QString &logoPath = "",
                 const qint64 totalHours = 0,
                 const qint64 lastPlayed = 0,
                 const QString &source = "");

    Q_INVOKABLE QVariantList getGames();

private:
    QSqlDatabase m_db;
};

#endif
