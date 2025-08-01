// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <KQuickConfigModule>
#include <QObject>
#include <QVariant>

class WebAppsKCM : public KQuickConfigModule
{
    Q_OBJECT

public:
    WebAppsKCM(QObject *parent, const KPluginMetaData &data);
    ~WebAppsKCM() override;

public Q_SLOTS:

Q_SIGNALS:

private:
};
