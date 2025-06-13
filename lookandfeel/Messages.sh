#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.qml` -L Java -o $podir/plasma_lookandfeel_org.kde.plasma.bigscreen.pot
rm -f rc.cpp
