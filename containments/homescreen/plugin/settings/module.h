/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <KQuickConfigModule>
#include <QFileInfo>
#include <QObject>

class Module : public QObject
{
    Q_OBJECT
    Q_PROPERTY(KQuickConfigModule *kcm READ kcm NOTIFY kcmChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QString name READ name WRITE setPath NOTIFY nameChanged)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)

public:
    KQuickConfigModule *kcm() const;
    QString path() const;
    void setPath(const QString &name);

    QString name()
    {
        return QFileInfo(m_path).baseName();
    }

    bool valid();

Q_SIGNALS:
    void kcmChanged();
    void pathChanged();
    void nameChanged();
    void validChanged();

private:
    KQuickConfigModule *m_kcm = nullptr;
    QString m_path;
    bool m_valid = false;
};