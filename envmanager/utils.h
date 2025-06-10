// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QLoggingCategory>

static const QLoggingCategory &LOGGING_CATEGORY()
{
    static const QLoggingCategory category("plasma-bigscreen-envmanager");
    return category;
}
