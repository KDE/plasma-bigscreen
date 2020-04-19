# Plasma Bigscreen Build Instructions
  + git clone https://invent.kde.org/KDE/plasma-bigscreen
  + cd plasma-bigscreen
  + mkdir build
  + cd build
  + cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
  + make
  + sudo make install
  + plasmashell --replace -p org.kde.plasma.mycroft.bigscreen

# List of Dependencies
- KDE KF5 Dependencies: (**Most dependencies require the latest git master**)
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
  
- Qt Dependencies:
  - Quick
  - Core
  - Qml
  - DBus
  - Network

# Additional Requirements
- Mycroft-Core (development branch) https://github.com/MycroftAI/Mycroft-Core
- Mycroft-GUI - https://github.com/MycroftAI/Mycroft-GUI
- MycroftSkillInstaller - https://github.com/AIIX/MycroftSkillInstaller
