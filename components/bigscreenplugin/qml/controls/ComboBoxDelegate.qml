// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects

import org.kde.kirigami as Kirigami

ItemDelegate {
    id: root

    /*!
       \brief This signal is emitted when the item at \a index is activated
       by the user.
     */
    signal activated(int index)

    /*!
       \qmlproperty Label descriptionItem
       \brief This property allows for access to the description label item.
     */
    property alias descriptionItem: internalDescriptionItem

    /*!
       \brief This property specifies whether the description font should be smaller.
     */
    property bool smallDescription: true

    /*!
       \qmlproperty var currentValue
       \brief This property holds the \l {ComboBox::currentValue} {currentValue} of the internal ComboBox.
     */
    property alias currentValue: combobox.currentValue

    /*!
       \qmlproperty string currentText
       \brief This property holds the \l {ComboBox::currentText} {currentText} of the internal ComboBox.
       \sa displayText
     */
    property alias currentText: combobox.currentText

    /*!
       \brief This property holds the \l {ComboBox::model} {model} providing data for the ComboBox.
       \sa displayText
       \sa {https://doc.qt.io/qt-6/qtquick-modelviewsdata-modelview.html} {Models and Views in QtQuick}
     */
    property var model

    /*!
       \qmlproperty int count
       \brief This property holds the \l {ComboBox::count} {count} of the internal ComboBox.
       \since 1.4.0
     */
    property alias count: combobox.count

    /*!
       \qmlproperty string textRole
       \brief This property holds the \l {ComboBox::textRole} {textRole} of the internal ComboBox.
     */
    property alias textRole: combobox.textRole

    /*!
       \qmlproperty string valueRole
       \brief This property holds the \l {ComboBox::valueRole} {valueRole} of the internal ComboBox.
     */
    property alias valueRole: combobox.valueRole

    /*!
       \qmlproperty int currentIndex
       \brief This property holds the \l {ComboBox::currentIndex} {currentIndex} of the internal ComboBox.

       Default: \c -1 when the model has no data, \c 0 otherwise
     */
    property alias currentIndex: combobox.currentIndex

    /*!
       \qmlproperty int highlightedIndex
       \brief This property holds the \l {ComboBox::highlightedIndex} {highlightedIndex} of the internal ComboBox.
     */
    property alias highlightedIndex: combobox.highlightedIndex

    /*!
       \qmlproperty string displayText
       \brief This property holds the \l {ComboBox::displayText} {displayText} of the internal ComboBox.

       This can be used to slightly modify the text to be displayed in the combobox, for instance, by adding a string with the currentText.
     */
    property alias displayText: combobox.displayText

    /*!
       \qmlproperty Label textItem
       \brief This property holds allows for access to the text label item.
     */
    property alias textItem: internalTextItem

    /*!
       \brief This property holds an item that will be displayed before
       the delegate's contents.
       \default null
     */
    property var leading: null

    /*!
       \brief This property holds the padding after the leading item.
       \default Kirigami.Units.smallSpacing
     */
    property real leadingPadding: Kirigami.Units.gridUnit

    /*!
       \brief This property holds an item that will be displayed after
       the delegate's contents.
       \default null
     */
    property var trailing: null

    /*!
       \brief This property holds the padding before the trailing item.
       \default Kirigami.Units.smallSpacing
     */
    property real trailingPadding: Kirigami.Units.gridUnit

    function indexOfValue(value) {
        return combobox.indexOfValue(value);
    }

    onPressed: root.forceActiveFocus()
    Keys.onReturnPressed: {
        click();
    }
    onClicked: comboBoxDialog.open()

    Accessible.onPressAction: root.clicked()

    contentItem: RowLayout {
        spacing: 0

        QQC2.Control {
            Layout.rightMargin: visible ? root.leadingPadding : 0
            visible: root.leading
            implicitHeight: visible ? root.leading.implicitHeight : 0
            implicitWidth: visible ? root.leading.implicitWidth : 0
            contentItem: root.leading
        }

        Kirigami.Icon {
            Layout.rightMargin: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignVCenter

            color: root.icon.color
            implicitHeight: (root.icon.name !== "") ? root.icon.height : 0
            implicitWidth: (root.icon.name !== "") ? root.icon.width : 0
            source: root.icon.name
            visible: root.icon.name != ''
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: (!internalTextItem.visible || !internalDescriptionItem.visible) ? 0 : Kirigami.Units.smallSpacing

            QQC2.Label {
                id: internalTextItem
                Layout.fillWidth: true
                text: root.text
                font.pixelSize: Units.defaultFontPixelSize
                elide: Text.ElideRight
                visible: root.text
                Accessible.ignored: true // base class sets this text on root already
            }
            QQC2.Label {
                id: internalDescriptionItem
                Layout.fillWidth: true
                text: root.displayText
                font.pixelSize: root.smallDescription ? 14 : Units.defaultFontPixelSize
                color: Kirigami.Theme.disabledTextColor
                elide: Text.ElideRight
                wrapMode: Text.Wrap
            }
        }

        QQC2.Control {
            Layout.leftMargin: visible ? root.trailingPadding : 0
            visible: root.trailing
            implicitHeight: visible ? root.trailing.implicitHeight : 0
            implicitWidth: visible ? root.trailing.implicitWidth : 0
            contentItem: root.trailing
        }

        // Internal combobox
        QQC2.ComboBox {
            id: combobox
            focusPolicy: Qt.NoFocus // provided by parent
            model: root.model
            visible: false
            currentIndex: root.currentIndex
            onActivated: index => root.activated(index)
        }
    }

    Dialog {
        id: comboBoxDialog
        title: root.text
        onOpened: contentItem.forceActiveFocus()
        onClosed: root.forceActiveFocus()

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            spacing: Kirigami.Units.smallSpacing
            model: root.model
            currentIndex: root.currentIndex
            keyNavigationEnabled: true

            delegate: ButtonDelegate {
                width: ListView.view.width
                text: root.textRole ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole]) : modelData

                onClicked: {
                    root.currentIndex = index;
                    root.activated(index);
                    comboBoxDialog.close();
                }

                trailing: Kirigami.Icon {
                    visible: root.currentIndex == model.index;
                    source: 'checkmark'
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                }
            }
        }
    }
}
