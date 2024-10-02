/*
 *  SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
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
 * You can use all elements of the QML TextEdit component, in particular
 * the "text" property to define the label text.
 * The properties and signals that belong to TextArea are included for compatiblity reasons,
 * but they're deprecated and do not do anything.
 *
 * Example usage:
 * @code{.qml}
 *     Kirigami.SelectableLabel {
 *         text: "Label"
 *     }
 * @endcode
 *
 * @see https://bugreports.qt.io/browse/QTBUG-14077
 * @since 5.95
 * @since org.kde.kirigami 2.20
 * @inherit QtQuick.TextEdit
 */
TextEdit {
    id: root

    // Unused deprecated properties shared with TextArea to maintain API compatibility
    property var background
    property real bottomInset
    property var focusReason
    property bool hoverEnabled
    property bool hovered
    property real implicitBackgroundHeight
    property real implicitBackgroundWidth
    property real leftInset
    property string placeholderText
    property color placeholderTextColor
    property real rightInset
    property real topInset
    property var flickable

    // Unused deprecated signals shared with TextArea to maintain API compatibility
    signal onPressAndHold()
    signal onPressed()
    signal onReleased()

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
    topPadding: undefined
    leftPadding: undefined
    rightPadding: undefined
    bottomPadding: undefined

    activeFocusOnTab: false
    readOnly: true
    wrapMode: TextEdit.WordWrap
    textFormat: TextEdit.AutoText
    verticalAlignment: TextEdit.AlignTop

    Accessible.selectableText: true
    Accessible.editable: false

    color: Kirigami.Theme.textColor
    selectedTextColor: Kirigami.Theme.highlightedTextColor
    selectionColor: Kirigami.Theme.highlightColor
    onLinkActivated: url => Qt.openUrlExternally(url)

    HoverHandler {
        id: hoverHandler
        // By default HoverHandler accepts the left button while it shouldn't accept anything,
        // causing https://bugreports.qt.io/browse/QTBUG-106489.
        // Qt.NoButton unfortunately is not a valid value for acceptedButtons.
        // Disabling masks the problem, but
        // there is no proper workaround other than an upstream fix
        // See qqc2-desktop-style Label.qml
        enabled: false
        cursorShape: root.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
    }

    TapHandler {
        enabled: root.selectByMouse

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
            enabled: root.selectedText.length > 0
            onTriggered: {
                root.copy();
                root.deselect();
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
                root.selectAll();
            }
        }
    }
}
