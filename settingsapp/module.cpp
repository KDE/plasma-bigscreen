/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "module.h"

#include <KPluginFactory>

KQuickConfigModule *Module::kcm() const
{
    return m_kcm;
}

QString Module::path() const
{
    return m_path;
}

void Module::setPath(const QString &path)
{
    if (m_path == path) {
        return;
    }

    // In case the user clicks from the UI we pass in the absolute path
    KPluginMetaData kcmMetaData(path);
    if (KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/") + path); data.isValid()) {
        kcmMetaData = data;
    }

    // if (kcmMetaData.isValid()) {
    m_path = kcmMetaData.fileName();
    Q_EMIT pathChanged();

    m_kcm = KQuickConfigModuleLoader::loadModule(kcmMetaData, this).plugin;
    Q_EMIT kcmChanged();
    Q_EMIT nameChanged();

    m_valid = true;
    Q_EMIT validChanged();
    // } else {
    //     qWarning() << "Unknown module" << path << "requested";
    //     m_valid = false;
    //     Q_EMIT validChanged();
    // }
}

bool Module::valid()
{
    return m_valid;
}