/* SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    id: root
    readonly property real hstep: wheelHandler.horizontalStepSize
    readonly property real vstep: wheelHandler.verticalStepSize
    readonly property real pageWidth: flickable.width - flickable.leftMargin - flickable.rightMargin
    readonly property real pageHeight: flickable.height - flickable.topMargin - flickable.bottomMargin
    readonly property real contentWidth: flickable.contentWidth
    readonly property real contentHeight: flickable.contentHeight
    property alias wheelHandler: wheelHandler
    property alias flickable: flickable

    name: "WheelHandler invokable functions"
    visible: true
    when: windowShown
    width: flickable.implicitWidth
    height: flickable.implicitHeight

    function test_Invokables() {
        const originalX = flickable.contentX
        const originalY = flickable.contentY
        let x = originalX
        let y = originalY

        wheelHandler.scrollRight()
        verify(flickable.contentX === x + hstep, "scrollRight()")
        x = flickable.contentX

        wheelHandler.scrollLeft()
        verify(flickable.contentX === x - hstep, "scrollLeft()")
        x = flickable.contentX

        wheelHandler.scrollDown()
        verify(flickable.contentY === y + vstep, "scrollDown()")
        y = flickable.contentY

        wheelHandler.scrollUp()
        verify(flickable.contentY === y - vstep, "scrollUp()")
        y = flickable.contentY

        wheelHandler.scrollRight(101)
        verify(flickable.contentX === x + 101, "scrollRight(101)")
        x = flickable.contentX

        wheelHandler.scrollLeft(101)
        verify(flickable.contentX === x - 101, "scrollLeft(101)")
        x = flickable.contentX

        wheelHandler.scrollDown(101)
        verify(flickable.contentY === y + 101, "scrollDown(101)")
        y = flickable.contentY

        wheelHandler.scrollUp(101)
        verify(flickable.contentY === y - 101, "scrollUp(101)")
        y = flickable.contentY
    }

    ScrollableFlickable {
        id: flickable
        anchors.fill: parent
        Kirigami.WheelHandler {
            id: wheelHandler
            target: flickable
        }
    }
}

