/*
 *   Copyright (C) 2016 by Aditya Mehra <aix.m@outlook.com>                      *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef PROTOTYPEPLASMOIDPLUGIN_H
#define PROTOTYPEPLASMOIDPLUGIN_H

#include <QQmlExtensionPlugin> 
#include <QDBusAbstractAdaptor>
#include <Plasma/Applet>

class QQmlEngine;
class ApplicationListModel;
class VoiceAppListModel;
class QQuickItem;

class BigLauncherPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
    Q_PROPERTY(ApplicationListModel *applicationListModel READ applicationListModel CONSTANT)
    Q_PROPERTY(VoiceAppListModel *voiceAppListModel READ voiceAppListModel CONSTANT)
    
public:
    void registerTypes(const char *uri);
    void initializeEngine(QQmlEngine *engine, const char *uri) override;
    
    ApplicationListModel *applicationListModel();
    VoiceAppListModel *voiceAppListModel();

private:
    ApplicationListModel *m_applicationListModel;
    VoiceAppListModel *m_voiceAppListModel;
    
Q_SIGNAL
};

#endif // PROTOTYPEPLASMOIDPLUGIN_H
