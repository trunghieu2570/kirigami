/*
 *  SPDX-FileCopyrightText: 2019 Carl-Lucien Schwan <carl@carlschwan.eu>
 *  SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Controls 2.1 as Controls
import org.kde.kirigami 2.16 as Kirigami

/**
 * This is a standard textfield following KDE HIG. Using Ctrl+F as focus
 * sequence and "Search..." as placeholder text.
 *
 * Example usage for the search field component:
 * @code
 * import org.kde.kirigami 2.8 as Kirigami
 *
 * Kirigami.SearchField {
 *     id: searchField
 *     onAccepted: console.log("Search text is " + searchField.text)
 * }
 * @endcode
 *
 * @inherit org::kde::kirigami::ActionTextField
 */
Kirigami.ActionTextField
{
    id: root
    /**
     * Determines whether the accepted signal will be fired automatically
     * when the text is changed. Setting this to false will require that
     * the user presses return or enter (the same way a QML.TextInput
     * works).
     *
     * The default value is true
     *
     * @since 5.81
     * @since org.kde.kirigami 2.16
     */
    property bool autoAccept: true
    /**
     * Delays the automatic acceptance of the input further (by 2.5 seconds).
     * Set this to true if your search is expensive (such as for online
     * operations or in exceptionally slow data sets).
     *
     * \note If you must have immediate feedback (filter-style), use the
     * text property directly instead of accepted()
     *
     * The default value is false
     *
     * @since 5.81
     * @since org.kde.kirigami 2.16
     */
    property bool delaySearch: false

    // padding to accommodate search icon nicely
    leftPadding: if (Qt.application.layoutDirection === Qt.RightToLeft) {
        return _rightActionsRow.width + Kirigami.Units.smallSpacing
    } else {
        return (activeFocus || root.text.length > 0 ? 0 : (searchIcon.width + Kirigami.Units.smallSpacing)) + _leftActionsRow.width
    }
    rightPadding: if (Qt.application.layoutDirection === Qt.RightToLeft) {
        return (activeFocus || root.text.length > 0 ? 0 : (searchIcon.width + Kirigami.Units.smallSpacing)) + _leftActionsRow.width
    } else {
        return _rightActionsRow.width + Kirigami.Units.smallSpacing
    }

    Kirigami.Icon {
        id: searchIcon
        opacity: parent.activeFocus || text.length > 0 ? 0 : 1
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round((parent.implicitHeight - implicitHeight) / 2 + (parent.bottomPadding - parent.topPadding) / 2)
        implicitHeight: Kirigami.Units.iconSizes.sizeForLabels
        implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
        color: root.placeholderTextColor

        source: "search"

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    placeholderText: qsTr("Search…")

    Accessible.name: qsTr("Search")
    Accessible.searchEdit: true

    focusSequence: "Ctrl+F"
    inputMethodHints: Qt.ImhNoPredictiveText
    rightActions: [
        Kirigami.Action {
            icon.name: root.LayoutMirroring.enabled ? "edit-clear-locationbar-ltr" : "edit-clear-locationbar-rtl"
            visible: root.text.length > 0
            onTriggered: {
                root.text = "";
                // Since we are always sending the accepted signal here (whether or not the user has requested
                // that the accepted signal be delayed), stop the delay timer that gets started by the text changing
                // above, so that we don't end up sending two of those in rapid succession.
                fireSearchDelay.stop();
                root.accepted();
            }
        }
    ]

    Timer {
        id: fireSearchDelay
        interval: root.delaySearch ? Kirigami.Units.humanMoment : Kirigami.Units.shortDuration
        running: false; repeat: false;
        onTriggered: {
            root.accepted();
        }
    }
    onAccepted: {
        fireSearchDelay.running = false
    }
    onTextChanged: {
        if (root.autoAccept) {
            fireSearchDelay.restart();
        } else {
            fireSearchDelay.stop();
        }
    }
}
