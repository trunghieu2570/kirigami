import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.17 as Kirigami

Kirigami.ApplicationWindow {
    height: 720
    width: 360

    Kirigami.OverlaySheet
    {
        id: sheet
        title: "Certificate Viewer"

        ColumnLayout {
            QQC2.DialogButtonBox {
                id: ppp
                Layout.fillWidth: true
                QQC2.Button {
                    id: butt
                    QQC2.DialogButtonBox.buttonRole: QQC2.DialogButtonBox.ActionRole
                    text: "Export..."
                }

                QQC2.Button {
                    QQC2.DialogButtonBox.buttonRole: QQC2.DialogButtonBox.DestructiveRole
                    text: "Close"
                    icon.name: "dialog-close"
                }
            }
        }
    }

    Timer {
        interval: 150
        running: true
        onTriggered: sheet.open()
    }
}
