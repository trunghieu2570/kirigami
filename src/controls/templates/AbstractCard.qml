/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import org.kde.kirigami 2.20 as Kirigami

/**
 * A AbstractCard is the base for cards. A Card is a visual object that serves
 * as an entry point for more detailed information. An abstractCard is empty,
 * providing just the look and the base properties and signals for an ItemDelegate.
 * It can be filled with any custom layout of items, its content is organized
 * in 3 properties: header, contentItem and footer.
 * Use this only when you need particular custom contents, for a standard layout
 * for cards, use the Card component.
 *
 * @see Card
 * @inherit QtQuick.Controls.ItemDelegate
 * @since 2.4
 */
T.ItemDelegate {
    id: root

//BEGIN properties
    /**
     * @brief This property holds an item that serves as a header.
     *
     * This item will be positioned on top if headerOrientation is ``Qt.Vertical``
     * or on the left if it is ``Qt.Horizontal``.
     */
    property alias header: layout.header

    /**
     * @brief This property sets the card's orientation.
     *
     * * ``Qt.Vertical``: the header will be positioned on top
     * * ``Qt.Horizontal``: the header will be positioned on the left (or right if an RTL layout is used)
     *
     * default: ``Qt.Vertical``
     *
     * @property Qt::Orientation headerOrientation
     */
    property int headerOrientation: Qt.Vertical

    /**
     * @brief This property holds an item that serves as a footer.
     *
     * This item will be positioned at the bottom if headerOrientation is ``Qt.Vertical``
     * or on the right if it is ``Qt.Horizontal``.
     */
    property alias footer: layout.footer

    /**
     * @brief This property sets whether clicking or tapping on the card area shows a visual click feedback.
     *
     * Use this if you want to do an action in the onClicked signal handler of the card.
     *
     * default: ``false``
     */
    property bool showClickFeedback: false

    //default property alias __contents: mainItem.data

//END properties

    Layout.fillWidth: true

    implicitWidth: Math.max(background.implicitWidth, layout.implicitWidth) + leftPadding + rightPadding
    implicitHeight: layout.implicitHeight + topPadding + bottomPadding

    hoverEnabled: !Kirigami.Settings.tabletMode && showClickFeedback

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    width: ListView.view ? ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin : undefined
    padding: Kirigami.Units.largeSpacing

    Kirigami.HeaderFooterLayout {
        id: layout
        parent: root
        anchors {
            fill: parent
            margins: root.padding
        }
        contentItem: Kirigami.Padding {
            visible: contentItem
            contentItem: root.contentItem
            topPadding: layout.header ? Kirigami.Units.largeSpacing : 0
            bottomPadding: layout.footer ? Kirigami.Units.largeSpacing : 0
            Connections {
                target: layout.contentItem.contentItem
                onXChanged: layout.contentItem.contentItem.x = 0
                onYChanged: layout.contentItem.contentItem.y = layout.contentItem.topPadding
            }
        }
    }
}
