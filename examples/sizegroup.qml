import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    pageStack.initialPage: Kirigami.Page {
        Kirigami.SizeGroup {
            items: [rect1, rect2, rect3]
            mode: Kirigami.SizeGroup.Width
        }
        RowLayout {
            id: layout
            anchors.fill: parent

            Rectangle {
                id: rect1
                color: "red"
                height: 100
                width: 400
            }
            Rectangle {
                id: rect2
                color: "green"
                height: 100
                implicitWidth: 150
            }
            Rectangle {
                id: rect3
                color: "blue"
                height: 100
                implicitWidth: 200
            }
        }
    }
}
