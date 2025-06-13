// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDir>
#include <QFile>
#include <QLoggingCategory>
#include <QTextStream>

static const QLoggingCategory &LOGGING_CATEGORY()
{
    static const QLoggingCategory category("plasma-bigscreen-envmanager");
    return category;
}

/**
 * Sets each config option in the config file to be immutable or not (appended with [$i])
 * See https://api.kde.org/frameworks/kconfig/html/options.html for more details.
 *
 * @param immutable whether to set options to be immutable, or to remove immutability
 * @param configFilePath path to the config file
 * @param options the options in the config file to affect (format: <config group, <key, value>>)
 */
void setOptionsImmutable(bool immutable, const QString &configFilePath, const QMap<QString, QMap<QString, QVariant>> &options);
