#! /usr/bin/env bash
$XGETTEXT `find . -name \*.qml` `find ../sddm-theme -name \*.qml` -L Java -o $podir/plasma_lookandfeel_org.kde.plasma.mycroft.bigscreen.pot
rm -f rc.cpp
