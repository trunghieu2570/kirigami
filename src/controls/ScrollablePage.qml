/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.19
import org.kde.kirigami.templates 2.2 as KT
import "private"

/**
 * ScrollablePage is a Page that holds scrollable content, such as ListViews.
 * Scrolling and scrolling indicators will be automatically managed.
 *
 * @code
 * ScrollablePage {
 *     id: root
 *     //The rectangle will automatically be scrollable
 *     Rectangle {
 *         width: root.width
 *         height: 99999
 *     }
 * }
 * @endcode
 *
 * @warning Do not put a ScrollView inside of a ScrollablePage; children of a ScrollablePage are already inside a ScrollView.
 *
 * Another behavior added by this class is a "scroll down to refresh" behavior
 * It also can give the contents of the flickable to have more top margins in order
 * to make possible to scroll down the list to reach it with the thumb while using the
 * phone with a single hand.
 *
 * Implementations should handle the refresh themselves as follows
 *
 * @code
 * Kirigami.ScrollablePage {
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
     * \property bool ScrollablePage::refreshing
     * If true the list is asking for refresh and will show a loading spinner.
     * it will automatically be set to true when the user pulls down enough the list.
     * This signals the application logic to start its refresh procedure.
     * The application itself will have to set back this property to false when done.
     */
    property bool refreshing: false

    /**
     * \property bool ScrollablePage::supportsRefreshing
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
     * \property Qt.ScrollBarPolicy ScrollablePage::verticalScrollBarPolicy
     * The vertical scrollbar policy.
     */
    property int verticalScrollBarPolicy

    /**
     * \property Qt.ScrollBarPolicy ScrollablePage::horizontalScrollBarPolicy
     * The horizontal scrollbar policy.
     */
    property int horizontalScrollBarPolicy: QQC2.ScrollBar.AlwaysOff

    default property alias pageData: itemsParent.data
    property alias pageChildren: itemsParent.children

    /**
     * @deprecated here for compatibility, will be removed in next Frameworks release
     */
    property QtObject mainItem

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

    contentItem: QQC2.ScrollView {
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
            topMargin: root.refreshing ? busyIndicatorFrame.height : 0
            Behavior on topMargin {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    duration: Units.longDuration
                }
            }
        }
        QQC2.ScrollBar.horizontal.policy: root.horizontalScrollBarPolicy
        QQC2.ScrollBar.vertical.policy: root.verticalScrollBarPolicy
    }

    data: [
        Item {
            id: scrollingArea
            width: itemsParent.flickable.width
            height: Math.max(root.flickable.height, implicitHeight)
            implicitHeight: {
                let impl = 0;
                for (let i in itemsParent.visibleChildren) {
                    let child = itemsParent.visibleChildren[i];
                    impl = Math.max(impl, child.implicitHeight);
                }
                return impl + itemsParent.anchors.topMargin + itemsParent.anchors.bottomMargin;
            }
            implicitWidth: {
                let impl = 0;
                for (let i in itemsParent.children) {
                    let child = itemsParent.children[i];
                    impl = Math.max(impl, child.implicitWidth);
                }
                return impl + itemsParent.anchors.leftMargin + itemsParent.anchors.rightMargin;
            }
            Item {
                id: itemsParent
                property Flickable flickable
                anchors {
                    fill: parent
                    leftMargin: root.leftPadding
                    topMargin: root.topPadding
                    rightMargin: root.rightPadding
                    bottomMargin: root.bottomPadding
                }
            }
        },

        Item {
            id: busyIndicatorFrame
            z: 99
            y: root.flickable.verticalLayoutDirection === ListView.BottomToTop
                ? -root.flickable.contentY + root.flickable.originY + height
                : -root.flickable.contentY + root.flickable.originY - height + scrollView.y
            width: root.flickable.width
            height: busyIndicator.height + Units.gridUnit * 2
            QQC2.BusyIndicator {
                id: busyIndicator
                z: 1
                anchors.centerIn: parent
                running: root.refreshing
                visible: root.refreshing
                //Android busywidget QQC seems to be broken at custom sizes
            }
            Rectangle {
                id: spinnerProgress
                anchors {
                    fill: busyIndicator
                    margins: Math.ceil(Units.smallSpacing)
                }
                radius: width
                visible: supportsRefreshing && !refreshing && progress > 0
                color: "transparent"
                opacity: 0.8
                border.color: Theme.backgroundColor
                border.width: Math.ceil(Units.smallSpacing)
                property real progress: supportsRefreshing && !refreshing ? (parent.y/busyIndicatorFrame.height) : 0
            }
            ConicalGradient {
                source: spinnerProgress
                visible: spinnerProgress.visible
                anchors.fill: spinnerProgress
                gradient: Gradient {
                    GradientStop { position: 0.00; color: Theme.highlightColor }
                    GradientStop { position: spinnerProgress.progress; color: Theme.highlightColor }
                    GradientStop { position: spinnerProgress.progress + 0.01; color: "transparent" }
                    GradientStop { position: 1.00; color: "transparent" }
                }
            }

            onYChanged: {
                if (!supportsRefreshing) {
                    return;
                }

                if (!root.refreshing && y > busyIndicatorFrame.height/2 + topPadding) {
                    refreshTriggerTimer.running = true;
                } else {
                    refreshTriggerTimer.running = false;
                }
            }
            Timer {
                id: refreshTriggerTimer
                interval: 500
                onTriggered: {
                    if (!root.refreshing && parent.y > busyIndicatorFrame.height/2 + topPadding) {
                        root.refreshing = true;
                    }
                }
            }
        }
    ]
    Component.onCompleted: {
        for (let i in itemsParent.children) {
            let child = itemsParent.children[i];
            if (child instanceof Flickable) {
                // If there were more flickable children, take the last one, as behavior compatibility
                // with old internal ScrollView
                itemsParent.flickable = child;
                child.keyNavigationEnabled = true;
                child.keyNavigationWraps = false;
            } else if (child instanceof KT.OverlaySheet) {
                //reparent sheets
                if (child.parent === itemsParent || child.parent === null) {
                    child.parent = root;
                }
            } else {
                child.anchors.left = itemsParent.left;
                child.anchors.right = itemsParent.right;
            }
        }

        if (itemsParent.flickable) {
            scrollView.contentItem = flickable;
            flickable.parent = scrollView;
            // Some existing code incorrectly uses anchors
            flickable.anchors.fill = undefined;
            flickable.anchors.left = undefined;
            flickable.anchors.right = undefined;
            flickable.anchors.top = undefined;
            flickable.anchors.bottom = undefined;
        } else {
            itemsParent.flickable = scrollView.contentItem;
            scrollingArea.parent = scrollView.contentItem.contentItem;
        }
        itemsParent.flickable.flickableDirection = Flickable.VerticalFlick;
    }
}
