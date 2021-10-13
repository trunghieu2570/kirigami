import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

QQC2.ApplicationWindow {
    id: root
    width: 600 + flickable.leftMargin + flickable.rightMargin
    height: 600 + flickable.topMargin + flickable.bottomMargin
    color: palette.window
    Flickable {
        id: flickable
        anchors.fill: parent
        Kirigami.ScrollHandler {
            id: scrollHandler
            target: flickable
            verticalScrollBar: flickable.QQC2.ScrollBar.vertical
            horizontalScrollBar: flickable.QQC2.ScrollBar.horizontal
            filterMouseEvents: true
            filterKeyEvents: true
        }
        leftMargin: QQC2.ScrollBar.vertical.mirrored && QQC2.ScrollBar.vertical.visible ?
            QQC2.ScrollBar.vertical.implicitWidth : 0
        rightMargin: !QQC2.ScrollBar.vertical.mirrored && QQC2.ScrollBar.vertical.visible ?
            QQC2.ScrollBar.vertical.implicitWidth : 0
        bottomMargin: QQC2.ScrollBar.horizontal.visible ?
            QQC2.ScrollBar.horizontal.implicitHeight : 0
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
                model: 1000
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
