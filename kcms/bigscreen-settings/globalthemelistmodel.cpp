
/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>         *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#include "globalthemelistmodel.h"
#include <KLocalizedString>
#include <KPackage/Package>
#include <KPackage/PackageLoader>
#include <QDir>
#include <QJsonObject>
#include <QProcess>

GlobalThemeListModel::GlobalThemeListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames.insert(PackageNameRole, "packageNameRole");
    m_roleNames.insert(PluginIdRole, "pluginIdRole");
    m_roleNames.insert(PackageDescriptionRole, "packageDescriptionRole");
    m_roleNames.insert(PreviewPathRole, "previewPathRole");

    reload();
    verifyPackage(QStringLiteral("org.kde.plasma.bigscreen"));
}

GlobalThemeListModel::~GlobalThemeListModel()
{
}

QHash<int, QByteArray> GlobalThemeListModel::roleNames() const
{
    return m_roleNames;
}

int GlobalThemeListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_themes.count();
}

QVariant GlobalThemeListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() >= m_themes.count()) {
        return QVariant();
    }

    const GlobalThemeInfo &theme = m_themes.at(index.row());
    switch (role) {
    case PackageNameRole:
        return theme.package;
    case PluginIdRole:
        return theme.pluginId;
    case PackageDescriptionRole:
        return theme.description;
    case PreviewPathRole:
        return theme.previewPath;
    default:
        return QVariant();
    }
}

QModelIndex GlobalThemeListModel::indexOf(const QString &path) const
{
    for (int i = 0; i < m_themes.count(); ++i) {
        if (m_themes.at(i).package == path) {
            return index(i, 0);
        }
    }

    return QModelIndex();
}

QVariantMap GlobalThemeListModel::get(int index) const
{
    QVariantMap map;
    if (index < 0 || index >= m_themes.count()) {
        return map;
    }

    const GlobalThemeInfo &theme = m_themes.at(index);
    map.insert("packageName", theme.package);
    map.insert("pluginId", theme.pluginId);
    map.insert("packageDescription", theme.description);
    map.insert("previewPath", theme.previewPath);

    return map;
}

void GlobalThemeListModel::reload()
{
    beginResetModel();
    m_themes.clear();

    const QList<KPluginMetaData> pkgs = KPackage::PackageLoader::self()->listPackages(QStringLiteral("Plasma/LookAndFeel"));

    for (const KPluginMetaData &pkg : pkgs) {
        GlobalThemeInfo info;
        info.package = pkg.name();
        info.pluginId = pkg.pluginId();
        info.description = pkg.description();
        info.previewPath = QUrl::fromLocalFile(packageForPluginId(info.pluginId).filePath("preview"));

        m_themes.append(info);
    }

    endResetModel();
}

KPackage::Package GlobalThemeListModel::packageForPluginId(const QString &pluginId) const
{
    return KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/LookAndFeel"), pluginId);
}

void GlobalThemeListModel::setTheme(const QString &pluginId)
{
    QProcess process;
    QStringList args;
    args << QStringLiteral("--apply") << pluginId;
    process.start(QStringLiteral("lookandfeeltool"), args);
    process.waitForFinished();

    if (process.exitCode() != 0) {
        qWarning() << "Failed to set theme: " << process.errorString();
    }

    Q_EMIT dataChanged(index(0, 0), index(m_themes.count() - 1, 0));
}

void GlobalThemeListModel::verifyPackage(const QString &packageName)
{
    KPackage::Package package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/Shell"));

    if (!packageName.isEmpty()) {
        package.setPath(packageName);
    }

    if (package.metadata().value(QStringLiteral("X-Plasma-APIVersion"), QStringLiteral("1")).toInt() >= 2) {
        qDebug() << "Package" << packageName << "is compatible with this version of Plasma";
    } else {
        qDebug() << "Package" << packageName << "is not compatible with this version of Plasma";
        qDebug() << package.metadata().value(QStringLiteral("X-Plasma-APIVersion"));
    }

    qDebug() << "Package" << packageName << package.filePath("lockscreenmainscript");

    // if (!package.filePath("lockscreenmainscript").contains(package.path()))
    // {
    //     qDebug() << "Package" << packageName << "does not contain the lockscreenmainscript";
    // }
    // else
    // {
    //     qDebug() << "Package" << packageName << "contains the lockscreenmainscript";
    // }
}