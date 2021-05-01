/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import org.kde.plasma.configuration 2.0
import QtQuick.Controls 2.3 as QtControls
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    id: root

    property int formAlignment: wallpaperComboBox.Kirigami.ScenePosition.x - root.Kirigami.ScenePosition.x + (units.largeSpacing/2)
    property string currentWallpaper: ""
    signal configurationChanged

//BEGIN functions
    function saveConfig() {
        if (main.currentItem.saveConfig) {
            main.currentItem.saveConfig()
        }
        for (var key in configDialog.wallpaperConfiguration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                configDialog.wallpaperConfiguration[key] = main.currentItem["cfg_"+key]
            }
        }
        configDialog.currentWallpaper = root.currentWallpaper;
        configDialog.applyWallpaper()
    }
//END functions

    Component.onCompleted: {
        for (var i = 0; i < configDialog.wallpaperConfigModel.count; ++i) {
            var data = configDialog.wallpaperConfigModel.get(i);
            if (configDialog.currentWallpaper == data.pluginName) {
                wallpaperComboBox.currentIndex = i
                wallpaperComboBox.activated(i);
                break;
            }
        }
    }

    Kirigami.InlineMessage {
        visible: plasmoid.immutable || animating
        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Layout cannot be changed while widgets are locked")
        showCloseButton: true
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true
        RowLayout {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper Type:")
            QtControls.ComboBox {
                id: wallpaperComboBox
                Layout.preferredWidth: Math.max(implicitWidth, pluginComboBox.implicitWidth)
                model: configDialog.wallpaperConfigModel
                width: theme.mSize(theme.defaultFont).width * 24
                textRole: "name"
                onActivated: {
                    var model = configDialog.wallpaperConfigModel.get(currentIndex)
                    root.currentWallpaper = model.pluginName
                    configDialog.currentWallpaper = model.pluginName
                    main.sourceFile = model.source
                    root.configurationChanged()
                }
            }
            // TODO Add "Get new plugins.." button when KNS is mobile friendly
        }
    }

    Item {
        id: emptyConfig
    }

    QtControls.StackView {
        id: main

        Layout.fillHeight: true;
        Layout.fillWidth: true;

        // Bug 360862: if wallpaper has no config, sourceFile will be ""
        // so we wouldn't load emptyConfig and break all over the place
        // hence set it to some random value initially
        property string sourceFile: "tbd"
        onSourceFileChanged: {
            if (sourceFile) {
                var props = {}

                var wallpaperConfig = configDialog.wallpaperConfiguration
                for (var key in wallpaperConfig) {
                    props["cfg_" + key] = wallpaperConfig[key]
                }

                var newItem = replace(Qt.resolvedUrl(sourceFile), props)

                for (var key in wallpaperConfig) {
                    var changedSignal = newItem["cfg_" + key + "Changed"]
                    if (changedSignal) {
                        changedSignal.connect(root.configurationChanged)
                    }
                }
            } else {
                replace(emptyConfig)
            }
        }
    }
}
