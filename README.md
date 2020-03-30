# Requirements

- Mycroft (development branch) - as described in the instructions for the above, but switch to the dev branch immediately after the cloning step
- Mycroft-GUI - https://github.com/MycroftAI/Mycroft-GUI
- MycroftSkillInstaller - https://github.com/AIIX/MycroftSkillInstaller

# Plasma Bigscreen
  + git clone https://invent.kde.org/KDE/plasma-bigscreen
  + cd plasma-bigscreen
  + mkdir build
  + cd build
  + cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
  + make
  + sudo make install
