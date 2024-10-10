/*
 *  SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *  SPDX-FileCopyrightText: 2024 Akseli Lahtinen <akselmo@akselmo.dev>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as QQC2
import QtQuick.Templates as T

/**
 * @brief This is a label which supports text selection.
 *
 * The label uses TextEdit component, which is wrapped inside a Control component.
 *
 *
 * Example usage:
 * @code{.qml}
 *     Kirigami.SelectableLabel {
 *         text: "Label"
 *     }
 * @endcode
 *
 * @see https://bugreports.qt.io/browse/QTBUG-14077
 * @since org.kde.kirigami 2.20
 * @since 5.95
 * @inherit QtQuick.Control
 */

QQC2.Control {
    id: root

    //TODO KF7: Cleanup from unnecessary properties we dont need to expose for a label
    activeFocusOnTab: false
    padding: 0

    property bool readOnly: true
    property bool selectByMouse: true
    property color color: Kirigami.Theme.textColor
    property color selectedTextColor: Kirigami.Theme.highlightedTextColor
    property color selectionColor: Kirigami.Theme.highlightColor
    property string text
    property var baseUrl
    property var cursorShape
    property var horizontalAlignment
    property var textFormat: TextEdit.AutoText
    property var verticalAlignment: TextEdit.AlignTop
    property var wrapMode: TextEdit.WordWrap

    readonly property bool canPaste: textEdit.canPaste
    readonly property bool canRedo: textEdit.canRedo
    readonly property bool canUndo: textEdit.canUndo
    readonly property bool inputMethodComposing: textEdit.inputMethodComposing
    readonly property int length: textEdit.length
    readonly property int lineCount: textEdit.lineCount
    readonly property int selectionEnd: textEdit.selectionEnd
    readonly property int selectionStart: textEdit.selectionStart
    readonly property real contentHeight: textEdit.contentHeight
    readonly property real contentWidth: textEdit.contentWidth
    readonly property string hoveredLink: textEdit.hoveredLink
    readonly property string preeditText: textEdit.preeditText
    readonly property string selectedText: textEdit.selectedText
    readonly property var cursorRectangle: textEdit.cursorRectangle
    readonly property var cursorSelection: textEdit.cursorSelection
    readonly property var effectiveHorizontalAlignment: textEdit.effectiveHorizontalAlignment
    readonly property var textDocument: textEdit.textDocument

    signal clicked()
    signal linkActivated(string link)
    signal linkHovered(string link)

    onLinkActivated: link => Qt.openUrlExternally(link)
//BEGIN TextArea dummy entries
    property var flickable: undefined
    property var placeholderText: undefined
    property var placeholderTextColor: undefined

    signal pressAndHold(MouseEvent event)
    signal pressed(MouseEvent event)
    signal released(MouseEvent event)
//END TextArea dummy entries

//BEGIN TextEdit dummy entries
    property var activeFocusOnPress: undefined
    property var cursorDelegate: undefined
    property var cursorPosition: undefined
    property var cursorVisible: undefined
    property var inputMethodHints: undefined
    property var mouseSelectionMode: undefined
    property var overwriteMode: undefined
    property var persistentSelection: undefined
    property var renderType: undefined
    property var selectByKeyboard: undefined
    property var tabStopDistance: undefined
    property var textMargin: undefined

    signal editingFinished()
//END TextEdit dummy entries

    contentItem: TextEdit {
        id: textEdit

        /**
        * @brief This property holds the cursor shape that will appear whenever
        * the mouse is hovering over the label.
        *
        * default: @c Qt.IBeamCursor
        *
        * @property Qt::CursorShape cursorShape
        */
        property alias cursorShape: hoverHandler.cursorShape

        activeFocusOnTab: root.activeFocusOnTab
        baseUrl: root.baseUrl
        color: root.color
        horizontalAlignment: root.horizontalAlignment
        padding: 0
        readOnly: root.readOnly
        selectByMouse: root.selectByMouse
        selectedTextColor: root.selectedTextColor
        selectionColor: root.selectionColor
        textFormat: root.textFormat
        verticalAlignment: root.verticalAlignment
        wrapMode: root.wrapMode

        onLinkActivated: root.linkActivated(textEdit.hoveredLink)
        onLinkHovered: root.linkHovered(textEdit.hoveredLink)

        text: root.text

        Accessible.selectableText: true
        Accessible.editable: false
        HoverHandler {
            id: hoverHandler
            // By default HoverHandler accepts the left button while it shouldn't accept anything,
            // causing https://bugreports.qt.io/browse/QTBUG-106489.
            // Qt.NoButton unfortunately is not a valid value for acceptedButtons.
            // Disabling masks the problem, but
            // there is no proper workaround other than an upstream fix
            // See qqc2-desktop-style Label.qml
            enabled: false
            cursorShape: root.cursorShape ? root.cursorShape : (textEdit.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor)
        }

        TapHandler {
            // For custom click actions we want selection to be turned off
            enabled: !textEdit.selectByMouse

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
            acceptedButtons: Qt.LeftButton

            onTapped: root.clicked()
        }

        TapHandler {
            enabled: textEdit.selectByMouse

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
            acceptedButtons: Qt.RightButton

            onTapped: {
                contextMenu.popup();
            }
        }

        QQC2.Menu {
            id: contextMenu
            QQC2.MenuItem {
                action: T.Action {
                    icon.name: "edit-copy-symbolic"
                    text: qsTr("Copy")
                    shortcut: StandardKey.Copy
                }
                enabled: textEdit.selectedText.length > 0
                onTriggered: {
                    textEdit.copy();
                    textEdit.deselect();
                }
            }
            QQC2.MenuSeparator {}
            QQC2.MenuItem {
                action: T.Action {
                    icon.name: "edit-select-all-symbolic"
                    text: qsTr("Select All")
                    shortcut: StandardKey.SelectAll
                }
                onTriggered: {
                    textEdit.selectAll();
                }
            }
        }
    }
}
