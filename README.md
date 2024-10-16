# ![Logo](https://plasma-bigscreen.org/img/logo.png)

Plasma Bigscreen is a user-friendly, open-source interface designed for devices like HTPCs and SBCs connected to TVs and projectors. It provides an intuitive experience that allows for easy navigation from a distance using remote controls. Discover an engaging environment that adapts to your preferences, offering the safety and privacy protection that come with the Free and Open Source Software.

## Test on a development machine

It is recommended to use `kdesrc-build` to build this from source.
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
- Notifications
- PlasmaQuick
- KIO
- Wayland
- WindowSystem
- KDEConnect
- SVG
  
### QT dependencies

- Quick
- Core
- Qml
- DBus
- Network

</details>

To start the Bigscreen homescreen in a window, run:

```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland "plasmashell -p org.kde.plasma.bigscreen"
```
