/*
 *  SPDX-FileCopyrightText: 2023 by Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/**
 * @brief A fancy inline view header showing a title and optional actions.
 *
 * Designed to be set as the header: property of a ListView or GridView, this
 * component provides a fancy inline header suitable for explaining the contents
 * of its view to the user in an attractive and standardized way. Actions globally
 * relevant to the view can be defined using the actions: property. They will
 * appear on the right side of the header as buttons, and collapse into an
 * overflow menu when there isn't room to show them all.
 *
 * The width: property must be manually set to the parent view's width.
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami as Kirigami
 *
 * ListView {
 *     id: listView
 *
 *     headerPositioning: ListView.OverlayHeader
 *     header: InlineViewHeader {
 *         width: listView.width
 *         text: "My amazing view"
 *         actions: [
 *             Kirigami.Action {
 *                 icon.name: "list-add-symbolic"
 *                 text: "Add item"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             }
 *         ]
 *     }
 *
 *     model: [...]
 *     delegate: [...]
 * }
 * @endcode
 * @inherit QtQuick.QQC2.ToolBar
 */
T.ToolBar {
    id: root

//BEGIN properties
    /**
     * @brief This property holds the title text.
     */
    property string text

    /**
     * This property holds the list of actions to show on the header. Actions
     * are added from left to right. If more actions are set than can fit, an
     * overflow menu is provided.
     */
    property list<T.Action> actions
//END properties

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topPadding: Kirigami.Units.smallSpacing + (root.position === T.ToolBar.Footer ? separator.implicitHeight : 0)
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing + (root.position === T.ToolBar.Header ? separator.implicitHeight : 0)

    z: 999 // don't let content overlap it

    // Just for getting the size of an icons-only ToolButton, used later
    QQC2.ToolButton {
        id: overflowButtonSizeHint
        icon.name: "overflow-menu-symbolic"
        visible: false
    }

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        // We want a color that's basically halfway between the view background
        // color and the window background color. But due to the use of color
        // scopes, only one will be available at a time. So to get basically the
        // same thing, we blend the view background color with a smidgen of the
        // text color.
        color: Qt.tint(Kirigami.Theme.backgroundColor, Qt.alpha(Kirigami.Theme.textColor, 0.03))

        Kirigami.Separator {
            id: separator

            anchors {
                top: root.position === T.ToolBar.Footer ? parent.top : undefined
                left: parent.left
                right: parent.right
                bottom: root.position === T.ToolBar.Header ? parent.bottom : undefined
            }
        }
    }

    contentItem: RowLayout {
        id: rowLayout

        spacing: 0

        Kirigami.Heading {
            Layout.fillWidth: !buttonsLoader.active
            Layout.maximumWidth: {
                if (!buttonsLoader.active) {
                    return -1;
                }
                return rowLayout.width
                    - rowLayout.spacing
                    - overflowButtonSizeHint.width;
            }
            Layout.alignment: Qt.AlignVCenter
            level: 2
            text: root.text
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }

        Loader {
            id: buttonsLoader

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            active: root.actions.length > 0
            sourceComponent: Kirigami.ActionToolBar {
                actions: root.actions
                alignment: Qt.AlignRight
            }
        }
    }
}
