import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    pageStack.initialPage: [page1, page2]

    Kirigami.Page {
        id: page1
        RowLayout {
            QQC2.Button {
                text: "add card"
                onClicked: cardsView.model.append({});
            }

            QQC2.Button {
                text: "remove card"
                onClicked: {
                    if (cardsView.model.count > 0) {
                        cardsView.model.remove(cardsView.model.count-1)
                    }
                }
            }
        }
    }
    Kirigami.ScrollablePage {
        id: page2
        Kirigami.CardsListView {
            id: cardsView
            anchors.fill: parent
            model: ListModel {}
            delegate: Kirigami.Card {
                banner.title: index
                contentItem: QQC2.Label {
                    text: "lorem ipsum"
                }
            }
        }
    }
}
