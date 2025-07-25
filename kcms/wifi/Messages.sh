#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.cpp -o -name \*.qml` -o $podir/kcm_mediacenter_wifi.pot
