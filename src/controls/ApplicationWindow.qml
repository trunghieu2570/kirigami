/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

/*!
 * \brief A window that provides some basic features needed for all apps
 *
 * It's usually used as a root QML component for the application.
 * It's based around the PageRow component, the application will be
 * about pages adding and removal.
 * For most of the usages, this class should be used instead
 * of AbstractApplicationWindow
 * \sa AbstractApplicationWindow
 *
 * Setting a width and height property on the ApplicationWindow
 * will set its initial size, but it won't set it as an automatically binding.
 * to resize programmatically the ApplicationWindow they need to
 * be assigned again in an imperative fashion
 *
 * Example usage:
 * \code
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *  [...]
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *            Kirigami.Action {
 *                text: "View"
 *                icon.name: "view-list-icons"
 *                Kirigami.Action {
 *                        text: "action 1"
 *                }
 *                Kirigami.Action {
 *                        text: "action 2"
 *                }
 *                Kirigami.Action {
 *                        text: "action 3"
 *                }
 *            },
 *            Kirigami.Action {
 *                text: "Sync"
 *                icon.name: "folder-sync"
 *            }
 *         ]
 *     }
 *
 *     contextDrawer: Kirigami.ContextDrawer {
 *         id: contextDrawer
 *     }
 *
 *     pageStack.initialPage: Kirigami.Page {
 *         mainAction: Kirigami.Action {
 *             icon.name: "edit"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *         contextualActions: [
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
 *       [...]
 *     }
 *  [...]
 * }
 * \endcode
 *
*/
Kirigami.AbstractApplicationWindow {
    id: root

    /*!
     * \brief This property holds the stack used to allocate the pages and to
     * manage the transitions between them.
     *
     * It's using a PageRow, while having the same API as PageStack,
     * it positions the pages as adjacent columns, with as many columns
     * as can fit in the screen. An handheld device would usually have a single
     * fullscreen column, a tablet device would have many tiled columns.
     *
     * @property org::kde::kirigami::PageRow pageStack
     */
    readonly property alias pageStack: __pageStack

    // Redefined here as here we can know a pointer to PageRow.
    // We negate the canBeEnabled check because we don't want to factor in the automatic drawer provided by Kirigami for page actions for our calculations
    wideScreen: width >= (root.pageStack.defaultColumnWidth) + ((contextDrawer && !(contextDrawer instanceof Kirigami.ContextDrawer)) ? contextDrawer.width : 0) + (globalDrawer ? globalDrawer.width : 0)

    Component.onCompleted: {
        pageStack.currentItem?.forceActiveFocus()
    }

    Kirigami.PageRow {
        id: __pageStack
        globalToolBar.style: Kirigami.ApplicationHeaderStyle.Auto
        anchors {
            fill: parent
        }

        focus: true
    }
}
