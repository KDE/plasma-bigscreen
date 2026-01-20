// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <kdedmodule.h>

class Start : public KDEDModule
{
    Q_OBJECT

public:
    Start(QObject *parent, const QList<QVariant> &);
};
