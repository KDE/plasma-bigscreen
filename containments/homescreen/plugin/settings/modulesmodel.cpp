/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "modulesmodel.h"

#include <QQuickItem>
#include <QSet>

#include <KJsonUtils>
#include <KPluginFactory>
#include <KRuntimePlatform>

#include <QDebug>

using namespace Qt::Literals::StringLiterals;

ModulesModel::ModulesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    qDebug() << "Current platform is " << KRuntimePlatform::runtimePlatform();
    const auto kcms = KPluginMetaData::findPlugins(u"kcms"_s)
        << KPluginMetaData::findPlugins(u"plasma/kcms"_s) << KPluginMetaData::findPlugins(u"plasma/kcms/systemsettings"_s);
    for (const KPluginMetaData &pluginMetaData : kcms) {
        bool isCurrentPlatform = false;
        if (KRuntimePlatform::runtimePlatform().isEmpty()) {
            isCurrentPlatform = true;
        } else {
            const auto platforms = KRuntimePlatform::runtimePlatform();
            for (const QString &platform : platforms) {
                if (pluginMetaData.formFactors().contains(platform)) {
                    qDebug() << "Platform for " << pluginMetaData.name() << " is " << pluginMetaData.formFactors();
                    isCurrentPlatform = true;
                }
            }
        }
        if (isCurrentPlatform) {
            Data d;
            d.plugin = pluginMetaData;
            m_plugins.append(d);
        }
    }
    std::sort(m_plugins.begin(), m_plugins.end(), std::less<Data>());
}

QVariant ModulesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount()) {
        return {};
    }

    // NOTE: as the kcm is lazy loading, this needs to not be const
    // a cleaner alternative, would be a ConfigModule *loadKcm(pluginId) method, which also wouldn't risk erroneous kcm instantiation when it shouldn't
    Data &d = const_cast<ModulesModel *>(this)->m_plugins[index.row()];

    switch (role) {
    case NameRole:
        return d.plugin.name();
    case DescriptionRole:
        return d.plugin.description();
    case IconNameRole:
        return d.plugin.iconName();
    case IdRole:
        return d.plugin.pluginId();
    case KeywordsRole: {
        QStringList keywords;
        QJsonObject raw = d.plugin.rawData();
        // always include English keywords to make searching for words with accents easier
        keywords << raw.value(QLatin1String("X-KDE-Keywords")).toString().split(QLatin1String(","));
        keywords << KJsonUtils::readTranslatedString(raw, QStringLiteral("X-KDE-Keywords")).split(QLatin1String(","));
        return keywords;
    }
    case KcmRole: {
        if (!d.kcm) {
            d.kcm = KQuickConfigModuleLoader::loadModule(d.plugin, const_cast<ModulesModel *>(this)).plugin;
        }

        return QVariant::fromValue(d.kcm.data());
    }
    }

    return {};
}

int ModulesModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_plugins.size();
}

QHash<int, QByteArray> ModulesModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {DescriptionRole, "description"},
        {IconNameRole, "iconName"},
        {IdRole, "id"},
        {KcmRole, "kcm"},
    };
}