// SPDX-FileCopyrightText: 2023 Tobias Fella <tobias.fella@kde.org>
// SPDX-FileCopyrightText: 2024 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kitemmodels

/**
 * A dialog to let's you do a global search accross your applications
 * documents, chat rooms and more.
 *
 * Example usage for a chat app where we want to quickly search for a room.
 *
 * @code{.qml}
 * import QtQuick
 * import org.kde.kitemmodels as KItemModels
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.SearchDialog {
 *    id: root
 *
 *    onTextChanged: {
 *        sortModel.filterText = text;
 *    }
 *    onAccepted: listView.currentItem.clicked()
 *
 *    emptyText: i18nc("Placeholder message", "No room found.")
 *
 *    model: KItemModels.KSortFilterProxyModel {
 *        id: sortModel
 *
 *        sourceModel: RoomModel { }
 *    }
 *
 *    delegate: RoomDelegate {
 *        onClicked: root.close()
 *    }
 *
 *    Shortcut {
 *        sequence: "Ctrl+K"
 *        onActivated: root.open()
 *    }
 * }
 * @endcode{}
 *
 * @image html searchdialog.html
 *
 * @note This component is unsuitable on mobile. Instead on mobile prefer to
 * use a seperate page for the search.
 *
 * @since Kirigami 6.3
 */
QQC2.Dialog {
    id: root

    /**
     * This property holds an alias to the model of the internal ListView.
     */
    property alias model: listView.model

    /**
     * This property holds an alias to the delegate component of the internal ListView.
     */
    property alias delegate: listView.delegate

    /**
     * This property holds an alias to the currentItem component of the internal ListView.
     */
    property alias currentItem: listView.currentItem

    /**
     * This property holds an alias to the section component of the internal ListView.
     */
    property alias section: listView.section

    /**
     * This property holds an alias to the content of the search field.
     */
    property alias text: searchField.text

    /**
     * This property holds an alias to the left actions of the seach field.
     */
    property alias searchFieldLeftActions: searchField.leftActions

    /**
     * This property holds an alias to the right actions of the seach field.
     */
    property alias searchFieldRightActions: searchField.rightActions

    /**
     * This property holds the number of search results displayed in the internal ListView.
     */
    property alias count: listView.count

    /**
     * This property holds an alias to the placeholder message text displayed
     * when the internal list view is empty.
     */
    property alias emptyText: placeholder.text

    /**
     * This property holds an alias to the placeholder message icon displayed
     * when the internal list view is empty.
     */
    property alias emptyIcon: placeholder.icon

    width: Math.min(Kirigami.Units.gridUnit * 35, parent.width)
    height: Math.min(Kirigami.Units.gridUnit * 20, parent.height)

    padding: 0

    anchors.centerIn: parent

    modal: true

    background: Kirigami.ShadowedRectangle {
        id: rect
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.cornerRadius
        shadow {
            size: radius * 2
            color: Qt.rgba(0, 0, 0, 0.3)
            yOffset: 1
        }
    }

    onOpened: {
        searchField.forceActiveFocus();
        searchField.text = "";
        listView.currentIndex = 0;
    }

    contentItem: ColumnLayout {
        spacing: 0

        Kirigami.SearchField {
            id: searchField

            Layout.fillWidth: true

            background: null

            Layout.margins: Kirigami.Units.smallSpacing

            Keys.onDownPressed: {
                listView.forceActiveFocus();
                if (listView.currentIndex < listView.count - 1) {
                    listView.currentIndex++;
                } else {
                    listView.currentIndex = 0;
                }
            }
            Keys.onUpPressed: {
                if (listView.currentIndex === 0) {
                    listView.currentIndex = listView.count - 1;
                } else {
                    listView.currentIndex--;
                }
            }
            focusSequence: ""
            autoAccept: false

            onAccepted: root.accepted()
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Keys.forwardTo: searchField

            ListView {
                id: listView

                currentIndex: 0
                clip: true
                highlightMoveDuration: 200
                Keys.forwardTo: searchField
                keyNavigationEnabled: true

                Kirigami.PlaceholderMessage {
                    id: placeholder
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.gridUnit * 4
                    icon.name: 'system-search-symbolic'
                    visible: listView.count === 0 && text.length > 0
                }
            }
        }
    }
}
