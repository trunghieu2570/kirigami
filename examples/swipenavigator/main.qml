import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    Kirigami.SwipeNavigator {
        anchors.fill: parent
        initialIndex: 2
        header: QQC2.Button {
            text: "Header"
        }
        footer: QQC2.Button {
            text: "Footer"
        }
        Kirigami.Page {
            icon.name: "globe"
            title: "World Clocks"
        }
        Kirigami.Page {
            icon.name: "clock"
            title: "Alarms"
            needsAttention: true
        }
        Kirigami.Page {
            icon.name: "clock"
            title: "Stopwatch"
        }
        Kirigami.Page {
            icon.name: "clock"
            title: "Timers"
            progress: 0.5
        }
    }
}
