#! /bin/sh

# SPDX-FileCopyrightText: 2020 Yuri Chornoivan
# SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.cpp -o -name \*.h -o -name \*.qml -o -name \*.js` -o $podir/plasma-bigscreen-uvcviewer.pot