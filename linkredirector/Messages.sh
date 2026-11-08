#!/bin/sh

# SPDX-FileCopyrightText: 2026 User8395 <therealuser8395@proton.me>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.cpp -o -name \*.h -o -name \*.qml -o -name \*.js` -o $podir/plasma-bigscreen-linkredirector.pot