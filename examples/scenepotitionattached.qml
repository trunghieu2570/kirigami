import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
	id: root
	pageStack.initialPage: Kirigami.Page {
		GridLayout {
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			ColumnLayout {
				Layout.column: 0
				Kirigami.Heading {
					text: "scene position"
					Layout.minimumHeight: Kirigami.Units.gridUnit * 2
				}
				ColumnLayout {
					QQC2.Label {
						// This will be 99 because it is the distance between the top of the window and this Item
						text: "Sublayout 1: " + Kirigami.ScenePosition.y
					}
					QQC2.Label {
						text: "Sublayout 2: " + Kirigami.ScenePosition.y
					}
					QQC2.Label {
						text: "Sublayout 3: " + Kirigami.ScenePosition.y
					}
				}
				Item {
					Layout.minimumHeight: 100
				}
				QQC2.Label {
					text: "Layout 1: " + Kirigami.ScenePosition.y
				}
				QQC2.Label {
					text: "Layout 2: " + Kirigami.ScenePosition.y
				}
				QQC2.Label {
					text: "Layout 3: " + Kirigami.ScenePosition.y
				}
			}
			ColumnLayout {
				Layout.column: 1
				Kirigami.Heading {
					text: "non scene position"
					Layout.minimumHeight: Kirigami.Units.gridUnit * 2
				}
				ColumnLayout {
					ColumnLayout {
						QQC2.Label {
							// This will be 0 because the X and Y properties are relative to the first Item
							text: "Sublayout 1: " + y
						}
						QQC2.Label {
							text: "Sublayout 2: " + y
						}
						QQC2.Label {
							text: "Sublayout 3: " + y
						}
					}
					Item {
						Layout.minimumHeight: 100
					}
					QQC2.Label {
						text: "Layout 1: " + y
					}
					QQC2.Label {
						text: "Layout 2: " + y
					}
					QQC2.Label {
						text: "Layout 3: " + y
					}
				}
			}
		}
	}
}

