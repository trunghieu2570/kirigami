import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
	QQC2.TextField {
		Kirigami.FormData.label: "Label:"
	}
	Kirigami.Separator {
		Kirigami.FormData.label: "Section Title"
		Kirigami.FormData.isSection: true
	}
	QQC2.TextField {
		Kirigami.FormData.label: "Label:"
	}
	QQC2.TextField {
	}
	QQC2.Button {
		text: "button"
		Layout.fillWidth: true
		Kirigami.FormData.label: "Button label: "
	}
}
