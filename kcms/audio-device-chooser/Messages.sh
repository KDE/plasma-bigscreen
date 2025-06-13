#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.cpp -o -name \*.qml` -o $podir/kcm_audiodevice.pot
