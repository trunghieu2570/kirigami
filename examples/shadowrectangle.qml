import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
	color: "white"
	Kirigami.ShadowedRectangle {
		anchors.centerIn: parent

		color: "grey"
		width: parent.width / 1.5
		height: parent.height / 1.5
		opacity: .3
		border.width: Kirigami.Units.smallSpacing * 2
		border.color: "red"
		corners.bottomLeftRadius: Kirigami.Units.largeSpacing
		corners.topRightRadius: Kirigami.Units.largeSpacing * 5
	}
}
