# Requirements

- Mycroft Plasma (and its components) - kde:plasma-mycroft
- Mycroft (development branch) - as described in the instructions for the above, but switch to the dev branch immediately after the cloning step
- MycroftSkillInstaller - https://github.com/AIIX/MycroftSkillInstaller

# Plasma Big Launcher
  + cd plasma-big-launcher
  + mkdir build
  + cd build
  + cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
  + make
  + sudo make install
  + Logout / Login or Restart Plasma Shell
