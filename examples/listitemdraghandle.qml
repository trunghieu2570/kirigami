import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
	pageStack.initialPage: Kirigami.ScrollablePage {
		ListView {
			id: mainList
			model: ListModel {
				ListElement {
					someText: "Item 1"
				}
				ListElement {
					someText: "Item 2"
				}
				ListElement {
					someText: "Item 3"
				}
			}

			delegate: Item {
				width: mainList.width
				height: listItemComponent.implicitHeight
				Kirigami.AbstractListItem {
					id: listItemComponent
					contentItem: RowLayout {
						Kirigami.ListItemDragHandle {
							listItem: listItemComponent
							listView: mainList
							onMoveRequested: mainList.model.move(oldIndex, newIndex, 1)
						}
						QQC2.Label {
							text: model.someText + " at index " + index
							Layout.fillWidth: true
						}
					}
				}
			}

			moveDisplaced: Transition {
				YAnimator {
					duration: Kirigami.Units.longDuration
					easing.type: Easing.InOutQuad
				}
			}
		}
	}
}
