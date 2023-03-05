/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "private" as P


// TODO KF6: Remove!
/**
 * @brief ToolBarApplicationHeader represents a toolbar that
 * will display the actions of the current page.
 *
 * Both Contextual actions and the main, left and right actions
 */
ApplicationHeader {
    id: header

    preferredHeight: 42
    maximumHeight: preferredHeight
    headerStyle: ApplicationHeaderStyle.Titles

    // FIXME: needs a property definition to have its own type in qml
    property string _internal: ""

    Component.onCompleted: print("Warning: ToolbarApplicationHeader is deprecated, remove and use the automatic internal toolbar instead.")
    pageDelegate: Item {
        id: delegateItem
        readonly property bool current: __appWindow.pageStack.currentIndex === index
        implicitWidth: titleTextMetrics.width/2 + buttonTextMetrics.collapsedButtonsWidth

        RowLayout {
            id: titleLayout
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: actionsLayout.left
            }
            Kirigami.Separator {
                id: separator
                Layout.preferredHeight: parent.height * 0.6
            }

            Kirigami.Heading {
                id: title
                Layout.fillWidth: true

                Layout.preferredWidth: implicitWidth
                Layout.minimumWidth: Math.min(titleTextMetrics.width, delegateItem.width - buttonTextMetrics.requiredWidth)
                leftPadding: Kirigami.Units.largeSpacing
                opacity: delegateItem.current ? 1 : 0.4
                maximumLineCount: 1
                color: Kirigami.Theme.textColor
                elide: Text.ElideRight
                text: page ? page.title : ""
            }
        }

        TextMetrics {
            id: titleTextMetrics
            text: page ? page.title : ""
            font: title.font
        }
        TextMetrics {
            id: buttonTextMetrics
            text: ""
            readonly property int collapsedButtonsWidth: ctxActionsButton.width
            readonly property int requiredWidth: width + collapsedButtonsWidth
        }

        P.PrivateActionToolButton {
            id: ctxActionsButton
            showMenuArrow: page.actions.length === 1

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: Kirigami.Units.smallSpacing
            }

            Kirigami.Action {
                id: overflowAction
                icon.name: "overflow-menu"
                tooltip: qsTr("More Actions")
                visible: children.length > 0
                children: page ? page.actions : null
            }

            action: page && page.actions.length === 1 ? page.actions[0] : overflowAction
        }
    }
}
