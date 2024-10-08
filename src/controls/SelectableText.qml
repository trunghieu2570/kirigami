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
 * This element should be used instead of SelectableLabel, due to SelectableLabel using TextArea
 * which can have issues when resizing.
 *
 * Example usage:
 * @code{.qml}
 *     Kirigami.SelectableText {
 *         text: "Label"
 *     }
 * @endcode
 *
 * @see https://bugreports.qt.io/browse/QTBUG-14077
 * @since org.kde.kirigami 2.21
 * @since 6.8
 * @inherit QtQuick.TextEdit
 */

QQC2.Control {
    id: root

    padding: 0
    activeFocusOnTab: false
    property bool readOnly: true
    property var wrapMode: TextEdit.WordWrap
    property var textFormat: TextEdit.AutoText
    property var horizontalAlignment
    property var verticalAlignment: TextEdit.AlignTop
    property color color: Kirigami.Theme.textColor
    property color selectedTextColor: Kirigami.Theme.highlightedTextColor
    property color selectionColor: Kirigami.Theme.highlightColor
    property string text
    property var cursorShape
    property bool selectByMouse: true
    readonly property string hoveredLink: textEdit.hoveredLink

    signal linkHovered(string link)
    signal linkActivated(string link)
    signal clicked()

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

        padding: 0
        activeFocusOnTab: root.activeFocusOnTab
        readOnly: root.readOnly
        wrapMode: root.wrapMode
        textFormat: root.textFormat
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: root.verticalAlignment
        color: root.color
        selectedTextColor: root.selectedTextColor
        selectionColor: root.selectionColor
        selectByMouse: root.selectByMouse

        onLinkActivated: root.linkActivated()
        onLinkHovered: root.linkHovered()

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
