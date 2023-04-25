/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.4 as QQC2
import org.kde.kirigami 2.14 as Kirigami

/**
 * @brief An item that represents an abstract Action
 * @inherit QtQuick.QQC2.Action
 */
QQC2.Action {
    id: root

//BEGIN properties
    /**
     * @brief This property holds whether the graphic representation of the action
     * is supposed to be visible.
     *
     * It's up to the action representation to honor this property.
     *
     * default: ``true``
     */
    property bool visible: true

    /**
     * @brief This property holds the tooltip text that is shown when the cursor is hovering over the control.
     *
     * Leaving this undefined or setting it to an empty string means that no tooltip will be shown when
     * the cursor is hovering over the control that triggers the tooltip.
     * @warning Tooltips may not be supported on all platforms.
     */
    property string tooltip

    /**
     * @brief This property sets whether this action is a separator action.
     *
     * default: ``false``
     */
    property bool separator: false

    /**
     * @brief This property sets whether this action  becomes a title displaying
     * its child actions as sub-items in GlobalDrawers and ContextDrawers.
     *
     * default: ``false``
     *
     * @since 2.6
     */
    property bool expandible: false

    /**
     * @brief This property holds the parent action.
     */
    property QQC2.Action parent

    /**
     * @brief This property sets this action's display type.
     *
     * These are provided to implementations to indicate a preference for certain display
     * styles.
     *
     * default: ``Kirigami.DisplayHint.NoPreference``
     *
     * @note This property contains only preferences, implementations may choose to disregard them.
     * @see org::kde::kirigami::DisplayHint
     * @since 2.12
     */
    property int displayHint: Kirigami.DisplayHint.NoPreference

    /**
     * @brief This property holds the component that should be used for displaying this action.
     * @note This can be used to display custom components in the toolbar.
     * @since 5.65
     * @since 2.12
     */
    property Component displayComponent: null

    /**
     * @brief This property holds a list of child actions.
     *
     * This is useful for tree-like menus, such as the GlobalDrawer.
     *
     * Example usage:
     * @code
     * Action {
     *    text: "Tools"
     *    Action {
     *        text: "Action1"
     *    }
     *    Action {
     *        text: "Action2"
     *    }
     * }
     * @endcode
     * @property list<Action> children
     */
    default property list<QtObject> children
//END properties

    onChildrenChanged: {
        let child;
        for (const i in children) {
            child = children[i];
            if (child.hasOwnProperty("parent")) {
                child.parent = root
            }
        }
    }

    /**
     * @brief This property holds the action's visible child actions.
     * @property list<Action> visibleChildren
     */
    readonly property var visibleChildren: {
        const visible = [];
        for (const i in children) {
            const child = children[i];
            if (!child.hasOwnProperty("visible") || child.visible) {
                visible.push(child);
            }
        }
        return visible;
    }
}
