/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.16

/**
 * Sidebar provides let's you specify actions that will appear in a list
 * and menu.actions that will appear in a menu in the header.
 *
 * @code
 * Kirigami.ApplicationWindow {
 *     ...
 *     globalDrawer: Kirigami.Sidebar {
 *         title: i18n("My sidebar")
 *         actions: [
 *             Kirigami.Action {
 *             }
 *         ]
 *         menu.actions: [
 *             Kirigami.Action {
 *             }
 *         ]
 *     }
 * }
 * [...]
 * @endcode
 *
 * @since 5.86
 * @since org.kde.kirigami 2.19
 */
OverlayDrawer {
    id: sidebar

    edge: Qt.application.layoutDirection == Qt.RightToLeft ? Qt.RightEdge : Qt.LeftEdge
    modal: !wideScreen
    onModalChanged: drawerOpen = !modal
    handleVisible: !wideScreen
    handleClosedIcon.source: null
    handleOpenIcon.source: null
    drawerOpen: !Settings.isMobile
    width: sidebar.collapsed ? menu.Layout.minimumWidth + Units.smallSpacing : Units.gridUnit * 12
    Behavior on width { NumberAnimation { duration: Units.longDuration; easing.type: Easing.InOutQuad } }

    property string title

    property list<QtObject> topActions

    property list<QtObject> bottomActions

    property alias menuActions: menu.actions

    property Item header: QQC2.ToolBar {
        Layout.fillWidth: true
        Layout.preferredHeight: pageStack.globalToolBar.preferredHeight

        leftPadding: sidebar.collapsed ? 0 : Units.smallSpacing
        rightPadding: sidebar.collapsed ? Units.smallSpacing / 2 : Units.smallSpacing
        topPadding: 0
        bottomPadding: 0

        Heading {
            level: 1
            text: title
            opacity: sidebar.collapsed ? 0 : 1
            anchors.left: parent.left
            anchors.leftMargin: Units.largeSpacing + Units.smallSpacing
            anchors.verticalCenter: parent.verticalCenter

            Behavior on opacity {
                OpacityAnimator {
                    duration: Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        ActionToolBar {
            id: menu
            anchors.fill: parent
            overflowIconName: "application-menu"

            Action {
                id: collapseAction
                enabled: !Settings.isMobile
                text: sidebar.collapsed ? qsTr("Expand Sidebar") : qsTr("Collapse Sidebar")
                icon.name: sidebar.collapsed ? "view-split-left-right" : "view-left-close"
//                 shortcut: "Ctrl+Alt+S"
                onTriggered: sidebar.collapsed = !sidebar.collapsed
            }

            Component.onCompleted: {
                actions.push(collapseAction)
                actions.push(quitAction)
                for (let i in actions) {
                    let action = actions[i]
                    action.displayHint = DisplayHint.AlwaysHide
                }
            }
        }
    }

    Theme.colorSet: Theme.Window

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    contentItem: ColumnLayout {
        id: container
        QQC2.ScrollView {
            id: topView
            implicitWidth: Units.gridUnit * 12
            Layout.topMargin: -Units.smallSpacing - 1
            Layout.bottomMargin: -Units.smallSpacing
            Layout.fillHeight: true
            Layout.fillWidth: true
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
            contentWidth: availableWidth

            ListView {
                id: topList
                currentIndex: -1
                model: topActions
                delegate: BasicListItem {
                    text: modelData.text
                    icon: modelData.icon.name
                    action: modelData
                    separatorVisible: index + 1 < topList.count
                    onClicked: {
                        bottomList.currentIndex = -1;
                    }
                }
            }
        }
        QQC2.ToolSeparator {
            Layout.topMargin: -1;
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            visible: topView.contentHeight > topView.height
        }
        QQC2.ToolSeparator { // WORKAROUND: needed for the first item to display
            Layout.topMargin: -1;
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            visible: topView.contentHeight > topView.height
        }
        QQC2.ScrollView {
            id: bottomView
            implicitWidth: Units.gridUnit * 12
            Layout.fillWidth: true
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
            contentWidth: availableWidth

            ListView {
                id: bottomList
                currentIndex: -1
                model: bottomActions
                delegate: BasicListItem {
                    text: modelData.text
                    icon: modelData.icon.name
                    separatorVisible: index + 1 < bottomList.count
                    action: modelData
                    onClicked: {
                        topList.currentIndex = -1;
                    }
                }
            }
        }
    }

//     function suggestSearchText(text) {
//         if (searchItem.visible) {
//             searchItem.text = text
//             searchItem.forceActiveFocus()
//         }
//     }
//
//     Keys.onPressed: {
//         if(event.text.length > 0 && event.modifiers === Qt.NoModifier && event.text.match(/\w+/)) {
//             sidebar.suggestSearchText(event.text)
//         }
//     }
//
    Component.onCompleted: {
        if (header) {
            container.children[0] = header
            container.children[1] = topView
        }
    }
}
