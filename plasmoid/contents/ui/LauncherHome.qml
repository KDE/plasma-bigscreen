import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.private.biglauncher 1.0 as Launcher
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    id: launcherHomeColumn
    anchors.fill: parent
    spacing: 1
    
    Rectangle {
	id: appsColumnLabelBox
        Layout.preferredWidth: appslabel.contentWidth + Kirigami.Units.largeSpacing * 3
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        color: Kirigami.Theme.backgroundColor
        
        PlasmaComponents.Label {
            id: appslabel
            anchors.centerIn: parent
            text: "My Apps & Games"
            font.pointSize: Kirigami.Units.iconSizes.small - Kirigami.Units.largeSpacing
            font.capitalization: Font.SmallCaps
        }
    }
    
    Item {
        //color: Kirigami.Theme.backgroundColor
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 2 - appsColumnLabelBox.height
        
        FocusScope {
            anchors.fill: parent
            
            GridView {
                id: gridView
                layoutDirection: Qt.LeftToRight
                width: parent.width
                height: parent.height
                flow: GridView.FlowTopToBottom
                cellWidth: gridView.width / 3
                cellHeight: gridView.height / 1
                //cellHeight: Kirigami.Units.iconSizes.huge + Kirigami.Units.largeSpacing + root.reservedSpaceForLabel
                model: root.appsModel
                clip: true
                highlight: PlasmaComponents.Highlight {}
                focus: true
                keyNavigationEnabled: true
                currentIndex: 0
                property var appId 
                delegate: RowDelegateApps {
                    property var modelData: typeof model !== "undefined" ? model : null
                }
                
                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 1000 }
                }
                
                Keys.onEnterPressed: {
                    console.log("Enter Pressed In GridView1")
                    if (gridView.focus) {
                         root.appsModel.runApplication(gridView.appId)
                    }
                }
                
                Keys.onReturnPressed: {
                    console.log("Enter Pressed In GridView1")
                    if (gridView.focus) {
                         root.appsModel.runApplication(gridView.appId)
                    }
                }
                
                Keys.onRightPressed: {
                    if (gridView.currentIndex < gridView.count) {
                        gridView.currentIndex = Math.min(gridView.currentIndex+1, gridView.count)
                    } 
                    if(gridView.currentIndex == gridView.count) {
                        gridView.currentIndex = 0
                    }
                    console.log("RightKey Pressed")
                }
                
                Keys.onLeftPressed:  { 
                    if (gridView.currentIndex > 0 ) {
                        gridView.currentIndex = gridView.currentIndex-1
                    }
                    if (gridView.currentIndex == 0 ) {
                        gridView.currentIndex = gridView.count
                    }
                    console.log("LeftKey Pressed")
                }
                
                Keys.onUpPressed: { 
                    console.log("UpKey Pressed")
                    activateTopNavBar()
                }
                
                Keys.onDownPressed: { 
                    gridView2.forceActiveFocus()
                    gridView2.currentIndex = 0
                    gridView.currentIndex = -1
                    gridView.focus = false
                }
                
                onCurrentItemChanged: {
                    console.log(currentIndex)
                    gridView.appId = currentItem.appStorageIdRole
                }
            }
        }
    }
    
    Rectangle {
	id: voiceAppsLabelColumnBox
        Layout.preferredWidth: appslabel.contentWidth + Kirigami.Units.largeSpacing * 3
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        color: Kirigami.Theme.backgroundColor
        
        PlasmaComponents.Label {
            id: appslabel2
            anchors.centerIn: parent
            text: "My Voice Apps"
            font.pointSize: Kirigami.Units.iconSizes.small - Kirigami.Units.largeSpacing
            font.capitalization: Font.SmallCaps
        }
    }
    
    Item {
        //color: Kirigami.Theme.backgroundColor
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 2 - voiceAppsLabelColumnBox.height
        
        FocusScope {
            anchors.fill: parent
            
            GridView {
                id: gridView2
                layoutDirection: Qt.LeftToRight
                width: parent.width
                height: parent.height
                flow: GridView.FlowTopToBottom
                cellWidth: gridView2.width / 3
                cellHeight: gridView2.height / 1
                model: root.voiceAppsModel
                clip: true
                highlight: PlasmaComponents.Highlight {}
                focus: false
                keyNavigationEnabled: true
                currentIndex: -1
                property var vAppId
                delegate: RowDelegateVoiceApps {
                    property var modelData: typeof model !== "undefined" ? model : null
                }
                
                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 1000 }
                }
                
                Keys.onEnterPressed: {
                    console.log("Enter Pressed In GridView2")
                    if (gridView2.focus) {
                         root.appsModel.runApplication(gridView2.vAppId)
                    }
                }
                
                Keys.onReturnPressed: {
                    console.log("Enter Pressed In GridView2")
                    if (gridView2.focus) {
                         root.appsModel.runApplication(gridView2.vAppId)
                    }
                }
                
                Keys.onRightPressed: {
                    if (gridView2.currentIndex < gridView2.count) {
                        gridView2.currentIndex = Math.min(gridView2.currentIndex+1, gridView2.count)
                    } 
                    if(gridView2.currentIndex == gridView2.count) {
                        gridView2.currentIndex = 0
                    }
                    console.log("RightKey Pressed")
                }
                Keys.onLeftPressed:  { 
                    if (gridView2.currentIndex > 0 ) {
                        gridView2.currentIndex = gridView2.currentIndex-1
                    }
                    if (gridView2.currentIndex == 0 ) {
                        gridView2.currentIndex = gridView2.count
                    }
                    console.log("LeftKey Pressed")
                }
                Keys.onUpPressed:    { 
                    gridView.forceActiveFocus()
                    gridView.currentIndex = 0
                    gridView2.currentIndex = -1
                    gridView2.focus = false
                }
                Keys.onDownPressed:  {  
                    console.log("DownKey Pressed")
                }
                
                onCurrentItemChanged: {
                    console.log(currentIndex)
                    gridView2.vAppId = currentItem.vAppStorageIdRole
                }
            }
        }
    }
    
    Component.onCompleted: {
        gridView.forceActiveFocus();
    }

    Connections {
	target: root
	onActivateAppView: {
	     console.log("here");
	     gridView.forceActiveFocus();
        }
    }
}
