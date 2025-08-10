#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.cpp -o -name \*.h -o -name \*.qml -o -name \*.js` -o $podir/plasma_applet_org.kde.bigscreen.homescreen.pot
