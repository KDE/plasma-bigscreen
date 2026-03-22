/*
    SPDX-FileCopyrightText: 2021 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>


    SPDX-License-Identifier: MIT
*/

#ifndef GLOBAL_H
#define GLOBAL_H

#include <QDir>
#include <QObject>
#include <QProcess>
#include <qqmlregistration.h>

#include "screenshot2interface.h"

class Global : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString launchReason READ launchReason CONSTANT)
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Global(QObject *parent = nullptr);

    Q_INVOKABLE void promptLogoutGreeter(const QString message);

    QString launchReason() const;
    Q_INVOKABLE void swapSession();
    Q_INVOKABLE void takeScreenshot();

private:
    void handleScreenshotMetaDataReceived(const QVariantMap &metadata, int fd);

    OrgKdeKWinScreenShot2Interface *m_screenshotInterface;
};

#endif // GLOBAL_H
