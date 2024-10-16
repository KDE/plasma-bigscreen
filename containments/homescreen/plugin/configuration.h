/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef CONFIGURATION_H
#define CONFIGURATION_H

#include <QObject>
#include <KGlobalAccel>

class Q_DECL_EXPORT Configuration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool pmInhibitionEnabled READ pmInhibitionEnabled WRITE setPmInhibitionEnabled NOTIFY pmInhibitionEnabledChanged)

public:
    bool pmInhibitionEnabled() const;
    void setPmInhibitionEnabled(bool pmInhibitionEnabled);

    static Configuration &self();

Q_SIGNALS:
    void pmInhibitionEnabledChanged();
};

#endif // CONFIGURATION_H
