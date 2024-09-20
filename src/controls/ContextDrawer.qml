/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import "private" as KP

/**
 * A specialized type of drawer that will show a list of actions
 * relevant to the application's current page.
 *
 * Example usage:
 *
 * @code
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *     contextDrawer: Kirigami.ContextDrawer {
 *         enabled: true
 *         actions: [
 *             Kirigami.Action {
 *                 icon.name: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             },
 *             Kirigami.Action {
 *                 icon.name: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             }
 *         ]
 *     }
 * }
 * @endcode
 *
 * @inherit OverlayDrawer
 */
Kirigami.OverlayDrawer {
    id: root

    handleClosedIcon.source: null
    handleOpenIcon.source: null

    /**
     * \brief A title for the action list that will be shown to the user when opens the drawer
     *
     * default: ``qsTr("Actions")``
     */
    property string title: qsTr("Actions")

    /**
     * List of contextual actions to be displayed in a ListView.
     *
     * \sa QtQuick.Action
     * \sa org::kde::kirigami::Action
     * @property list<T.Action> actions
     */
    property list<T.Action> actions

    /**
     * \brief Arbitrary content to show above the list view.
     *
     * default: `an Item containing a Kirigami.Heading that displays a title whose text is
     * controlled by the title property.`
     *
     * @property Component header
     * @since 2.7
     */
    property alias header: menu.header

    /**
     * \brief Arbitrary content to show below the list view.
     * @property Component footer
     * @since 2.7
     */
    property alias footer: menu.footer

    // Not stored in a property, so we don't have to waste memory on an extra list.
    function visibleActions() {
        return actions.filter(
            action => !(action instanceof Kirigami.Action) || action.visible
        );
    }

    // Disable for empty menus or when we have a global toolbar
    enabled: {
        const pageStack = typeof applicationWindow !== "undefined" ? applicationWindow().pageStack : null;
        const itemExistsButStyleIsNotToolBar = item => item && item.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.ToolBar;
        return menu.count > 0
            && (!pageStack
                || !pageStack.globalToolBar
                || (pageStack.layers.depth > 1
                    && itemExistsButStyleIsNotToolBar(pageStack.layers.currentItem))
                || itemExistsButStyleIsNotToolBar(pageStack.trailingVisibleItem));
    }

    edge: Qt.application.layoutDirection === Qt.RightToLeft ? Qt.LeftEdge : Qt.RightEdge
    drawerOpen: false

    // list items go to edges, have their own padding
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    property bool handleVisible: {
        if (typeof applicationWindow === "function") {
            const w = applicationWindow();
            if (w) {
                return w.controlsVisible;
            }
        }
        // For a ContextDrawer its handle is hidden by default
        return false;
    }

    contentItem: QQC2.ScrollView {
        // this just to create the attached property
        Kirigami.Theme.inherit: true
        implicitWidth: Kirigami.Units.gridUnit * 20
        ListView {
            id: menu
            interactive: contentHeight > height

            model: root.visibleActions()

            topMargin: root.handle.y > 0 ? menu.height - menu.contentHeight : 0
            header: QQC2.ToolBar {
                height: pageStack.globalToolBar.preferredHeight
                width: parent.width

                Kirigami.Heading {
                    id: heading
                    elide: Text.ElideRight
                    text: root.title

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        leftMargin: Kirigami.Units.largeSpacing
                        rightMargin: Kirigami.Units.largeSpacing
                    }
                }
            }

            delegate: Column {
                id: delegate

                required property T.Action modelData

                width: parent.width

                KP.ContextDrawerActionItem {
                    tAction: delegate.modelData
                    width: parent.width
                }

                Repeater {
                    model: delegate.modelData instanceof Kirigami.Action && delegate.modelData.expandible
                        ? delegate.modelData.children : null

                    delegate: KP.ContextDrawerActionItem {
                        width: parent.width
                        leftPadding: Kirigami.Units.gridUnit
                        opacity: !root.collapsed
                    }
                }
            }
        }
    }
}
