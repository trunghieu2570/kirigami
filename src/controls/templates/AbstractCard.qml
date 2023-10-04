/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

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
     * This item will be positioned on top.
     */
    property Item header

    /**
     * @brief This property holds an item that serves as a footer.
     *
     * This item will be positioned at the bottom
     */
    property Item footer

    /**
     * @brief This property sets whether clicking or tapping on the card area shows a visual click feedback.
     *
     * Use this if you want to do an action in the onClicked signal handler of the card.
     *
     * default: ``false``
     */
    property bool showClickFeedback: false
//END properties

    Layout.fillWidth: true

    implicitWidth: Math.max(background.implicitWidth, mainLayout.implicitWidth) + leftPadding + rightPadding
    implicitHeight: mainLayout.implicitHeight + topPadding + bottomPadding

    hoverEnabled: !Kirigami.Settings.tabletMode && showClickFeedback
    // if it's in a CardLayout, try to expand horizontal cards to both columns
    Layout.columnSpan: 1

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    horizontalPadding: Kirigami.Units.largeSpacing
    verticalPadding: contentItemParent.children.length > 0 ? Kirigami.Units.largeSpacing : 0

    width: ListView.view ? ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin : undefined

    GridLayout {
        id: mainLayout
        rowSpacing: root.topPadding
        columnSpacing: root.leftPadding
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: root.topPadding
            leftMargin: root.leftPadding
            rightMargin: root.rightPadding
            bottomMargin: root.bottomPadding
        }
        columns: 1
        function preferredHeight(item) {
            if (!item) {
                return 0;
            }
            if (item.Layout.preferredHeight > 0) {
                return item.Layout.preferredHeight;
            }
            return item.implicitHeight;
        }
        Item {
            id: headerParent
            Layout.fillWidth: true
            Layout.rowSpan: 1
            Layout.preferredWidth: root.header?.implicitWidth ?? 0
            Layout.preferredHeight: mainLayout.preferredHeight(root.header)
            visible: children.length > 0
        }
        Item {
            id: contentItemParent
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: root.topPadding
            Layout.bottomMargin: root.bottomPadding
            Layout.preferredWidth: root.contentItem?.implicitWidth ?? 0
            Layout.preferredHeight: mainLayout.preferredHeight(root.contentItem)
            visible: children.length > 0
        }
        Item {
            id: footerParent
            Layout.fillWidth: true
            Layout.preferredWidth: root.footer?.implicitWidth ?? 0
            Layout.preferredHeight: mainLayout.preferredHeight(root.footer)
            visible: children.length > 0
        }
    }

//BEGIN signal handlers
    onContentItemChanged: {
        if (!contentItem) {
            return;
        }

        contentItem.parent = contentItemParent;
        contentItem.anchors.fill = contentItemParent;
    }
    onHeaderChanged: {
        if (!header) {
            return;
        }

        header.parent = headerParent;
        header.anchors.fill = headerParent;
    }
    onFooterChanged: {
        if (!footer) {
            return;
        }

        //make the footer always looking it's at the bottom of the card
        footer.parent = footerParent;
        footer.anchors.top = footerParent.top;
        footer.anchors.left = footerParent.left;
        footer.anchors.right = footerParent.right;
        footer.anchors.topMargin = Qt.binding(() => {
            return height - topPadding - bottomPadding - footerParent.y - footerParent.height;
        });
    }
    Component.onCompleted: {
        contentItemChanged();
    }
//END signal handlers
}
