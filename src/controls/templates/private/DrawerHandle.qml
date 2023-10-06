/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

MouseArea {
    id: drawerHandle

    /*
     * This property is used to set when the tooltip is visible.
     * It exists because the text is changed while the tooltip is still visible.
     */
    property bool displayToolTip: true

    /**
     * The drawer this handle will control
     */
    //TODO: this could eventually be a T.Drawer, tough this code
    property T.Drawer drawer

    z: drawer.T.Overlay.overlay.z + 1
    preventStealing: true
    hoverEnabled: handleAnchor && handleAnchor.visible
    parent: drawer.T.Overlay.overlay.parent

    QQC2.ToolButton {
        anchors.centerIn: parent
        width: parent.height - Kirigami.Units.smallSpacing * 1.5
        height: parent.height - Kirigami.Units.smallSpacing * 1.5
        onClicked: {
            drawerHandle.displayToolTip = false
            Qt.callLater(() => drawer.drawerOpen = !drawer.drawerOpen)
        }
        Accessible.name: root.drawerOpen ? root.handleOpenToolTip : root.handleClosedToolTip
        visible: !Kirigami.Settings.tabletMode && !Kirigami.Settings.hasTransientTouchInput
    }
    QQC2.ToolTip.visible: drawerHandle.displayToolTip && containsMouse
    QQC2.ToolTip.text: root.drawerOpen ? handleOpenToolTip : handleClosedToolTip
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

    property Item handleAnchor: (applicationWindow().pageStack && applicationWindow().pageStack.globalToolBar)
            ? ((drawer.edge === Qt.LeftEdge && Qt.application.layoutDirection === Qt.LeftToRight)
                || (drawer.edge === Qt.RightEdge && Qt.application.layoutDirection === Qt.RightToLeft)
                ? applicationWindow().pageStack.globalToolBar.leftHandleAnchor
                : applicationWindow().pageStack.globalToolBar.rightHandleAnchor)
            : null

    property int startX
    property int mappedStartX

    enabled: root.handleVisible

    onPressed: mouse => {
        drawer.peeking = true;
        startX = mouse.x;
        mappedStartX = mapToItem(parent, startX, 0).x
    }
    onPositionChanged: mouse => {
        if (!pressed) {
            return;
        }
        const pos = mapToItem(parent, mouse.x - startX, mouse.y);
        switch(drawer.edge) {
        case Qt.LeftEdge:
            drawer.position = pos.x/drawer.contentItem.width;
            break;
        case Qt.RightEdge:
            drawer.position = (drawer.parent.width - pos.x - width)/drawer.contentItem.width;
            break;
        default:
        }
    }
    onReleased: mouse => {
        drawer.peeking = false;
        if (Math.abs(mapToItem(parent, mouse.x, 0).x - mappedStartX) < Qt.styleHints.startDragDistance) {
            if (!drawer.drawerOpen) {
                drawer.close();
            }
            drawer.drawerOpen = !drawer.drawerOpen;
        }
    }
    onCanceled: {
        drawer.peeking = false
    }
    x: {
        switch(drawer.edge) {
        case Qt.LeftEdge:
            return drawer.background.width * drawer.position + Kirigami.Units.smallSpacing;
        case Qt.RightEdge:
            return drawerHandle.parent.width - (drawer.background.width * drawer.position) - width - Kirigami.Units.smallSpacing;
        default:
            return 0;
        }
    }

    Binding {
        when: drawerHandle.handleAnchor && drawerHandle.anchors.bottom
        target: drawerHandle
        property: "y"
        value: drawerHandle.handleAnchor ? drawerHandle.handleAnchor.Kirigami.ScenePosition.y : 0
        restoreMode: Binding.RestoreBinding
    }

    anchors {
        bottom: drawerHandle.handleAnchor ? undefined : parent.bottom
        bottomMargin: {
            if (typeof applicationWindow === "undefined") {
                return;
            }

            let margin = Kirigami.Units.smallSpacing;
            if (applicationWindow().footer) {
                margin = applicationWindow().footer.height + Kirigami.Units.smallSpacing;
            }

            if(drawer.parent && drawer.height < drawer.parent.height) {
                margin = drawer.parent.height - drawer.height - drawer.y + Kirigami.Units.smallSpacing;
            }

            if (!applicationWindow() || !applicationWindow().pageStack ||
                !applicationWindow().pageStack.contentItem ||
                !applicationWindow().pageStack.contentItem.itemAt) {
                return margin;
            }

            let item;
            if (applicationWindow().pageStack.layers.depth > 1) {
                item = applicationWindow().pageStack.layers.currentItem;
            } else {
                item = applicationWindow().pageStack.contentItem.itemAt(applicationWindow().pageStack.contentItem.contentX + drawerHandle.x, 0);
            }

            // try to take the last item
            if (!item) {
                item = applicationWindow().pageStack.lastItem;
            }

            let pageFooter = item && item.page ? item.page.footer : (item ? item.footer : undefined);
            if (pageFooter && drawer.parent) {
                margin = drawer.height < drawer.parent.height ? margin : margin + pageFooter.height
            }

            return margin;
        }
        Behavior on bottomMargin {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    visible: drawer.enabled && (drawer.edge === Qt.LeftEdge || drawer.edge === Qt.RightEdge) && opacity > 0
    width: handleAnchor && handleAnchor.visible ? handleAnchor.width : Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing*2
    height: handleAnchor && handleAnchor.visible ? handleAnchor.height : width
    opacity: drawer.handleVisible ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    transform: Translate {
        id: translateTransform
        x: drawer.handleVisible ? 0 : (drawer.edge === Qt.LeftEdge ? -drawerHandle.width : drawerHandle.width)
        Behavior on x {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: !drawer.handleVisible ? Easing.OutQuad : Easing.InQuad
            }
        }
    }
}
