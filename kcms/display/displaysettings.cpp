/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <KPluginFactory>
#include <KQuickConfigModule>
#include "displaysettings.h"
#include "displaymodel.h"

DisplaySettings::DisplaySettings(QObject *parent, const KPluginMetaData &data)
    : KQuickConfigModule(parent, data),
      m_displayModel(new DisplayModel(this))
{
    setButtons(Apply | Default);
    qmlRegisterAnonymousType<DisplayModel>("DisplayModel", 1);
}

DisplayModel *DisplaySettings::displayModel()
{
    return m_displayModel;
}

K_PLUGIN_CLASS_WITH_JSON(DisplaySettings, "kcm_mediacenter_display.json")

#include "displaysettings.moc"
