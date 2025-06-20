// SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "webappmanager.h"

#include <QImage>
#include <QStandardPaths>
#include <QStringBuilder>

#include <KConfigGroup>
#include <KDesktopFile>
#include <KSandbox>

const QString USERAGENT_CFG_KEY = QStringLiteral("X-KDE-Bigscreen-UserAgent");

WebAppManager::WebAppManager(QObject *parent)
    : QObject(parent)
    , m_desktopFileDirectory(desktopFileDirectory())
{
    const auto fileInfos = m_desktopFileDirectory.entryInfoList(QDir::Files);

    // Likely almost all files in the directory are webapps, so this should be worth it
    m_webApps.reserve(fileInfos.size());

    for (const auto &file : fileInfos) {
        // Make sure to only parse desktop files
        if (file.fileName().contains(QStringView(u".desktop"))) {
            KDesktopFile desktopFile(file.filePath());

            auto configGroup = desktopFile.group(QStringLiteral("Desktop Entry"));

            // Only handle desktop files referencing plasma-bigscreen
            if (configGroup.readEntry("Exec").contains(QStringView(u"plasma-bigscreen-webapp"))) {
                auto userAgent = configGroup.readEntry(USERAGENT_CFG_KEY);
                WebApp app{desktopFile.readName(), desktopFile.readIcon(), desktopFile.readUrl(), userAgent};

                m_webApps.push_back(std::move(app));
            }
        }
    }
}

QString WebAppManager::desktopFileDirectory()
{
    auto dir = []() -> QString {
        if (KSandbox::isFlatpak()) {
            return qEnvironmentVariable("HOME") % u"/.local/share/applications/";
        }
        return QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    }();

    QDir(dir).mkpath(QStringLiteral("."));

    return dir;
}

QString WebAppManager::iconDirectory()
{
    auto dir = []() -> QString {
        if (KSandbox::isFlatpak()) {
            return qEnvironmentVariable("HOME") % u"/.local/share/icons/hicolor/16x16/apps/";
        }
        return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + QStringLiteral("/icons/hicolor/16x16/apps/");
    }();
    QDir(dir).mkpath(QStringLiteral("."));

    return dir;
}

const std::vector<WebApp> &WebAppManager::applications() const
{
    return m_webApps;
}

void WebAppManager::addApp(const QString &name, const QString &url, const QImage &icon, const QString &userAgent)
{
    const QString filename = generateFileName(name);
    const QString desktopFileName = generateDesktopFileName(name);

    icon.save(iconDirectory() % QDir::separator() % filename % u".png", "PNG");
    KConfig desktopFile(desktopFileDirectory() % QDir::separator() % desktopFileName, KConfig::SimpleConfig);

    // TODO: maybe have program read options from .desktop file?
    // Currently, the user can inject and break the launch command
    QString exec = webAppCommand() + " --name \"" + name + "\"";
    if (!userAgent.isEmpty()) {
        exec += " --agent \"" + userAgent + "\"";
    }
    exec += " \"" + url + "\"";

    auto desktopEntry = desktopFile.group(QStringLiteral("Desktop Entry"));
    desktopEntry.writeEntry(QStringLiteral("Type"), QStringLiteral("Application"));
    desktopEntry.writeEntry(QStringLiteral("URL"), url);
    desktopEntry.writeEntry(QStringLiteral("Name"), name);
    desktopEntry.writeEntry(QStringLiteral("Exec"), exec);
    desktopEntry.writeEntry(QStringLiteral("Icon"), filename);
    desktopEntry.writeEntry(USERAGENT_CFG_KEY, userAgent);

    m_webApps.push_back(WebApp{name, filename, url, userAgent});

    desktopFile.sync();

    Q_EMIT applicationsChanged();
}

bool WebAppManager::exists(const QString &name)
{
    const QString location = desktopFileDirectory();
    const QString filename = generateDesktopFileName(name);

    return QFile::exists(location % QDir::separator() % filename);
}

bool WebAppManager::removeApp(const QString &name)
{
    const QString location = desktopFileDirectory();
    const QString filename = generateDesktopFileName(name);

    auto it = std::remove_if(m_webApps.begin(), m_webApps.end(), [&name](const WebApp &app) {
        return app.name == name;
    });

    m_webApps.erase(it);

    bool success = QFile::remove(location % QDir::separator() % filename);
    Q_EMIT applicationsChanged();
    return success;
}

WebAppManager &WebAppManager::instance()
{
    static WebAppManager instance;
    return instance;
}

QString WebAppManager::generateFileName(const QString &name)
{
    QString filename = name.toLower();
    filename.replace(QChar(u' '), QChar(u'_'));
    filename.remove(u'/');
    filename.remove(u'"');
    filename.remove(u'\'');
    filename.remove(u',');
    filename.remove(u'.');
    filename.remove(u'|');
    return filename;
}

QString WebAppManager::generateDesktopFileName(const QString &name)
{
    return generateFileName(name) % u".desktop";
}

QString WebAppManager::webAppCommand()
{
    return QStringLiteral("plasma-bigscreen-webapp");
}

#include "moc_webappmanager.cpp"
