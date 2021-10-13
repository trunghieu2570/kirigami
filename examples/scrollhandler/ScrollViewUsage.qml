import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

T.ScrollView {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    leftPadding: mirrored && T.ScrollBar.vertical.visible && !Kirigami.Settings.isMobile ? T.ScrollBar.vertical.width : 0
    rightPadding: !mirrored && T.ScrollBar.vertical.visible && !Kirigami.Settings.isMobile ? T.ScrollBar.vertical.width : 0
    bottomPadding: T.ScrollBar.horizontal.visible && !Kirigami.Settings.isMobile ? T.ScrollBar.horizontal.height : 0

    data: [
        Kirigami.ScrollHandler {
            id: scrollHandler
            target: control.contentItem
            verticalScrollBar: control.T.ScrollBar.vertical
            horizontalScrollBar: control.T.ScrollBar.horizontal
        }
    ]


    T.ScrollBar.vertical: QQC2.ScrollBar {
        parent: control
        x: control.mirrored ? 0 : control.width - width
        y: control.topPadding
        height: control.availableHeight
        active: control.T.ScrollBar.vertical.active
    }

    T.ScrollBar.horizontal: QQC2.ScrollBar {
        parent: control
        x: control.leftPadding
        y: control.height - height
        width: control.availableWidth
        active: control.T.ScrollBar.horizontal.active
    }

    //contentWidth: grid.implicitWidth
//     contentHeight: grid.implicitHeight
    contentItem: Flickable {
        Grid {
            id: grid
            columns: Math.sqrt(repeater.count)
            Repeater {
                id: repeater
                model: 1000
                delegate: Rectangle {
                    implicitWidth: 60
                    implicitHeight: 60
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
