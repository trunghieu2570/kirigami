/*
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
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
    name: "KeyboardNavigation"

    KeyboardTest {
        id: mainWindowPageStack
    }

    SignalSpy {
        id: spyLastKey
        target: mainWindowPageStack.currentItem
        signalName: "lastKeyChanged"
    }

    function test_press() {
        waitForRendering(testCase)
        compare(mainWindowPageStack.depth, 2)
        compare(mainWindowPageStack.currentIndex, 1)
        keyClick("A")
        spyLastKey.wait()
        compare(mainWindowPageStack.currentItem.lastKey, "A")
        keyClick(Qt.Key_Left, Qt.AltModifier)
        compare(mainWindowPageStack.currentIndex, 0)
        compare(mainWindowPageStack.currentItem.lastKey, "")
        keyClick("B")
        spyLastKey.wait()
        compare(mainWindowPageStack.currentItem.lastKey, "B")
    }
}
