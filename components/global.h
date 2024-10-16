/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: MIT
*/

#ifndef GLOBAL_H
#define GLOBAL_H

#include <QObject>

class Global : public QObject
{
    Q_OBJECT

public:
    explicit Global(QObject *parent = nullptr);

    Q_INVOKABLE void promptLogoutGreeter(const QString message);
};

#endif // GLOBAL_H