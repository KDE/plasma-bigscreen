#include "gamemanager.h"
#include <QDebug>
#include <QVariantList>
#include <QVariantMap>
#include <QtSql/QSqlError>
#include <QtSql/qsqldatabase.h>
#include <QtSql/qsqlquery.h>
#include <qcontainerfwd.h>
#include <qdir.h>
#include <qlogging.h>
#include <qobject.h>
#include <qstandardpaths.h>

GameManager::GameManager(QObject *parent)
    : QObject(parent)
{
    if (init()) {
        createTable();
    }
}

GameManager *GameManager::instance()
{
    static GameManager *s_instance = new GameManager();
    return s_instance;
}

bool GameManager::init()
{
    QString basePath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);

    QString dbFolder = basePath + "/plasma-bigscreen-games";
    qWarning() << "DATABASE IS LOCATED AT:" << dbFolder;

    QDir dir;
    if (!dir.exists(dbFolder)) {
        dir.mkpath(dbFolder);
    }

    m_db = QSqlDatabase::addDatabase("QSQLITE", "BigScreenGamesConnection");
    m_db.setDatabaseName(dbFolder + "/games.db");

    return m_db.open();
}

bool GameManager::createTable()
{
    QSqlQuery query(m_db);
    QString mySqlString =
        "CREATE TABLE IF NOT EXISTS games"
        "("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT,"
        "grid_path TEXT,"
        "hero_path TEXT,"
        "logo_path TEXT,"
        "total_hour INTEGER,"
        "last_played INTEGER,"
        "source TEXT,"
        "command TEXT"
        ")";
    return query.exec(mySqlString);
}

bool GameManager::addGame(const QString &name,
                          const QString &command,
                          const QString &gridPath,
                          const QString &heroPath,
                          const QString &logoPath,
                          const qint64 totalHours,
                          const qint64 lastPlayed,
                          const QString &source)
{
    QSqlQuery query(m_db);

    query.prepare(
        "INSERT INTO games (name,grid_path,hero_path,logo_path,total_hour,last_played,source,command)"
        "VALUES (:name,:grid,:hero,:logo,:hour,:lastplayed,:source,:cmd)");
    query.bindValue(":name", name);
    query.bindValue(":cmd", command);

    query.bindValue(":grid", gridPath.isEmpty() ? QVariant() : gridPath);
    query.bindValue(":hero", heroPath.isEmpty() ? QVariant() : heroPath);
    query.bindValue(":logo", logoPath.isEmpty() ? QVariant() : logoPath);
    query.bindValue(":source", source.isEmpty() ? QVariant() : source);

    query.bindValue(":hour", totalHours);
    query.bindValue(":lastplayed", lastPlayed);

    if (!query.exec()) {
        qWarning() << "Failed to add game to database!" << query.lastError().text();
        return false;
    }
    return true;
}

QVariantList GameManager::getGames()
{
    QVariantList gameList;
    QSqlQuery query(m_db);
    qWarning() << "DB Call Happening";
    if (!query.exec("SELECT * FROM games")) {
        qWarning() << "Failed to fetch game from database!" << query.lastError().text();
        return gameList;
    }

    while (query.next()) {
        QVariantMap game;

        game["id"] = query.value("id").toInt();
        game["name"] = query.value("name").toString();
        game["grid_path"] = query.value("grid_path").toString();
        game["hero_path"] = query.value("hero_path").toString();
        game["logo_path"] = query.value("logo_path").toString();
        game["total_hour"] = query.value("total_hour").toLongLong();
        game["last_played"] = query.value("last_played").toLongLong();
        game["source"] = query.value("source").toString();
        game["command"] = query.value("command").toString();
        qWarning() << "Game from DB : " << game;
        gameList.append(game);
    }
    return gameList;
}