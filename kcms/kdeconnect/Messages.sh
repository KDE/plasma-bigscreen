#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.cpp -o -name \*.qml` -o $podir/kcm_mediacenter_kdeconnect.pot
