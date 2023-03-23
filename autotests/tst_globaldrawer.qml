/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import QtTest 1.15

Kirigami.ApplicationItem {
    id: root

    width: 500
    height: 500
    visible: true

    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer

        drawerOpen: true

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

    TestCase {
        name: "GlobalDrawerHeader"
        when: windowShown

        function test_headerItemVisibility() {
            const overlay = QQC2.Overlay.overlay;
            verify(headerItem.height !== 0);

            // Due to margins, position won't be exactly zero...
            let position = topItem.mapToItem(overlay, 0, 0);
            verify(position.y > 0);
            const oldY = position.y;

            // ...but with visible header it would be greater than with invisible.
            headerItem.visible = false;
            waitForRendering(overlay);
            position = topItem.mapToItem(overlay, 0, 0);
            verify(position.y < oldY);

            // And now return it back to where we started.
            headerItem.visible = true;
            waitForRendering(overlay);
            position = topItem.mapToItem(overlay, 0, 0);
            verify(position.y === oldY);
        }
    }
}
