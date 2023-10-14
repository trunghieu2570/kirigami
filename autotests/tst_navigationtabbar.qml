/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: root

    name: "NavigationTabBarTest"
    visible: true
    when: windowShown

    width: 500
    height: 500

    Component {
        id: emptyComponent
        Kirigami.NavigationTabBar {}
    }

    Component {
        id: tActionComponent
        T.Action {}
    }

    Component {
        id: kActionComponent
        Kirigami.Action {}
    }

    function test_create() {
        failOnWarning(/error|null/i);
        {
            const tabbar = createTemporaryObject(emptyComponent, this);
            verify(tabbar);
        }
        {
            const tAction = createTemporaryObject(tActionComponent, this);
            const kAction = createTemporaryObject(kActionComponent, this);
            const tabbar = createTemporaryObject(emptyComponent, this, {
                actions: [tAction, kAction],
            });
            verify(tabbar);
            compare(tabbar.visibleActions, [tAction, kAction]);

            const kInvisibleAction = createTemporaryObject(kActionComponent, this, {
                visible: false,
            });
            verify(kInvisibleAction);
            tabbar.actions.push(kInvisibleAction);
            compare(tabbar.visibleActions, [tAction, kAction]);

            tabbar.actions.push(null);
            compare(tabbar.visibleActions, [tAction, kAction]);

            const tAction2 = createTemporaryObject(tActionComponent, this);
            tabbar.actions.push(tAction2);
            compare(tabbar.visibleActions, [tAction, kAction, tAction2]);
        }
    }
}
