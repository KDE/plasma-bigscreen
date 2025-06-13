// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "utils.h"

#include <QStandardPaths>

void setOptionsImmutable(bool immutable, const QString &configFilePath, const QMap<QString, QMap<QString, QVariant>> &options)
{
    // Find ~/.config/{configFilePath}
    QDir basePath{QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)};
    QString fullPath = basePath.filePath(configFilePath);

    QFile file{fullPath};
    if (!file.exists()) {
        return;
    }
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qCCritical(LOGGING_CATEGORY) << "Unable to read from" << configFilePath << "to change immutability!";
        return;
    }

    QTextStream in(&file);
    QStringList lines;

    QString configGroup;

    // Read file line by line, and add/remove [$i] suffixes from each option
    while (!in.atEnd()) {
        QString line = in.readLine();

        if (line.trimmed().startsWith("//")) {
            lines << line;
            continue;
        }

        // Split by first '=' sign
        int equalsIndex = line.indexOf('=');
        if (equalsIndex == -1) {
            lines << line;

            // Is it a group?
            if (line.startsWith("[") && line.endsWith("]")) {
                configGroup = line.mid(1, line.length() - 2);
            }

            continue;
        }

        QString key = line.mid(0, equalsIndex);
        QString value = line.mid(equalsIndex + 1);
        const QString immutableSuffix = "[$i]";

        // Remove [$i] key suffix
        if (key.endsWith(immutableSuffix)) {
            key.chop(immutableSuffix.length());
        }

        // Add [$i] key suffix, only edit line if it's found in provided options
        if (immutable && (options.contains(configGroup) && options[configGroup].contains(key))) {
            key += immutableSuffix;
        }

        lines << (key + "=" + value);
    }
    file.close();

    // Overwrite file with edited lines
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qCCritical(LOGGING_CATEGORY) << "Unable to write to" << configFilePath << "to change immutability!";
        return;
    }

    QTextStream out(&file);
    for (const QString &line : std::as_const(lines)) {
        out << line << "\n";
    }
    file.close();
}
