// SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "displaymodel.h"

#include <QDBusMessage>
#include <QDBusConnection>
#include <QDBusArgument>
#include <QProcess>

DisplayModel::DisplayModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames.insert(IdRole, "id");
    m_roleNames.insert(OutputNameRole, "outputName");
    m_roleNames.insert(ConnectedRole, "connected");
    m_roleNames.insert(EnabledRole, "enabled");
    m_roleNames.insert(CurrentModeIdRole, "currentModeId");
    m_roleNames.insert(SizeRole, "size");
    m_roleNames.insert(ScaleRole, "scale");
    m_roleNames.insert(ModesRole, "modes");

    loadDisplayInformation();
}

DisplayModel::~DisplayModel()
{
}


int DisplayModel::rowCount(const QModelIndex &) const
{
    return m_displays.size();
}

QVariant DisplayModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() >= m_displays.size()) {
        return QVariant();
    }

    const QVariantMap &display = m_displays.at(index.row());

    switch (role) {
    case IdRole:
        return display.value(QStringLiteral("id"));
    case OutputNameRole:
        return display.value(QStringLiteral("outputName"));
    case ConnectedRole:
        return display.value(QStringLiteral("connected"));
    case EnabledRole:
        return display.value(QStringLiteral("enabled"));
    case CurrentModeIdRole:
        return display.value(QStringLiteral("currentModeId"));
    case SizeRole:
        return display.value(QStringLiteral("size"));
    case ScaleRole:
        return display.value(QStringLiteral("scale"));
    case ModesRole:
        return display.value(QStringLiteral("modes"));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> DisplayModel::roleNames() const
{
    return m_roleNames;
}

void DisplayModel::loadDisplayInformation()
{
    beginResetModel();
    m_displays.clear();

    QDBusConnection m_dbusConnection = QDBusConnection::sessionBus();
    QDBusMessage message = QDBusMessage::createMethodCall(QStringLiteral("org.kde.KScreen"),
                                                          QStringLiteral("/backend"),
                                                          QStringLiteral("org.kde.kscreen.Backend"),
                                                          QStringLiteral("getConfig"));



    QDBusMessage reply = m_dbusConnection.call(message);

     if (reply.type() == QDBusMessage::ReplyMessage) {
        QDBusArgument dbusArg = reply.arguments().at(0).value<QDBusArgument>();
        QVariantMap config;
        dbusArg >> config;

        QDBusArgument outputsArg = config.value(QStringLiteral("outputs")).value<QDBusArgument>();
        outputsArg.beginArray();
        QList<QVariant> outputs;
        while (!outputsArg.atEnd()) {
            QVariant output;
            outputsArg >> output;
            outputs.append(output);
        }
        outputsArg.endArray();

        for (const QVariant &output : outputs) {
            QDBusArgument outputArg = output.value<QDBusArgument>();
            QVariantMap outputMap;
            outputArg >> outputMap;

            QVariantMap display;
            display.insert(QStringLiteral("id"), outputMap.value(QStringLiteral("id")));
            display.insert(QStringLiteral("outputName"), outputMap.value(QStringLiteral("name")));
            display.insert(QStringLiteral("connected"), outputMap.value(QStringLiteral("connected")));
            display.insert(QStringLiteral("enabled"), outputMap.value(QStringLiteral("enabled")));
            display.insert(QStringLiteral("currentModeId"), outputMap.value(QStringLiteral("currentModeId")));
            display.insert(QStringLiteral("size"), deserializeMap(outputMap.value(QStringLiteral("size")).value<QDBusArgument>()));
            display.insert(QStringLiteral("scale"), outputMap.value(QStringLiteral("scale")));
            display.insert(QStringLiteral("modes"), deserializeMapsList(outputMap.value(QStringLiteral("modes")).value<QDBusArgument>()));

            m_displays.append(display);
        }

        endResetModel();
        Q_EMIT countChanged();
    }
}

Q_INVOKABLE void DisplayModel::refresh()
{
    loadDisplayInformation();
    Q_EMIT dataChanged(index(0), index(m_displays.size() - 1));
}

QVariantMap DisplayModel::deserializeMap(QDBusArgument arg) {
    QVariantMap serialMap;
    arg >> serialMap;
    return serialMap;
}

QVariantList DisplayModel::deserializeMapsList(QDBusArgument arg)
{
    QVariantList mapsList;
    arg >> mapsList;

    for (int i = 0; i < mapsList.size(); i++) {
        QDBusArgument map = mapsList.at(i).value<QDBusArgument>();
        mapsList.replace(i, deserializeMap(map));
    }

    for (int i = 0; i < mapsList.size(); i++) {
        QVariantMap map = mapsList.at(i).toMap();
        QDBusArgument size = map.value(QStringLiteral("size")).value<QDBusArgument>();
        map.insert(QStringLiteral("size"), deserializeMap(size));
        mapsList.replace(i, map);
    }

    QVariantList displayList;
    for (int i = 0; i < mapsList.size(); i++) {
        QVariantMap map = mapsList.at(i).toMap();
        QString id = map.value(QStringLiteral("id")).toString();
        QVariantMap size = map.value(QStringLiteral("size")).toMap();
        int refreshRateRound = qRound(map.value(QStringLiteral("refreshRate")).toDouble());
        QString displayText = id + ": " + size.value(QStringLiteral("width")).toString() + "x" + size.value(QStringLiteral("height")).toString() + "*" + QString::number(refreshRateRound);
        QVariantMap display;
        display.insert(QStringLiteral("id"), id);
        display.insert(QStringLiteral("displayText"), displayText);
        display.insert(QStringLiteral("refreshRate"), refreshRateRound);
        displayList.append(display);
    }

    return displayList;
}

void DisplayModel::setResolutionConfiguration(int modeId, const QString &outputName)
{
    QProcess process;
    QString startProcess = QStringLiteral("kscreen-doctor");
    QStringList arguments;
    arguments << QStringLiteral("output.") + outputName + QStringLiteral(".mode.") + QString::number(modeId);
    process.startCommand(startProcess + " " + arguments.join(" "));
    process.waitForFinished();
    refresh();
    Q_EMIT displayConfigurationChanged();
}

void DisplayModel::setScaleConfiguration(qreal scale, const QString &outputName)
{
    QProcess process;
    QString startProcess = QStringLiteral("kscreen-doctor");
    QStringList arguments;
    arguments << QStringLiteral("output.") + outputName + QStringLiteral(".scale.") + QString::number(scale);
    process.startCommand(startProcess + " " + arguments.join(" "));
    process.waitForFinished();
    refresh();
    Q_EMIT displayScaleChanged();
}

QString DisplayModel::getCurrentRefreshRate(int currentModeId)
{
    for (const QMap<QString, QVariant> &display : std::as_const(m_displays)) {
        QVariantList modes = display.value(QStringLiteral("modes")).toList();
        for (const QVariant &mode : std::as_const(modes)) {
            QVariantMap modeMap = mode.toMap();
            if (modeMap.value(QStringLiteral("id")).toInt() == currentModeId) {
                return QString::number(qRound(modeMap.value(QStringLiteral("refreshRate")).toDouble()));
            }
        }
    }

    return QStringLiteral("0");
}