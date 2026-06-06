#! /usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: CC0-1.0

$XGETTEXT `find . -name \*.qml -o -name \*.cpp -o -name \*.h` -o $podir/kcm_mediacenter_input.pot
