/*
 *  SPDX-FileCopyrightText: 2016-2023 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Templates 2.15 as T2
import org.kde.kirigami as Kirigami
import "private" as P

/**
 * @brief An overlay sheet that covers the current Page content.
 *
 * Its contents can be scrolled up or down, scrolling all the way up or
 * all the way down, dismisses it.
 * Use this for big, modal dialogs or information display, that can't be
 * logically done as a new separate Page, even if potentially
 * are taller than the screen space.
 *
 * Example usage:
 * @code
 * Kirigami.OverlaySheet {
 *    ColumnLayout { ... }
 * }
 * Kirigami.OverlaySheet {
 *    ListView { ... }
 * }
 * @endcode
 *
 * It needs a single element declared inseide, do *not* override its contentItem
 *
 * @inherit QtQuick.Templates.Popup
 */

T2.Popup {
    id: root

    Kirigami.OverlayZStacking.layer: Kirigami.OverlayZStacking.FullScreen
    z: Kirigami.OverlayZStacking.z

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

//BEGIN Own Properties

    /**
     * @brief A title to be displayed in the header of this Sheet
     */
    property string title

    /**
     * @brief This property sets the visibility of the close button in the top-right corner.
     *
     * default: `Only shown in desktop mode`
     *
     */
    property bool showCloseButton: !Kirigami.Settings.isMobile

    /**
     * @brief This property holds an optional item which will be used as the sheet's header,
     * and will always be displayed.
     */
    property Item header: Kirigami.Heading {
        level: 2
        text: root.title
        elide: Text.ElideRight

        // use tooltip for long text that is elided
        QQC2.ToolTip.visible: truncated && titleHoverHandler.hovered
        QQC2.ToolTip.text: root.title
        HoverHandler {
            id: titleHoverHandler
        }
    }

    /**
     * @brief An optional item which will be used as the sheet's footer,
     * always kept on screen.
     */
    property Item footer

    default property alias flickableContentData: scrollView.contentData
//END Own Properties

//BEGIN Reimplemented Properties
    QQC2.Overlay.modeless: Item {
        id: overlay
        Rectangle {
            x: sheetHandler.visualParent.Kirigami.ScenePosition.x
            y: sheetHandler.visualParent.Kirigami.ScenePosition.y
            width: sheetHandler.visualParent.width
            height: sheetHandler.visualParent.height
            color: Qt.rgba(0, 0, 0, 0.2)
        }
        Behavior on opacity {
            NumberAnimation {
                property: "opacity"
                easing.type: Easing.InOutQuad
                duration: Kirigami.Units.longDuration
            }
        }
    }

    modal: false
    dim: true

    leftInset: -1
    rightInset: -1
    topInset: -1
    bottomInset: -1

    closePolicy: QQC2.Popup.CloseOnEscape
    x: parent ? Math.round(parent.width / 2 - width / 2) : 0
    y: {
        if (!parent) {
            return 0;
        }
        const visualParentAdjust = sheetHandler.visualParent?.y ?? 0;
        const wantedPosition = Kirigami.Settings.isMobile
            ? parent.height - implicitHeight - Kirigami.Units.gridUnit
            : parent.height / 2 - implicitHeight / 2;
        return Math.round(Math.max(visualParentAdjust, wantedPosition, Kirigami.Units.gridUnit * 3));
    }

    implicitWidth: {
        if (!scrollView.itemForSizeHints) {
            return parent.width;
        } else if (scrollView.itemForSizeHints.Layout.preferredWidth > 0) {
            return scrollView.itemForSizeHints.Layout.preferredWidth;
        } else if (scrollView.itemForSizeHints.implicitWidth > 0) {
            return scrollView.itemForSizeHints.implicitWidth;
        } else {
            return parent.width;
        }
    }
    implicitHeight: {
        let h = parent.height;
        if (!scrollView.itemForSizeHints) {
            return h;
        } else if (scrollView.itemForSizeHints.Layout.preferredHeight > 0) {
            h = scrollView.itemForSizeHints.Layout.preferredHeight;
        } else if (scrollView.itemForSizeHints.implicitHeight > 0) {
            h = scrollView.itemForSizeHints.implicitHeight + Kirigami.Units.largeSpacing * 2;
        } else {
            return h;
        }
        h += headerItem.implicitHeight + footerParent.implicitHeight + topPadding + bottomPadding;
    }
//END Reimplemented Properties

//BEGIN Signal handlers
    onVisibleChanged: scrollView.contentItem.contentY = 0 + scrollView.contentItem.originY - scrollView.contentItem.topMargin
    onHeaderChanged: headerItem.initHeader()
    onFooterChanged: {
        footer.parent = footerParent;
        footer.Layout.fillWidth = true;
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            if (!root.parent && typeof applicationWindow !== "undefined") {
                root.parent = applicationWindow().overlay
            }
            headerItem.initHeader();
        });
    }
