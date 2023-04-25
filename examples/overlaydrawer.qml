import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
	Kirigami.OverlayDrawer {
		id: drawer

		edge: Qt.BottomEdge

		contentItem: RowLayout {
			QQC2.Button {
				text: "Close"
				onClicked: drawer.close()
			}
		}
	}

	pageStack.initialPage: Kirigami.Page {
		RowLayout {
			QQC2.Button {
				text: "Open drawer"
				onClicked: {
					drawer.modal = isModal.checked
					drawer.open()
				}
			}
			QQC2.CheckBox {
				id: isModal
				text: "Drawer is modal?"
			}
		}
	}
}

