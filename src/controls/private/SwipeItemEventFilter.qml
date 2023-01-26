/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
import QtQuick 2.5
import org.kde.kirigami 2.4 as Kirigami

MouseArea {
    id: swipeFilter
    anchors {
        right: parent.right
        top: parent.top
        bottom: parent.bottom
    }

    z: 99999
    property Item currentItem
    property real peek

    preventStealing: true
    width: Kirigami.Units.gridUnit
    onPressed: {
        const mapped = mapToItem(parent.flickableItem.contentItem, mouse.x, mouse.y);
        currentItem = parent.flickableItem.itemAt(mapped.x, mapped.y);
    }
    onPositionChanged: {
        const mapped = mapToItem(parent.flickableItem.contentItem, mouse.x, mouse.y);
        currentItem = parent.flickableItem.itemAt(mapped.x, mapped.y);
        peek = 1 - mapped.x / parent.flickableItem.contentItem.width;
    }
}
