/*
 *  SPDX-FileCopyrightText: 2016-2023 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

/**
 * \brief An overlay sheet that covers the current Page content.
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
 * It needs a single element declared inside, do *not* override its contentItem
 *
 * @inherit QtQuick.Templates.Popup
 */
T.Popup {
    id: root

    Kirigami.OverlayZStacking.layer: Kirigami.OverlayZStacking.FullScreen
    z: Kirigami.OverlayZStacking.z

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

//BEGIN Own Properties

    /**
     * \brief A title to be displayed in the header of this Sheet
     */
    property string title

    /**
     * \brief This property sets the visibility of the close button in the top-right corner.
     *
     * default: `Only shown in desktop mode`
     *
     */
    property bool showCloseButton: !Kirigami.Settings.isMobile

    /**
     * \brief This property holds an optional item which will be used as the sheet's header,
     * and will always be displayed.
     */
    property Item header: Kirigami.Heading {
        level: 2
        text: root.title
        elide: Text.ElideRight

        // use tooltip for long text that is elided
        T.ToolTip.visible: truncated && titleHoverHandler.hovered
        T.ToolTip.text: root.title
        HoverHandler {
            id: titleHoverHandler
        }
    }

    /**
     * \brief An optional item which will be used as the sheet's footer,
     * always kept on screen.
     */
    property Item footer

    default property alias flickableContentData: scrollView.contentData
//END Own Properties

//BEGIN Reimplemented Properties
    T.Overlay.modeless: Item {
        id: overlay
        Rectangle {
            x: sheetHandler.visualParent?.Kirigami.ScenePosition.x ?? 0
            y: sheetHandler.visualParent?.Kirigami.ScenePosition.y ?? 0
            width: sheetHandler.visualParent?.width ?? 0
            height: sheetHandler.visualParent?.height ?? 0
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

    closePolicy: T.Popup.CloseOnEscape
    x: parent ? Math.round(parent.width / 2 - width / 2) : 0
    y: {
        if (!parent) {
            return 0;
        }
        const visualParentAdjust = sheetHandler.visualParent?.y ?? 0;
        const wantedPosition = parent.height / 2 - implicitHeight / 2;
        return Math.round(Math.max(visualParentAdjust, wantedPosition, Kirigami.Units.gridUnit * 3));
    }

    implicitWidth: {
        let width = parent?.width ?? 0;
        if (!scrollView.itemForSizeHints) {
            return width;
        } else if (scrollView.itemForSizeHints.Layout.preferredWidth > 0) {
            return Math.min(width, scrollView.itemForSizeHints.Layout.preferredWidth);
        } else if (scrollView.itemForSizeHints.implicitWidth > 0) {
            return Math.min(width, scrollView.itemForSizeHints.implicitWidth);
        } else {
            return width;
        }
    }
    implicitHeight: {
        let h = parent?.height ?? 0;
        if (!scrollView.itemForSizeHints) {
            return h - y;
        } else if (scrollView.itemForSizeHints.Layout.preferredHeight > 0) {
            h = scrollView.itemForSizeHints.Layout.preferredHeight;
        } else if (scrollView.itemForSizeHints.implicitHeight > 0) {
            h = scrollView.itemForSizeHints.implicitHeight + Kirigami.Units.largeSpacing * 2;
        } else if (scrollView.itemForSizeHints instanceof Flickable && scrollView.itemForSizeHints.contentHeight > 0) {
            h = scrollView.itemForSizeHints.contentHeight + Kirigami.Units.largeSpacing * 2;
        } else {
            h = scrollView.itemForSizeHints.height;
        }
        h += headerItem.implicitHeight + footerParent.implicitHeight + topPadding + bottomPadding;
        return parent ? Math.min(h, parent.height - y) : h
    }
//END Reimplemented Properties

//BEGIN Signal handlers
    onVisibleChanged: {
        const flickable = scrollView.contentItem;
        flickable.contentY = flickable.originY - flickable.topMargin;
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            if (!root.parent && typeof applicationWindow !== "undefined") {
                root.parent = applicationWindow().overlay
            }
        });
    }

    Connections {
        target: parent
        function onVisibleChanged() {
            if (!parent.visible) {
                root.close();
            }
        }
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

                Kirigami.Padding {
                    id: headerParent

                    readonly property real leadingPadding: Kirigami.Units.largeSpacing
                    readonly property real trailingPadding: (root.showCloseButton ? closeIcon.width : 0) + Kirigami.Units.smallSpacing

                    anchors.fill: parent
                    verticalPadding: Kirigami.Units.smallSpacing
                    leftPadding: root.mirrored ? trailingPadding : leadingPadding
                    rightPadding: root.mirrored ? leadingPadding : trailingPadding

                    contentItem: root.header
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
                clip: true
                T.ScrollBar.horizontal.policy: T.ScrollBar.AlwaysOff

                property bool initialized: false
                property Item itemForSizeHints

                // Important to not even access contentItem before it has been spontaneously created
                contentWidth: initialized ? contentItem.width : width
                contentHeight: itemForSizeHints?.implicitHeight ?? 0

                onContentItemChanged: {
                    initialized = true;
                    const flickable = contentItem as Flickable;
                    flickable.boundsBehavior = Flickable.StopAtBounds;
                    if ((flickable instanceof ListView) || (flickable instanceof GridView)) {
                        itemForSizeHints = flickable;
                        return;
                    }
                    const content = flickable.contentItem;
                    content.childrenChanged.connect(() => {
                        for (const item of content.children) {
                            item.anchors.margins = Kirigami.Units.largeSpacing;
                            item.anchors.top = content.top;
                            item.anchors.left = content.left;
                            item.anchors.right = content.right;
                        }
                        itemForSizeHints = content.children?.[0] ?? null;
                    });
                }
            }

            // Optional footer
            Kirigami.Separator {
                Layout.fillWidth: true
                visible: footerParent.visible
            }
            Kirigami.Padding {
                id: footerParent
                Layout.fillWidth: true
                padding: Kirigami.Units.smallSpacing
                contentItem: root.footer
                visible: contentItem !== null
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

