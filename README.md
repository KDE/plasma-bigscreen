<!--
- SPDX-FileCopyrightText: None
- SPDX-License-Identifier: CC0-1.0
-->

# Plasma Bigscreen

This repository contains shell components for Plasma Bigscreen.

* Project page: [plasma-bigscreen.org](https://plasma-bigscreen.org)
* Repository: [invent.kde.org/plasma/plasma-bigscreen](https://invent.kde.org/plasma/plasma-bigscreen)
* Documentation: [invent.kde.org/plasma/plasma-bigscreen/-/wikis/home](https://invent.kde.org/plasma/plasma-bigscreen/-/wikis/home)
* Development channel: [matrix.to/#/#plasma-bigscreen:kde.org](https://matrix.to/#/#plasma-bigscreen:kde.org)

Plasma Bigscreen is a user-friendly, open-source interface designed for devices like HTPCs and SBCs connected to TVs and projectors. It provides an intuitive experience that allows for easy navigation from a distance using remote controls. Discover an engaging environment that adapts to your preferences, offering the safety and privacy protection that come with the Free and Open Source Software.

### Locations

* [components](components) - Shell components & controls libraries
* [containments](containments) - Shell components (homescreen)
* [kcms](kcms) - Settings modules
* [look-and-feel](look-and-feel/contents) - Plasma look-and-feel package
* [shell](shell) Plasma shell package, provides implementations for applet and containment configuration dialogs

<img src="/screenshots/homescreen.png" width=500px/>

### Test on a development machine

It is recommended to use `kde-builder` to build this from source.
See [this page](https://community.kde.org/Get_Involved/development) in order to set it up.
Note that `kdesrc-build` doesn't automatically build `plasma-nano` and `plasma-settings`, so make sure to also build that before you run the shell.

<details>
<summary><b>Click here to see dependencies</b></summary>

### KDE Plasma Dependencies

- Plasma Nano - https://invent.kde.org/plasma/plasma-nano

### KDE Frameworks Dependencies

- Activities
- ActivitiesStats
- Plasma
- I18n
- Kirigami
- KCMUtils
- GlobalAccel
- Milou
- Notifications
- PlasmaQuick
- KIO
- Wayland
- WindowSystem
- KDEConnect
- SVG
- KScreen

### Qt dependencies

- Quick
- Core
- Qml
- DBus
- Network

</details>

To start the Bigscreen homescreen in a window, use the following script:

```bash
#/bin/bash

# Environment variables
export QT_QUICK_CONTROLS_STYLE=org.kde.breeze
export QT_ENABLE_GLYPH_CACHE_WORKAROUND=1
export QT_QUICK_CONTROLS_MOBILE=true
export PLASMA_INTEGRATION_USE_PORTAL=1
export PLASMA_PLATFORM=mediacenter
export QT_FILE_SELECTORS=mediacenter

# Set ~/.config/plasma-bigscreen/... as location for default bigscreen configs (i.e. envmanager generated)
export XDG_CONFIG_DIRS="$HOME/.config/plasma-bigscreen:/etc/xdg:$XDG_CONFIG_DIRS"

# ensure that we have our environment settings set properly prior to the shell being loaded (otherwise there is a race condition with autostart)
QT_QPA_PLATFORM=offscreen plasma-bigscreen-envmanager --apply-settings

export PLASMA_DEFAULT_SHELL=org.kde.plasma.bigscreen
dbus-run-session kwin_wayland "plasmashell -p org.kde.plasma.bigscreen"
```

<br/>

<img src="https://invent.kde.org/plasma/plasma-bigscreen/-/wikis/uploads/92914bdc119ad89fb0436c1ad59e1375/image.png" width=300px>
