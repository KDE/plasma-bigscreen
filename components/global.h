/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>


    SPDX-License-Identifier: MIT
*/

#ifndef GLOBAL_H
#define GLOBAL_H

#include <QObject>
#include <QProcess>
#include <QDir>

class Global : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString launchReason READ launchReason CONSTANT)
public:
    explicit Global(QObject *parent = nullptr);

    Q_INVOKABLE void promptLogoutGreeter(const QString message);

    QString launchReason() const;
    Q_INVOKABLE void swapSession();
};

#endif // GLOBAL_H