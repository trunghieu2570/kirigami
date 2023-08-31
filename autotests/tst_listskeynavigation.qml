/*
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtTest 1.0
import "../tests"

TestCase {
    id: testCase
    width: 400
    height: 400
    name: "KeyboardListsNavigation"

    Component {
        id: mainComponent
        KeyboardListTest {
            id: window

            width: 480
            height: 360

            readonly property SignalSpy spyCurrentIndex: SignalSpy {
                target: window.pageStack.currentItem?.flickable ?? null
                signalName: "currentIndexChanged"
            }
        }
    }

    // The following methods are adaptation of QtTest internals

    function waitForWindowActive(window: Window) {
        tryVerify(() => window.active);
    }

    function ensureWindowShown(window: Window) {
        window.requestActivate();
        waitForWindowActive(window);
        wait(0);
    }

    function test_press() {
        const window = createTemporaryObject(mainComponent, this);
        verify(window);
        const spy = window.spyCurrentIndex;
        verify(spy.valid);

        ensureWindowShown(window);

        compare(window.pageStack.depth, 1);
        compare(window.pageStack.currentIndex, 0);

        compare(window.pageStack.currentItem.flickable.currentIndex, 0);
        keyClick(Qt.Key_Down);
        compare(spy.count, 1);
        compare(window.pageStack.currentItem.flickable.currentIndex, 1);
    }
}
