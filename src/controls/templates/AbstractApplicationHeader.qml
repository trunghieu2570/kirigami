/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/**
 * \brief An item that can be used as a title for the application.
 *
 * Scrolling the main page will make it taller or shorter (through the point of going away)
 * It's a behavior similar to the typical mobile web browser addressbar
 * the minimum, preferred and maximum heights of the item can be controlled with
 * * minimumHeight: default is 0, i.e. hidden
 * * preferredHeight: default is Units.gridUnit * 1.6
 * * maximumHeight: default is Units.gridUnit * 3
 *
 * To achieve a titlebar that stays completely fixed just set the 3 sizes as the same
 *
 * @inherit QtQuick.Item
 */
Item {
    id: root
    z: 90
    property int minimumHeight: 0
    // Use an inline arrow function, referring to an external normal function makes QV4 crash, see https://bugreports.qt.io/browse/QTBUG-119395
    property int preferredHeight: mainItem.children.reduce((accumulator, item) => {
        return Math.max(accumulator, item.implicitHeight);
    }, 0) + topPadding + bottomPadding
    property int maximumHeight: Kirigami.Units.gridUnit * 3

    property int position: QQC2.ToolBar.Header

    property Kirigami.PageRow pageRow: __appWindow?.pageStack ?? null
    property Kirigami.Page page: pageRow?.currentItem as Kirigami.Page ?? null

    default property alias contentItem: mainItem.data
    readonly property int paintedHeight: headerItem.y + headerItem.height - 1

    property int leftPadding: 0
    property int topPadding: 0
    property int rightPadding: 0
    property int bottomPadding: 0
    property bool separatorVisible: true

    /**
     * This property specifies whether the header should be pushed back when
     * scrolling using the touch screen.
     */
    property bool hideWhenTouchScrolling: root.pageRow?.globalToolBar.hideWhenTouchScrolling ?? false

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Kirigami.Theme.inherit: true

    // FIXME: remove
    property QtObject __appWindow: typeof applicationWindow !== "undefined" ? applicationWindow() : null
    implicitHeight: preferredHeight
    height: Layout.preferredHeight

    /**
     * \brief This property holds the background item.
     * @note the background will be automatically sized to fill the whole control
     */
    property Item background

    onBackgroundChanged: {
        background.z = -1;
        background.parent = headerItem;
        background.anchors.fill = headerItem;
    }

    Component.onCompleted: AppHeaderSizeGroup.items.push(this)

    onMinimumHeightChanged: implicitHeight = preferredHeight;
    onPreferredHeightChanged: implicitHeight = preferredHeight;

    opacity: height > 0 ? 1 : 0

    NumberAnimation {
        id: heightAnim
        target: root
        property: "implicitHeight"
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
    }

    Connections {
        target: root.__appWindow

        function onControlsVisibleChanged() {
            heightAnim.from = root.implicitHeight;
            heightAnim.to = root.__appWindow.controlsVisible ? root.preferredHeight : 0;
            heightAnim.restart();
        }
    }

    Connections {
        target: root.page?.Kirigami.ColumnView ?? null

        function onScrollIntention(event) {
            headerItem.scrollIntentHandler(event);
        }
    }

    Item {
        id: headerItem
        anchors {
            left: parent.left
            right: parent.right
            bottom: !Kirigami.Settings.isMobile || root.position === QQC2.ToolBar.Header ? parent.bottom : undefined
            top: !Kirigami.Settings.isMobile || root.position === QQC2.ToolBar.Footer ? parent.top : undefined
        }

        height: Math.max(root.height, root.minimumHeight > 0 ? root.minimumHeight : root.preferredHeight)

        function scrollIntentHandler(event) {
            if (!root.hideWhenTouchScrolling) {
                return
            }

            if (root.pageRow
                && root.pageRow.globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.Breadcrumb) {
                return;
            }
            if (!root.page.flickable || (root.page.flickable.atYBeginning && root.page.flickable.atYEnd)) {
                return;
            }

            root.implicitHeight = Math.max(0, Math.min(root.preferredHeight, root.implicitHeight + event.delta.y))
            event.accepted = root.implicitHeight > 0 && root.implicitHeight < root.preferredHeight;
            slideResetTimer.restart();
            if ((root.page.flickable instanceof ListView) && root.page.flickable.verticalLayoutDirection === ListView.BottomToTop) {
                root.page.flickable.contentY -= event.delta.y;
            }
        }

        Connections {
            target: root.page?.globalToolBarItem ?? null
            enabled: target
            function onImplicitHeightChanged() {
                root.implicitHeight = root.page.globalToolBarItem.implicitHeight;
            }
        }

        Timer {
           id: slideResetTimer
           interval: 500
           onTriggered: {
                if ((root.pageRow?.wideMode ?? (root.__appWindow?.wideScreen ?? false)) || !Kirigami.Settings.isMobile) {
                    return;
                }
                if (root.height > root.minimumHeight + (root.preferredHeight - root.minimumHeight) / 2) {
                    heightAnim.to = root.preferredHeight;
                } else {
                    heightAnim.to = root.minimumHeight;
                }
                heightAnim.from = root.implicitHeight
                heightAnim.restart();
            }
        }

        Connections {
            target: pageRow
            function onCurrentItemChanged() {
                if (!root.page) {
                    return;
                }

                heightAnim.from = root.implicitHeight;
                heightAnim.to = root.preferredHeight;

                heightAnim.restart();
            }
        }

        Item {
            id: mainItem
            clip: childrenRect.width > width

            onChildrenChanged: {
                for (const child of children) {
                    child.anchors.verticalCenter = verticalCenter;
                }
            }

            anchors {
                fill: parent
                topMargin: root.topPadding
                leftMargin: root.leftPadding
                rightMargin: root.rightPadding
                bottomMargin: root.bottomPadding
            }
        }
    }
}
