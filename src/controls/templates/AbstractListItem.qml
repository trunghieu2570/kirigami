/*
 *  SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4
// NOTE: This must stay at 2.2 until KF6 due to retrocompatibility of the "icon" property
import QtQuick.Templates 2.2 as T2
import QtQuick.Templates 2.4 as QQC2

/**
 * @brief An item delegate for the primitive ListView component.
 *
 * It's intended to make all listviews look coherent.
 *
 * @inherit QtQuick.Controls.ItemDelegate
 */
T2.ItemDelegate {
    id: listItem

    /**
     * @brief Holds if the item emits signals related to mouse interaction.
     *
     * The default value is false.
     *
     * @deprecated This will be removed in KF6.
     */
    property bool supportsMouseEvents: hoverEnabled

    /**
     * @brief True when the user hovers the cursor over the list item.
     *
     * On mobile touch devices this will be true only when pressed
     *
     * @see QtQuick::Templates::ItemDelegate::hovered
     * @deprecated This will be removed in KF6.
     * @property bool containsMouse
     */
    property alias containsMouse: listItem.hovered

    /**
     * @brief If true the background of the list items will be alternating between two
     * colors, helping readability with multiple column views.
     *
     * Use it only when implementing a view which shows data visually in multiple columns
     *
     * @since 2.7
     */
    property bool alternatingBackground: false

    /**
     * @brief If true the item will be a delegate for a section, so will look like a
     * "title" for the items under it.
     */
    property bool sectionDelegate: false

    /**
     * @brief True if the separator between items is visible.
     *
     * default: true
     */
    property bool separatorVisible: true

    /**
     * @brief Color for the text in the item.
     *
     * It is advised to leave the default value (Theme.textColor)
     *
     * If custom text elements are inserted in an AbstractListItem,
     * their color property will have to be manually bound with this property
     */
    property color textColor: Theme.textColor

    /**
     * @brief Color for the background of the item.
     *
     * It is advised to leave the default value (Theme.viewBackgroundColor)
     */
    property color backgroundColor: "transparent"

    /**
     * @brief The background color to use if alternatingBackground is true.
     *
     * It is advised to leave the default.
     *
     * @since 2.7
     */
    property color alternateBackgroundColor: Theme.alternateBackgroundColor

    /**
     * @brief Color for the text in the item when pressed or selected.
     *
     * It is advised to leave the default value (Theme.highlightedTextColor)
     *
     * If custom text elements are inserted in an AbstractListItem,
     * their color property will have to be manually bound with this property
     */
    property color activeTextColor: Theme.highlightedTextColor

    /**
     * @brief Color for the background of the item when pressed or selected.
     *
     * It is advised to leave the default value (Theme.highlightColor)
     */
    property color activeBackgroundColor: Theme.highlightColor

    default property alias _default: listItem.contentItem

    // NOTE: Overrides action property of newer import versions which we can't use
    /**
     * @brief This property holds the item action.
     * @property QtQuick::Controls::Action action
     */
    property QQC2.Action action

    activeFocusOnTab: ListView.view ? false : true

    text: action ? action.text : undefined
    checked: action ? action.checked : false
    checkable: action ? action.checkable : false
    onClicked: {
        if (ListView.view && typeof index !== "undefined") {
            ListView.view.currentIndex = index;
        }
        if (!action) {
            return;
        }

        action.trigger();
        checked = Qt.binding(function() { return action.checked });
    }
    //Theme.inherit: false
   //Theme.colorSet: Theme.View

    padding: Settings.tabletMode ? Units.largeSpacing : Units.smallSpacing

    leftPadding: padding*2
    topPadding: padding

    rightPadding: padding*2
    bottomPadding: padding

    implicitWidth: contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : Units.gridUnit * 12

    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    width: parent && parent.width > 0 ? parent.width : implicitWidth
    Layout.fillWidth: true

    opacity: enabled ? 1 : 0.6

    height: implicitHeight

    onVisibleChanged: {
        if (visible) {
            height = Qt.binding(() => { return implicitHeight; })
        } else {
            if (ListView.view && ListView.view.visible) {
                height = 0;
            }
        }
    }

    hoverEnabled: true

    QtObject {
        id: internal
        property Flickable view: listItem.ListView.view || (listItem.parent ? listItem.parent.ListView.view : null)
        property bool indicateActiveFocus: listItem.pressed || Settings.tabletMode || listItem.activeFocus || (view ? view.activeFocus : false)
    }

    Accessible.role: Accessible.ListItem
    highlighted: focus && ListView.isCurrentItem && ListView.view && ListView.view.keyNavigationEnabled
}
