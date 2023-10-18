/*
 *  SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Controls as QQC2

/**
 * @brief An item delegate for the primitive ListView component.
 *
 * It's intended to make all listviews look coherent.
 *
 * @inherit QtQuick.Controls.ItemDelegate
 */
QQC2.ItemDelegate {
    id: listItem

//BEGIN properties
    /**
     * @brief This property sets whether the item should emit signals related to mouse interaction.
     *
     * default: ``true``
     *
     * @deprecated This will be removed in KF6.
     */
    property bool supportsMouseEvents: hoverEnabled

    /**
     * @brief This property tells whether the cursor is currently hovering over the item.
     *
     * On mobile touch devices, this will be true only when pressed.
     *
     * @see QtQuick.Templates.ItemDelegate::hovered
     * @deprecated This will be removed in KF6; use the ``hovered``  property instead.
     * @property bool containsMouse
     */
    property alias containsMouse: listItem.hovered

    /**
     * @brief This property sets whether instances of this list item will alternate
     * between two colors, helping readability.
     *
     * It is suggested to use this only when implementing a view with multiple columns.
     *
     * default: ``false``
     *
     * @since 2.7
     */
    property bool alternatingBackground: false

    /**
     * @brief This property sets whether this item is a section delegate.
     *
     * Setting this to true will make the list item look like a "title" for items under it.
     *
     * default: ``false``
     *
     * @see ListSectionHeader
     */
    property bool sectionDelegate: false

    /**
     * @brief This property sets whether the separator is visible.
     *
     * The separator is a line between this and the item under it.
     *
     * default: ``false``
     */
    property bool separatorVisible: false

    /**
     * @brief This property holds list item's background color.
     *
     * It is advised to use the default value.
     * default: ``"transparent"``
     */
    property color backgroundColor: "transparent"

    /**
     * @brief This property holds the background color to be used when
     * background alternating is enabled.
     *
     * It is advised to use the default value.
     * default: ``Kirigami.Theme.alternateBackgroundColor``
     *
     * @since 2.7
     */
    property color alternateBackgroundColor: Kirigami.Theme.alternateBackgroundColor

    /**
     * @brief This property holds the color of the background
     * when the item is pressed or selected.
     *
     * It is advised to use the default value.
     * default: ``Kirigami.Theme.highlightColor``
     */
    property color activeBackgroundColor: Kirigami.Theme.highlightColor

    /**
     * @brief This property holds the color of the text in the item.
     *
     * It is advised to use the default value.
     * default: ``Kirigami.Theme.textColor``
     *
     * If custom text elements are inserted in an AbstractListItem,
     * their color will have to be manually set with this property.
     */
    property color textColor: Kirigami.Theme.textColor

    /**
     * @brief This property holds the color of the text when the item is pressed or selected.
     *
     * It is advised to use the default value.
     * default: ``Kirigami.Theme.highlightedTextColor``
     *
     * If custom text elements are inserted in an AbstractListItem,
     * their color will have to be manually set with this property.
     */
    property color activeTextColor: Kirigami.Theme.highlightedTextColor

    default property alias _default: listItem.contentItem

//END properties

    Kirigami.Theme.useAlternateBackgroundColor: alternatingBackground
    activeFocusOnTab: ListView.view ? false : true

    onClicked: {
        if (ListView.view && typeof index !== "undefined") {
            ListView.view.currentIndex = index;
        }
    }
    //Theme.inherit: false
    //Theme.colorSet: Kirigami.Theme.View

    padding: Kirigami.Settings.tabletMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing
    topPadding: undefined
    leftPadding: undefined
    rightPadding: undefined
    bottomPadding: undefined
    verticalPadding: undefined
    horizontalPadding: padding * 2

    implicitWidth: contentItem ? implicitContentWidth + leftPadding + rightPadding : Kirigami.Units.gridUnit * 12
    implicitHeight: contentItem ? implicitContentHeight + topPadding + bottomPadding : 0

    width: parent?.width > 0 ? parent.width : implicitWidth
    height: implicitHeight

    Layout.fillWidth: true

    opacity: enabled ? 1 : 0.6

    onVisibleChanged: {
        if (visible) {
            height = Qt.binding(() => implicitHeight);
        } else {
            if (ListView.view?.visible) {
                height = 0;
            }
        }
    }

    hoverEnabled: true

    Accessible.role: Accessible.ListItem
    highlighted: focus && ListView.isCurrentItem && (ListView.view?.keyNavigationEnabled ?? false)
}
