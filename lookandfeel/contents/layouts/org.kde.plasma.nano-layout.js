
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    var desk = desktopsArray[j];
    desk.addWidget("org.kde.plasma.digitalclock");
    desk.wallpaperPlugin = "org.kde.slideshow";

    desk.currentConfigGroup = new Array("Wallpaper","org.kde.slideshow","General");
    desk.writeConfig("SlideInterval", 480);
    desk.writeConfig("SlidePaths", "/usr/share/wallpapers/");
}


