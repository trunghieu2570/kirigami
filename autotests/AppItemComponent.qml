/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationItem {
    property alias headerItem: headerItem
    property alias topItem: topItem

    width: 500
    height: 500
    visible: true

    globalDrawer: Kirigami.GlobalDrawer {
        // drawerOpen: true
        handleVisible: false

        header: Rectangle {
            id: headerItem
            implicitHeight: 50
            implicitWidth: 50
            color: "red"
            radius: 20 // to see its bounds
        }

        // Create some item which we can use to measure actual header height
        Rectangle {
            id: topItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "green"
            radius: 20 // to see its bounds
        }
    }
}
