/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>         *
 *   SPDX-FileCopyrightText: 2015 Sebastian Kügler <sebas@kde.org>         *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 ***************************************************************************/

#ifndef BIGSCREENSETTINGS_H
#define BIGSCREENSETTINGS_H

#include <KQuickAddons/ConfigModule>
#include <QObject>
#include <QVariant>

namespace Plasma
{
class Theme;
}

class ThemeListModel;

class BigscreenSettings : public KQuickAddons::ConfigModule
{
    Q_OBJECT

    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)
    Q_PROPERTY(ThemeListModel *themeListModel READ themeListModel CONSTANT)
    Q_PROPERTY(QTime currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QDate currentDate READ currentDate WRITE setCurrentDate NOTIFY currentDateChanged)
    Q_PROPERTY(bool useNtp READ useNtp WRITE setUseNtp NOTIFY useNtpChanged)

public:
    BigscreenSettings(QObject *parent, const QVariantList &args);
    ~BigscreenSettings() override;

    QString themeName() const;
    void setThemeName(const QString &theme);

    ThemeListModel *themeListModel();

public Q_SLOTS:
    void load() override;
    void applyPlasmaTheme(QQuickItem *item, const QString &themeName);

    bool useColoredTiles() const;
    void setUseColoredTiles(bool useColoredTiles);

    bool useExpandingTiles() const;
    void setUseExpandingTiles(bool useExpandingTiles);

    bool mycroftIntegrationActive() const;
    void setMycroftIntegrationActive(bool mycroftIntegrationActive);

    bool pmInhibitionActive() const;
    void setPmInhibitionActive(bool pmInhibitionActive);

    void saveTimeZone(const QString &newtimezone);

    bool useNtp() const;
    void setUseNtp(bool ntp);

    QTime currentTime() const;
    void setCurrentTime(const QTime &time);

    QDate currentDate() const;
    void setCurrentDate(const QDate &date);

    bool saveTime();

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
    ThemeListModel *m_themeListModel;

    bool m_coloredTiles;
    bool m_expandingTiles;

    QTime m_currentTime;
    QDate m_currentDate;
    bool m_useNtp;
};

#endif // BIGSCREENSETTINGS_H
