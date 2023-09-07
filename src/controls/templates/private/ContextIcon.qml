/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: canvas
    width: height
    height: Kirigami.Units.iconSizes.smallMedium
    property Kirigami.OverlayDrawer drawer
    readonly property real position: drawer?.position ?? 0
    property color color: Kirigami.Theme.textColor
    opacity: 0.8
    layer.enabled: true

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    Item {
        id: iconRoot
        anchors {
            fill: parent
            margins: Kirigami.Units.smallSpacing
        }
        property int thickness: 2
        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                //horizontalCenterOffset: -parent.width/2
                topMargin: (parent.height/2 - iconRoot.thickness/2) * canvas.position
            }
            antialiasing: canvas.position !== 0
            transformOrigin: Item.Center
            width: (1 - canvas.position) * height + canvas.position * (Math.sqrt(2*(parent.width*parent.width)))
            height: iconRoot.thickness
            color: canvas.color
            rotation: 45 * canvas.position
        }

        Rectangle {
            anchors.centerIn: parent
            width: height
            height: iconRoot.thickness
            color: canvas.color
        }


        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
             //   topMargin: -iconRoot.thickness/2 * canvas.position
                bottomMargin: (parent.height/2 - iconRoot.thickness/2) * canvas.position
            }
            antialiasing: canvas.position !== 0
            transformOrigin: Item.Center
            width: (1 - canvas.position) * height + canvas.position * (Math.sqrt(2*(parent.width*parent.width)))
            height: iconRoot.thickness
            color: canvas.color
            rotation: -45 * canvas.position
        }
    }
}

