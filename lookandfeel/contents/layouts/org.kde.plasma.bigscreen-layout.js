/*
    SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    var desk = desktopsArray[j];
    desk.wallpaperPlugin = "org.kde.slideshow";

    desk.currentConfigGroup = new Array("Wallpaper","org.kde.slideshow","General");
    desk.writeConfig("SlideInterval", 480);
    desk.writeConfig("SlidePaths", "/usr/share/wallpapers/");

   if (j == 0) {
        // Add meta to home default shortcut
        desk.currentConfigGroup = new Array("Shortcuts");
        desk.writeConfig("global", "Meta");
    }
}