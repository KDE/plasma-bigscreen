// SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-only

#include <QObject>
#include <qqmlintegration.h>

class LinkRedirector : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    LinkRedirector(QObject *parent = nullptr);
    Q_INVOKABLE QString sendUrl(QString device, QString url);
    Q_INVOKABLE void openInBrowser(QString storageId, QString url);
};