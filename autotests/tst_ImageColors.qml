/*
 *  SPDX-FileCopyrightText: 2023 Fushan Wen <qydwhotmail@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.1-or-later
 */

import QtQuick
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: testCase
    name: "ImageColorsTest"

    width: 400
    height: 400
    visible: true

    when: windowShown

    Component {
        id: windowComponent
        Window {
            id: window
            width: 100
            height: 100
            visible: true
            property alias colorArea: colorArea
            property alias imageColors: imageColors
            property alias paletteChangedSpy: paletteChangedSpy
            Rectangle {
                id: colorArea
                anchors.fill: parent
                color: "transparent"
            }
            Kirigami.ImageColors {
                id: imageColors
                source: colorArea
            }
            SignalSpy {
                id: paletteChangedSpy
                target: imageColors
                signalName: "paletteChanged"
            }
        }
    }


    function test_extractColors() {
        const window = createTemporaryObject(windowComponent, testCase)

        tryVerify(() => window.visible)

        window.colorArea.color = Qt.rgba(1, 0, 0)
        window.imageColors.update()
        window.paletteChangedSpy.wait()
        compare(window.paletteChangedSpy.count, 1)
        compare(window.imageColors.palette.length, 1)
        compare(window.imageColors.dominant, window.colorArea.color)
    }
}
