/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtTest

// Inline components are needed because ApplicationItem and
// ApplicationWindow types expect themselves to be top-level components.
TestCase {
    name: "GlobalDrawerHeader"
    visible: true
    when: windowShown

    width: 500
    height: 500

    Component {
        id: appItemComponent
        AppItemComponent {}
    }

    function test_headerItemVisibility() {
        print("AAAAA", Qt.platform.os);
        const app = createTemporaryObject(appItemComponent, this);
        verify(app);
        // const { headerItem, topItem } = app;

        // waitForRendering(app.globalDrawer.contentItem);

        // const overlay = QQC2.Overlay.overlay;
        // verify(headerItem.height !== 0);

        // // Due to margins, position won't be exactly zero...
        // const position = topItem.mapToItem(overlay, 0, 0);
        // verify(position.y > 0);
        // const oldY = position.y;

        // // ...but with visible header it would be greater than with invisible.
        // headerItem.visible = false;
        // tryVerify(() => {
        //     const position = topItem.mapToItem(overlay, 0, 0);
        //     return position.y < oldY;
        // });

        // // And now return it back to where we started.
        // headerItem.visible = true;
        // tryVerify(() => {
        //     const position = topItem.mapToItem(overlay, 0, 0);
        //     return position.y === oldY;
        // });
    }
}
