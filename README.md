# ![Logo](https://plasma-bigscreen.org/wp-content/uploads/sites/3/2020/03/bigscreen-logo.png)

A big launcher giving you easy access to any installed apps and skills.
Controllable via voice or TV remote.

This project is using various open-source components like Plasma Bigscreen, Mycroft AI and libcec.

### Voice Control

Bigscreen supports Mycroft AI, a free and open-source voice assistant that can be run completely decentralized on your own server.

### Remote control your TV via CEC

CEC (Consumer Electronics Control) is a standard to control devices over HDMI.
Use your normal TV remote control, or a RC with built-in microphone for voice control and optional mouse simulation.

### Voice apps

Download new apps (aka skills) for your Bigscreen or add your own ones for others to enjoy.

## Test on a development machine

It is recommended to use `kdesrc-build` to build this from source.
See [this page](https://community.kde.org/Get_Involved/development) in order to set it up.
Note that `kdesrc-build` doesn't automatically build `plasma-nano` and `plasma-settings`, so make sure to also build that before you run the shell.

<details>
<summary><b>Click here to see dependencies</b></summary>

### KDE Plasma Dependencies

- plasma-nano - https://invent.kde.org/plasma/plasma-nano
- plasma-settings - https://invent.kde.org/plasma-mobile/plasma-settings

### KDE KF5 dependencies

- Activities
- ActivitiesStats
- Plasma
- I18n
- Kirigami2
- Declarative
- KCMUtils
- Notifications
- PlasmaQuick
- KIO
- Wayland
- WindowSystem
- KDEConnect
  
### Qt dependencies

- Quick
- Core
- Qml
- DBus
- Network

### Optional dependencies

The following can be installed for extra functionality but are not required to build or run:

- Mycroft-Core (development branch) https://github.com/MycroftAI/Mycroft-Core
- Mycroft-GUI - https://github.com/MycroftAI/Mycroft-GUI
- MycroftSkillInstaller - https://github.com/AIIX/MycroftSkillInstaller

</details>

To start the Bigscreen homescreen in a window, run:

```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland "plasmashell -p org.kde.plasma.mycroft.bigscreen"
```

