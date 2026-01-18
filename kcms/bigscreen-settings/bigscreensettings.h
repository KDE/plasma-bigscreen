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
#include <QObject>
#include <QVariant>

namespace Plasma
{
class Theme;
}

class GlobalThemeListModel;

class BigscreenSettings : public KQuickConfigModule
{
    Q_OBJECT

    Q_PROPERTY(QString themeName READ themeName NOTIFY themeNameChanged)
    Q_PROPERTY(GlobalThemeListModel *globalThemeListModel READ globalThemeListModel CONSTANT)
    Q_PROPERTY(QTime currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QDate currentDate READ currentDate WRITE setCurrentDate NOTIFY currentDateChanged)
    Q_PROPERTY(bool useNtp READ useNtp WRITE setUseNtp NOTIFY useNtpChanged)

public:
    BigscreenSettings(QObject *parent, const KPluginMetaData &data);
    ~BigscreenSettings() override;

    QString themeName() const;
    void setThemeName(const QString &theme);

    GlobalThemeListModel *globalThemeListModel();

public Q_SLOTS:
    void load() override;

    bool useColoredTiles();
    void setUseColoredTiles(bool useColoredTiles);

    bool useWallpaperBlur();
    void setUseWallpaperBlur(bool useWallpaperBlur);

    bool pmInhibitionActive();
    void setPmInhibitionActive(bool pmInhibitionActive);

    void saveTimeZone(const QString &newtimezone);

    bool useNtp();
    void setUseNtp(bool ntp);

    QTime currentTime();
    void setCurrentTime(const QTime &time);

    QDate currentDate();
    void setCurrentDate(const QDate &date);

    bool saveTime();

    QString getShortcut(const QString &action);
    void setShortcut(const QString &action, const QKeySequence &shortcut);
    void resetShortcut(const QString &action);

Q_SIGNALS:
    void themeNameChanged();
    void timeFormatChanged();
    void twentyFourChanged();
    void useNtpChanged();
    void currentTimeChanged();
    void currentDateChanged();

private:
    QHash<QString, Plasma::Theme *> m_themes;
    Plasma::Theme *m_theme;
    QString m_themeName;
    GlobalThemeListModel *m_globalThemeListModel;

    QTime m_currentTime;
    QDate m_currentDate;
    bool m_useNtp;
};

#endif // BIGSCREENSETTINGS_H
