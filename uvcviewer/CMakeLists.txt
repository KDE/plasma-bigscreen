# SPDX-FileCopyrightText: 2025 Seshan Ravikumar <seshan@sineware.ca>
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

add_subdirectory(src)

install(PROGRAMS org.kde.plasma.bigscreen.uvcviewer.desktop DESTINATION ${KDE_INSTALL_APPDIR})