//END Signal handlers

//BEGIN UI
    contentItem: MouseArea {
        implicitWidth: mainLayout.implicitWidth
        implicitHeight: mainLayout.implicitHeight
        Kirigami.Theme.colorSet: root.Kirigami.Theme.colorSet
        Kirigami.Theme.inherit: false

        property real scenePressY
        property real lastY
        property bool dragStarted
        drag.filterChildren: true
        DragHandler {
            id: mouseDragBlocker
            target: null
            dragThreshold: 0
            acceptedDevices: PointerDevice.Mouse
            onActiveChanged: {
                if (active) {
                    parent.dragStarted = false;
                }
            }
        }

        onPressed: mouse => {
            scenePressY = mapToItem(null, mouse.x, mouse.y).y;
            lastY = scenePressY;
            dragStarted = false;
        }
        onPositionChanged: mouse => {
            if (mouseDragBlocker.active) {
                return;
            }
            const currentY = mapToItem(null, mouse.x, mouse.y).y;

            if (dragStarted && currentY !== lastY) {
                translation.y += currentY - lastY;
            }
            if (Math.abs(currentY - scenePressY) > Qt.styleHints.startDragDistance) {
                dragStarted = true;
            }
            lastY = currentY;
        }
        onCanceled: restoreAnim.restart();
        onReleased: mouse => {
            if (mouseDragBlocker.active) {
                return;
            }
            if (Math.abs(mapToItem(null, mouse.x, mouse.y).y - scenePressY) > Kirigami.Units.gridUnit * 5) {
                root.close();
            } else {
                restoreAnim.restart();
            }
        }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: 0

            // Even though we're not actually using any shadows here,
            // we're using a ShadowedRectangle instead of a regular
            // rectangle because it allows fine-grained control over which
            // corners to round, which we need here
            Kirigami.ShadowedRectangle {
                id: headerItem
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                //Layout.margins: 1
                visible: root.header || root.showCloseButton
                implicitHeight: Math.max(headerParent.implicitHeight, closeIcon.height) + Kirigami.Units.smallSpacing * 2
                z: 2
                corners.topLeftRadius: Kirigami.Units.smallSpacing
                corners.topRightRadius: Kirigami.Units.smallSpacing
                Kirigami.Theme.colorSet: Kirigami.Theme.Header
                Kirigami.Theme.inherit: false
                color: Kirigami.Theme.backgroundColor

                function initHeader() {
                    if (header) {
                        header.parent = headerParent;
                        header.anchors.fill = headerParent;
                    }
                }

                Item {
                    id: headerParent
                    implicitHeight: header ? header.implicitHeight : 0
                    anchors {
                        fill: parent
                        leftMargin: Kirigami.Units.largeSpacing
                        margins: Kirigami.Units.smallSpacing
                        rightMargin: (root.showCloseButton ? closeIcon.width : 0) + Kirigami.Units.smallSpacing
                    }
                }
                Kirigami.Icon {
                    id: closeIcon

                    readonly property bool tallHeader: headerItem.height > (Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.largeSpacing + Kirigami.Units.largeSpacing)

                    anchors {
                        right: parent.right
                        rightMargin: Kirigami.Units.largeSpacing
                        verticalCenter: headerItem.verticalCenter
                        margins: Kirigami.Units.smallSpacing
                    }

                    // Apply the changes to the anchors imperatively, to first disable an anchor point
                    // before setting the new one, so the icon don't grow unexpectedly
                    onTallHeaderChanged: {
                        if (tallHeader) {
                            // We want to position the close button in the top-right corner if the header is very tall
                            anchors.verticalCenter = undefined
                            anchors.topMargin = Kirigami.Units.largeSpacing
                            anchors.top = headerItem.top
                        } else {
                            // but we want to vertically center it in a short header
                            anchors.top = undefined
                            anchors.topMargin = undefined
                            anchors.verticalCenter = headerItem.verticalCenter
                        }
                    }
                    Component.onCompleted: tallHeaderChanged()

                    z: 3
                    visible: root.showCloseButton
                    width: Kirigami.Units.iconSizes.smallMedium
                    height: width
                    source: closeMouseArea.containsMouse ? "window-close" : "window-close-symbolic"
                    active: closeMouseArea.containsMouse
                    MouseArea {
                        id: closeMouseArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: root.close();
                    }
                }
                Kirigami.Separator {
                    anchors {
                        right: parent.right
                        left: parent.left
                        top: parent.bottom
                    }
                }
            }

            // Here goes the main Sheet content
            QQC2.ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

                property bool initialized: false
                property Item itemForSizeHints

                // Important to not even access contentItem before it has been spontaneously created
                contentWidth: initialized ? contentItem.width : width
                contentHeight: itemForSizeHints ? itemForSizeHints.implicitHeight : 0

                onContentItemChanged: {
                    initialized = true;
                    contentItem.boundsBehavior = Flickable.StopAtBounds;
                    if ((contentItem instanceof ListView) || (contentItem instanceof GridView)) {
                        itemForSizeHints = contentItem;
                        return;
                    }
                    contentItem.contentItem.childrenChanged.connect(() => {
                        for(const item of contentItem.contentItem.children) {
                            item.anchors.margins = Kirigami.Units.largeSpacing;
                            item.anchors.top = contentItem.contentItem.top;
                            item.anchors.left = contentItem.contentItem.left;
                            item.anchors.right = contentItem.contentItem.right;
                        }
                        itemForSizeHints = contentItem.contentItem.children[0];
                    });
                }
            }

            // Optional footer
            Kirigami.Separator {
                Layout.fillWidth: true
                visible: footerParent.visible
            }
            RowLayout {
                id: footerParent
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                visible: root.footer !== null
            }
        }
        Translate {
            id: translation
        }
        MouseArea {
            id: sheetHandler
            readonly property Item visualParent: root.parent?.contentItem ?? root.parent
            x: -root.x
            y: -root.y
            z: -1
            width:  visualParent?.width ?? 0
            height: (visualParent?.height ?? 0) * 2

            property var pressPos
            onPressed: mouse => {
                pressPos = mapToItem(null, mouse.x, mouse.y)
            }
            onReleased: mouse => {
                // onClicked is emitted even if the mouse was dragged a lot, so we have to check the Manhattan length by hand
                // https://en.wikipedia.org/wiki/Taxicab_geometry
                let pos = mapToItem(null, mouse.x, mouse.y)
                if (Math.abs(pos.x - pressPos.x) + Math.abs(pos.y - pressPos.y) < Qt.styleHints.startDragDistance) {
                    root.close();
                }
            }

            NumberAnimation {
                id: restoreAnim
                target: translation
                property: "y"
                from: translation.y
                to: 0
                easing.type: Easing.InOutQuad
                duration: Kirigami.Units.longDuration
            }
            Component.onCompleted: {
                root.contentItem.parent.transform = translation
                root.contentItem.parent.clip = false
            }
        }
    }
//END UI

//BEGIN Transitions
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                easing.type: Easing.InOutQuad
                duration: Kirigami.Units.longDuration
            }
            NumberAnimation {
                target: translation
                property: "y"
                from: Kirigami.Units.gridUnit * 5
                to: 0
                easing.type: Easing.InOutQuad
                duration: Kirigami.Units.longDuration
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                easing.type: Easing.InOutQuad
                duration: Kirigami.Units.longDuration
            }
            NumberAnimation {
                target: translation
                property: "y"
                from: translation.y
                to: translation.y >= 0 ? translation.y + Kirigami.Units.gridUnit * 5 : translation.y - Kirigami.Units.gridUnit * 5
                easing.type: Easing.InOutQuad
                duration: Kirigami.Units.longDuration
            }
        }
    }
//END Transitions
}

