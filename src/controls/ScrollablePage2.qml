/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19
import org.kde.kirigami.templates 2.2 as KT
import "private"

/**
 * ScrollablePage2 is a Page that holds scrollable content, such as ListViews.
 * Scrolling and scrolling indicators will be automatically managed.
 *
 * @code
 * ScrollablePage2 {
 *     id: root
 *     //The rectangle will automatically be scrollable
 *     Rectangle {
 *         width: root.width
 *         height: 99999
 *     }
 * }
 * @endcode
 *
 * @warning Do not put a ScrollView inside of a ScrollablePage2; children of a ScrollablePage2 are already inside a ScrollView.
 *
 * Another behavior added by this class is a "scroll down to refresh" behavior
 * It also can give the contents of the flickable to have more top margins in order
 * to make possible to scroll down the list to reach it with the thumb while using the
 * phone with a single hand.
 *
 * Implementations should handle the refresh themselves as follows
 *
 * @code
 * Kirigami.ScrollablePage2 {
 *     id: view
 *     supportsRefreshing: true
 *     onRefreshingChanged: {
 *         if (refreshing) {
 *             myModel.refresh();
 *         }
 *     }
 *     ListView {
 *         // NOTE: MyModel doesn't come from the components,
 *         // it's purely an example on how it can be used together
 *         // some application logic that can update the list model
 *         // and signals when it's done.
 *         model: MyModel {
 *             onRefreshDone: view.refreshing = false;
 *         }
 *         delegate: BasicListItem {}
 *     }
 * }
 * [...]
 * @endcode
 *
 */
Page {
    id: root

    /**
     * \property bool ScrollablePage2::refreshing
     * If true the list is asking for refresh and will show a loading spinner.
     * it will automatically be set to true when the user pulls down enough the list.
     * This signals the application logic to start its refresh procedure.
     * The application itself will have to set back this property to false when done.
     */
    property bool refreshing: false

    /**
     * \property bool ScrollablePage2::supportsRefreshing
     * If true the list supports the "pull down to refresh" behavior.
     * By default it is false.
     */
    property bool supportsRefreshing: false

    /**
     * \property QtQuick.Flickable ScrollablePage::flickable
     * The main Flickable item of this page.
     */
    readonly property Flickable flickable: itemsParent.flickable

    /**
     * \property QtQuick.Controls.ScrollBar ScrollablePage2::verticalScrollBar
     * The vertical scrollbar.
     */
    readonly property QQC2.ScrollBar verticalScrollBar: scrollView.QQC2.ScrollBar.vertical

    /**
     * \property QtQuick.Controls.ScrollBar ScrollablePage2::horizontalScrollBar
     * The horizontal scrollbar.
     */
    readonly property QQC2.ScrollBar horizontalScrollBar: scrollView.QQC2.ScrollBar.horizontal

    default property alias pageData: itemsParent.data
    property alias pageChildren: itemsParent.children

    /**
     * If true, and if flickable is an item view, like a ListView or
     * a GridView, it will be possible to navigate the list current item
     * to next and previous items with keyboard up/down arrow buttons.
     * Also, any key event will be forwarded to the current list item.
     * default is true.
     */
    property bool keyboardNavigationEnabled: true

    contentHeight: flickable ? flickable.contentHeight : 0
    implicitHeight: ((header && header.visible) ? header.implicitHeight : 0) + ((footer && footer.visible) ? footer.implicitHeight : 0) + contentHeight + topPadding + bottomPadding
    implicitWidth: flickable
        ? (flickable.contentItem ? flickable.contentItem.implicitWidth : contentItem.implicitWidth + leftPadding + rightPadding)
        : 0

    Theme.inherit: false
    Theme.colorSet: flickable && flickable.hasOwnProperty("model") ? Theme.View : Theme.Window

    property QQC2.ScrollView scrollView
    Component {
        id: scrollViewComponent
        QQC2.ScrollView {
            id: scrollView
            anchors {
                top: (root.header && root.header.visible)
                        ? root.header.bottom
                        //FIXME: for now assuming globalToolBarItem is in a Loader, which needs to be got rid of
                        : (globalToolBarItem && globalToolBarItem.parent && globalToolBarItem.visible
                            ? globalToolBarItem.parent.bottom
                            : parent.top)
                bottom: (root.footer && root.footer.visible) ? root.footer.top : parent.bottom
                left: parent.left
                right: parent.right
            }

            property bool supportsRefreshing;
            property bool refreshing
            property alias flickableItem: scrollView.contentItem

            QQC2.ScrollBar.horizontal.policy: Qt.ScrollBarAlwaysOff
        }
    }
    data: Item {
        z: 9999
        parent: root

        implicitHeight: itemsParent.children.length === 1 ? itemsParent.children[0].implicitHeight : 0
        implicitWidth: itemsParent.children.length === 1 ? itemsParent.children[0].implicitWidth : 0
        Item {
            id: itemsParent
            property Flickable flickable
            anchors {
               fill: parent
               leftMargin: root.leftPadding || root.padding
               topMargin: root.topPadding || root.padding
               rightMargin: root.rightPadding || root.padding
               bottomMargin: root.bottomPadding || root.padding
            }
        }
    }
    Component.onCompleted: {
        for (let i in itemsParent.children) {
            let child = itemsParent.children[i];
            if (child instanceof Flickable) {
                itemsParent.flickable = child;
                break;
            }
        }

        if (itemsParent.flickable) {
            root.contentItem = root.scrollView = scrollViewComponent.createObject(root, {"contentData": [itemsParent.flickable]});
            flickable.parent = root.scrollView;
        } else {
            root.contentItem = root.scrollView = scrollViewComponent.createObject(root, {"contentData": [itemsParent.parent]});
        }
    }
}
