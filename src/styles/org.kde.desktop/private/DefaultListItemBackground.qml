/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.12

Rectangle {
    id: background

    property var leadingWidth

    color: listItem.alternatingBackground && index%2 ? listItem.alternateBackgroundColor : listItem.backgroundColor
    visible: listItem.ListView.view ? listItem.ListView.view.highlight === null : true

    Rectangle {
        id: internal
        property bool indicateActiveFocus: listItem.pressed || Settings.tabletMode || listItem.activeFocus || (listItem.ListView.view ? listItem.ListView.view.activeFocus : false)

        anchors.fill: parent
        anchors.margins: 2
        border.color: Theme.focusColor
        border.width: 1
        radius: 3

        color: Qt.rgba(Theme.focusColor.r, Theme.focusColor.g, Theme.focusColor.b, 0.3)
        opacity: {
            if (listItem.hovered || listItem.activeFocus) {
                return 1
            } else if (listItem.checked || listItem.highlighted || (listItem.supportsMouseEvents && listItem.pressed && !listItem.checked && !listItem.sectionDelegate)) {
                return 0.5
            } else {
                return 0
            }
        }

        Behavior on opacity { NumberAnimation { duration: Units.shortDuration } }
    }
}

