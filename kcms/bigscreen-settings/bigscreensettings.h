/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>         *
 *   SPDX-FileCopyrightText: 2015 Sebastian Kügler <sebas@kde.org>         *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#ifndef BIGSCREENSETTINGS_H
#define BIGSCREENSETTINGS_H

#include <KQuickConfigModule>
#include <KSharedConfig>
#include <QObject>
#include <QVariant>

class ColorSchemeListModel;

class BigscreenSettings : public KQuickConfigModule
{
    Q_OBJECT

    Q_PROPERTY(QString colorSchemeName READ colorSchemeName NOTIFY colorSchemeNameChanged)
    Q_PROPERTY(ColorSchemeListModel *colorSchemeListModel READ colorSchemeListModel CONSTANT)
    Q_PROPERTY(QTime currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QDate currentDate READ currentDate WRITE setCurrentDate NOTIFY currentDateChanged)
    Q_PROPERTY(bool useNtp READ useNtp WRITE setUseNtp NOTIFY useNtpChanged)

public:
    BigscreenSettings(QObject *parent, const KPluginMetaData &data);
    ~BigscreenSettings() override;

    QString colorSchemeName() const;
    void loadColorSchemeName();

    ColorSchemeListModel *colorSchemeListModel();

public Q_SLOTS:
    void load() override;

    bool useColoredTiles();
    void setUseColoredTiles(bool useColoredTiles);

    bool useWallpaperBlur();
    void setUseWallpaperBlur(bool useWallpaperBlur);

    void saveTimeZone(const QString &newtimezone);

    bool useNtp();
    void setUseNtp(bool ntp);

    QTime currentTime();
    void setCurrentTime(const QTime &time);

    QDate currentDate();
    void setCurrentDate(const QDate &date);

    bool saveTime();

    QString getShortcut(const QString &action);
    bool setShortcut(const QString &action, const QKeySequence &shortcut);
    void resetShortcut(const QString &action);

Q_SIGNALS:
    void colorSchemeNameChanged();
    void timeFormatChanged();
    void twentyFourChanged();
    void useNtpChanged();
    void currentTimeChanged();
    void currentDateChanged();

private:
    KSharedConfigPtr m_config;
    QString m_colorSchemeName;
    ColorSchemeListModel *m_colorSchemeListModel;

    QTime m_currentTime;
    QDate m_currentDate;
    bool m_useNtp;
};

#endif // BIGSCREENSETTINGS_H
