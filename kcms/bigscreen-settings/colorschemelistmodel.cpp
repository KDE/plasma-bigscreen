/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>         *
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>                *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#include "colorschemelistmodel.h"

#include <KColorScheme>
#include <KConfigGroup>
#include <KSharedConfig>

#include <QCollator>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>

#include <algorithm>

using namespace Qt::StringLiterals;

ColorSchemeListModel::ColorSchemeListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames.insert(PackageNameRole, "packageNameRole");
    m_roleNames.insert(SchemeNameRole, "schemeNameRole");
    m_roleNames.insert(WindowColorRole, "windowColorRole");
    m_roleNames.insert(TextColorRole, "textColorRole");
    m_roleNames.insert(ButtonColorRole, "buttonColorRole");
    m_roleNames.insert(HighlightColorRole, "highlightColorRole");
    m_roleNames.insert(HighlightedTextColorRole, "highlightedTextColorRole");
    m_roleNames.insert(ActiveTitleBarBackgroundRole, "activeTitleBarBackgroundRole");
    m_roleNames.insert(ActiveTitleBarForegroundRole, "activeTitleBarForegroundRole");

    reload();
}

ColorSchemeListModel::~ColorSchemeListModel() = default;

QHash<int, QByteArray> ColorSchemeListModel::roleNames() const
{
    return m_roleNames;
}

int ColorSchemeListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_colorSchemes.count();
}

QVariant ColorSchemeListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_colorSchemes.count()) {
        return {};
    }

    const ColorSchemeInfo &colorScheme = m_colorSchemes.at(index.row());
    switch (role) {
    case PackageNameRole:
        return colorScheme.package;
    case SchemeNameRole:
        return colorScheme.schemeName;
    case WindowColorRole:
        return colorScheme.windowColor;
    case TextColorRole:
        return colorScheme.textColor;
    case ButtonColorRole:
        return colorScheme.buttonColor;
    case HighlightColorRole:
        return colorScheme.highlightColor;
    case HighlightedTextColorRole:
        return colorScheme.highlightedTextColor;
    case ActiveTitleBarBackgroundRole:
        return colorScheme.activeTitleBarBackground;
    case ActiveTitleBarForegroundRole:
        return colorScheme.activeTitleBarForeground;
    default:
        return {};
    }
}

QModelIndex ColorSchemeListModel::indexOf(const QString &schemeName) const
{
    for (int i = 0; i < m_colorSchemes.count(); ++i) {
        if (m_colorSchemes.at(i).schemeName == schemeName) {
            return index(i, 0);
        }
    }

    return {};
}

QVariantMap ColorSchemeListModel::get(int index) const
{
    QVariantMap map;
    if (index < 0 || index >= m_colorSchemes.count()) {
        return map;
    }

    const ColorSchemeInfo &colorScheme = m_colorSchemes.at(index);
    map.insert("packageName", colorScheme.package);
    map.insert("schemeName", colorScheme.schemeName);
    map.insert("windowColor", colorScheme.windowColor);
    map.insert("textColor", colorScheme.textColor);
    map.insert("buttonColor", colorScheme.buttonColor);
    map.insert("highlightColor", colorScheme.highlightColor);
    map.insert("highlightedTextColor", colorScheme.highlightedTextColor);
    map.insert("activeTitleBarBackground", colorScheme.activeTitleBarBackground);
    map.insert("activeTitleBarForeground", colorScheme.activeTitleBarForeground);

    return map;
}

void ColorSchemeListModel::reload()
{
    beginResetModel();
    m_colorSchemes.clear();

    QStringList schemeFiles;

    const QStringList schemeDirs =
        QStandardPaths::locateAll(QStandardPaths::GenericDataLocation, QStringLiteral("color-schemes"), QStandardPaths::LocateDirectory);
    for (const QString &dir : schemeDirs) {
        const QStringList fileNames = QDir(dir).entryList(QStringList{QStringLiteral("*.colors")});
        for (const QString &file : fileNames) {
            const QString suffixedFileName = QLatin1String("color-schemes/") + file;
            if (!schemeFiles.contains(suffixedFileName)) {
                schemeFiles.append(suffixedFileName);
            }
        }
    }

    std::ranges::transform(schemeFiles, schemeFiles.begin(), [](const QString &item) {
        return QStandardPaths::locate(QStandardPaths::GenericDataLocation, item);
    });

    for (const QString &schemeFile : std::as_const(schemeFiles)) {
        const QFileInfo fileInfo(schemeFile);
        const QString baseName = fileInfo.baseName();

        KSharedConfigPtr config = KSharedConfig::openConfig(schemeFile, KConfig::SimpleConfig);
        KConfigGroup group(config, u"General"_s);
        const QString name = group.readEntry("Name", baseName);

        const QPalette palette = KColorScheme::createApplicationPalette(config);

        QColor activeTitleBarBackground;
        QColor activeTitleBarForeground;
        if (KColorScheme::isColorSetSupported(config, KColorScheme::Header)) {
            KColorScheme headerColorScheme(QPalette::Active, KColorScheme::Header, config);
            activeTitleBarBackground = headerColorScheme.background().color();
            activeTitleBarForeground = headerColorScheme.foreground().color();
        } else {
            KConfigGroup wmConfig(config, u"WM"_s);
            activeTitleBarBackground = wmConfig.readEntry("activeBackground", palette.color(QPalette::Active, QPalette::Highlight));
            activeTitleBarForeground = wmConfig.readEntry("activeForeground", palette.color(QPalette::Active, QPalette::HighlightedText));
        }

        ColorSchemeInfo info;
        info.package = name;
        info.schemeName = baseName;
        info.windowColor = palette.color(QPalette::Active, QPalette::Window);
        info.textColor = palette.color(QPalette::Active, QPalette::WindowText);
        info.buttonColor = palette.color(QPalette::Active, QPalette::Button);
        info.highlightColor = palette.color(QPalette::Active, QPalette::Highlight);
        info.highlightedTextColor = palette.color(QPalette::Active, QPalette::HighlightedText);
        info.activeTitleBarBackground = activeTitleBarBackground;
        info.activeTitleBarForeground = activeTitleBarForeground;

        m_colorSchemes.append(info);
    }

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    std::ranges::sort(m_colorSchemes, [&collator](const ColorSchemeInfo &a, const ColorSchemeInfo &b) {
        return collator.compare(a.package, b.package) < 0;
    });

    endResetModel();
}

void ColorSchemeListModel::setColorScheme(const QString &schemeName)
{
    QProcess process;
    process.start(QStringLiteral("plasma-apply-colorscheme"), QStringList{schemeName});
    if (!process.waitForStarted() || !process.waitForFinished()) {
        qWarning() << "Failed to start plasma-apply-colorscheme:" << process.errorString();
        return;
    }

    if (process.exitCode() != 0) {
        qWarning() << "Failed to set color scheme:" << process.errorString() << process.readAllStandardError() << process.readAllStandardOutput();
        return;
    }

    Q_EMIT colorSchemeChanged();
    if (!m_colorSchemes.isEmpty()) {
        Q_EMIT dataChanged(index(0, 0), index(m_colorSchemes.count() - 1, 0));
    }
}

#include "moc_colorschemelistmodel.cpp"
