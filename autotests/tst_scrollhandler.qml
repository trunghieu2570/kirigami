import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import QtTest 1.15

TestCase {
    id: root
    readonly property real hstep:  scrollHandler.horizontalStepMode == Kirigami.ScrollHandler.PixelStepMode ?
        scrollHandler.horizontalStepSize : scrollHandler.horizontalStepSize * flickable.contentWidth
    readonly property real vstep: scrollHandler.verticalStepMode == Kirigami.ScrollHandler.PixelStepMode ?
        scrollHandler.verticalStepSize : scrollHandler.verticalStepSize * flickable.contentHeight
    readonly property real pageWidth: flickable.width - flickable.leftMargin - flickable.rightMargin
    readonly property real pageHeight: flickable.height - flickable.topMargin - flickable.bottomMargin
    readonly property real contentWidth: flickable.contentWidth
    readonly property real contentHeight: flickable.contentHeight

    name: "ScrollHandlerTests"
    visible: true
    when: windowShown
    width: 600 + flickable.leftMargin + flickable.rightMargin
    height: 600 + flickable.topMargin + flickable.bottomMargin

    function test_WheelScroll() {
        let x = flickable.contentX
        let y = flickable.contentY
        mouseWheel(flickable, flickable.leftMargin + 10, 10, -120, -120, Qt.NoButton)
        verify(flickable.contentX === x + hstep, "+xTick")
        x = flickable.contentX
        verify(flickable.contentY === y + vstep, "+yTick")
        y = flickable.contentY

        mouseWheel(flickable, flickable.leftMargin + 10, 10, 120, 120, Qt.NoButton)
        verify(flickable.contentX === x - hstep, "-xTick")
        x = flickable.contentX
        verify(flickable.contentY === y - vstep, "-yTick")
        y = flickable.contentY

        mouseWheel(flickable, flickable.leftMargin + 10, 10, 0, -120, Qt.NoButton, scrollHandler.horizontalScrollModifiers)
        verify(flickable.contentX === x + hstep, "+h_yTick")
        x = flickable.contentX
        verify(flickable.contentY === y, "no +yTick")

        mouseWheel(flickable, flickable.leftMargin + 10, 10, 0, 120, Qt.NoButton, scrollHandler.horizontalScrollModifiers)
        verify(flickable.contentX === x - hstep, "-h_yTick")
        x = flickable.contentX
        verify(flickable.contentY === y, "no -yTick")

        mouseWheel(flickable, flickable.leftMargin + 10, 10, -120, -120, Qt.NoButton, scrollHandler.pageScrollModifiers)
        verify(flickable.contentX === x + pageWidth, "+xPage")
        x = flickable.contentX
        verify(flickable.contentY === y + pageHeight, "+yPage")
        y = flickable.contentY

        mouseWheel(flickable, flickable.leftMargin + 10, 10, 120, 120, Qt.NoButton, scrollHandler.pageScrollModifiers)
        verify(flickable.contentX === x - pageWidth, "-xPage")
        x = flickable.contentX
        verify(flickable.contentY === y - pageHeight, "-yPage")
        y = flickable.contentY

        mouseWheel(flickable, flickable.leftMargin + 10, 10, 0, -120, Qt.NoButton,
                   scrollHandler.horizontalScrollModifiers | scrollHandler.pageScrollModifiers)
        verify(flickable.contentX === x + pageWidth, "+h_yPage")
        x = flickable.contentX
        verify(flickable.contentY === y, "no +yPage")

        mouseWheel(flickable, flickable.leftMargin + 10, 10, 0, 120, Qt.NoButton,
                   scrollHandler.horizontalScrollModifiers | scrollHandler.pageScrollModifiers)
        verify(flickable.contentX === x - pageWidth, "-h_yPage")
        x = flickable.contentX
        verify(flickable.contentY === y, "no -yPage")
    }

    function test_KeyboardScroll() {
        const originalX = flickable.contentX
        const originalY = flickable.contentY
        let x = originalX
        let y = originalY
        keyClick(Qt.Key_Right)
        verify(flickable.contentX === x + hstep, "Key_Right")
        x = flickable.contentX

        keyClick(Qt.Key_Left)
        verify(flickable.contentX === x - hstep, "Key_Left")
        x = flickable.contentX

        keyClick(Qt.Key_Down)
        verify(flickable.contentY === y + vstep, "Key_Down")
        y = flickable.contentY

        keyClick(Qt.Key_Up)
        verify(flickable.contentY === y - vstep, "Key_Up")
        y = flickable.contentY

        keyClick(Qt.Key_PageDown)
        verify(flickable.contentY === y + pageHeight, "Key_PageDown")
        y = flickable.contentY

        keyClick(Qt.Key_PageUp)
        verify(flickable.contentY === y - pageHeight, "Key_PageUp")
        y = flickable.contentY

        keyClick(Qt.Key_End)
        verify(flickable.contentY === contentHeight - pageHeight, "Key_End")
        y = flickable.contentY

        keyClick(Qt.Key_Home)
        verify(flickable.contentY === originalY, "Key_Home")
        y = flickable.contentY

        keyClick(Qt.Key_PageDown, scrollHandler.horizontalScrollModifiers)
        verify(flickable.contentX === x + pageWidth, "h_Key_PageDown")
        x = flickable.contentX

        keyClick(Qt.Key_PageUp, scrollHandler.horizontalScrollModifiers)
        verify(flickable.contentX === x - pageWidth, "h_Key_PageUp")
        x = flickable.contentX

        keyClick(Qt.Key_End, scrollHandler.horizontalScrollModifiers)
        verify(flickable.contentX === contentWidth - pageWidth, "h_Key_End")
        x = flickable.contentX

        keyClick(Qt.Key_Home, scrollHandler.horizontalScrollModifiers)
        verify(flickable.contentX === originalX, "h_Key_Home")
    }

    function test_MouseFlick() {
        const x = flickable.contentX
        const y = flickable.contentY
        mousePress(flickable, flickable.leftMargin + 10, 10)
        mouseMove(flickable)
        mouseRelease(flickable)
        verify(flickable.contentX === x && flickable.contentY === y, "not moved")
    }

    // NOTE: Unfortunately, this test can't work. Flickable does not handle touch events, only mouse events synthesized from touch events
    // TODO: Uncomment if Flickable is ever able to use touch events.
    /*function test_TouchFlick() {
        const x = flickable.contentX, y = flickable.contentY
        let touch = touchEvent(flickable)
        // Press on center.
        touch.press(0, flickable)
        touch.commit()
        // Move a bit towards top left.
        touch.move(0, flickable, flickable.width/2 - 50, flickable.height/2 - 50)
        touch.commit()
        // Release at the spot we moved to.
        touch.release(0, flickable, flickable.width/2 - 50, flickable.height/2 - 50)
        touch.commit()
        verify(flickable.contentX !== x || flickable.contentY !== y, "moved")
    }*/

    function test_MouseScrollBars() {
        const x = flickable.contentX, y = flickable.contentY
        mousePress(flickable, flickable.leftMargin + 10, 10)
        mouseMove(flickable)
        const interactive = flickable.QQC2.ScrollBar.vertical.interactive || flickable.QQC2.ScrollBar.horizontal.interactive
        mouseRelease(flickable)
        verify(interactive, "interactive scrollbars")
    }

    function test_TouchScrollBars() {
        const x = flickable.contentX, y = flickable.contentY
        let touch = touchEvent(flickable)
        touch.press(0, flickable, flickable.leftMargin + 10, 10)
        touch.commit()
        touch.move(0, flickable)
        touch.commit()
        const interactive = flickable.QQC2.ScrollBar.vertical.interactive || flickable.QQC2.ScrollBar.horizontal.interactive
        touch.release(0, flickable)
        touch.commit()
        verify(!interactive, "no interactive scrollbars")
    }

    Flickable {
        id: flickable
        focus: true
        anchors.fill: parent
        Kirigami.ScrollHandler {
            id: scrollHandler
            target: flickable
            verticalScrollBar: flickable.QQC2.ScrollBar.vertical
            horizontalScrollBar: flickable.QQC2.ScrollBar.horizontal
            filterMouseEvents: true
            keyNavigationEnabled: true
        }
        leftMargin: !QQC2.ScrollBar.vertical.mirrored ? 0 : QQC2.ScrollBar.vertical.width
        rightMargin: QQC2.ScrollBar.vertical.mirrored ? 0 : QQC2.ScrollBar.vertical.width
        bottomMargin: QQC2.ScrollBar.horizontal.height
        QQC2.ScrollBar.vertical: QQC2.ScrollBar {
            parent: flickable.parent
            anchors.right: flickable.right
            anchors.top: flickable.top
            anchors.bottom: flickable.bottom
            anchors.bottomMargin: flickable.QQC2.ScrollBar.horizontal.height
            active: flickable.QQC2.ScrollBar.vertical.active
            stepSize: scrollHandler.verticalStepSize / flickable.contentHeight
        }
        QQC2.ScrollBar.horizontal: QQC2.ScrollBar {
            parent: flickable.parent
            anchors.left: flickable.left
            anchors.right: flickable.right
            anchors.bottom: flickable.bottom
            anchors.rightMargin: flickable.QQC2.ScrollBar.vertical.width
            active: flickable.QQC2.ScrollBar.horizontal.active
            stepSize: scrollHandler.horizontalStepSize / flickable.contentWidth
        }
        contentWidth: grid.implicitWidth
        contentHeight: grid.implicitHeight
        Grid {
            id: grid
            columns: Math.sqrt(visibleChildren.length)
            Repeater {
                model: 500
                delegate: Rectangle {
                    implicitHeight: 60
                    implicitWidth: 60
                    gradient: Gradient {
                        orientation: index % 2 ? Gradient.Vertical : Gradient.Horizontal
                        GradientStop { position: 0; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                        GradientStop { position: 1; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                    }
                }
            }
            QQC2.Button {
                id: enableSliderButton
                width: 60
                height: 60
                contentItem: QQC2.Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "Enable Slider"
                    wrapMode: Text.Wrap
                }
                checked: true
            }
            QQC2.Slider {
                wheelEnabled: !scrollHandler.scrolling
                enabled: enableSliderButton.checked
                width: 60
                height: 60
            }
            Repeater {
                model: 500
                delegate: Rectangle {
                    implicitHeight: 60
                    implicitWidth: 60
                    gradient: Gradient {
                        orientation: index % 2 ? Gradient.Vertical : Gradient.Horizontal
                        GradientStop { position: 0; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                        GradientStop { position: 1; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                    }
                }
            }
        }
    }
}
