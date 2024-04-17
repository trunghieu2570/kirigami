/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/**
 * A simple dialog to quickly prompt a user with information,
 * and possibly perform an action.
 *
 * Provides content padding (instead of padding outside of the scroll
 * area). Also has a default preferredWidth, as well as the `subtitle` property.
 *
 * <b>Note:</b> If a `mainItem` is specified, it will replace
 * the subtitle label, and so the respective property will have no effect.
 *
 * @see Dialog
 * @see MenuDialog
 *
 * Example usage:
 *
 * @code{.qml}
 * Kirigami.PromptDialog {
 *     title: "Reset settings?"
 *     subtitle: "The stored settings for the application will be deleted, with the defaults restored."
 *     standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
 *
 *     onAccepted: console.log("Accepted")
 *     onRejected: console.log("Rejected")
 * }
 * @endcode
 *
 * Text field prompt dialog:
 *
 * @code{.qml}
 * Kirigami.PromptDialog {
 *     id: textPromptDialog
 *     title: qsTr("New Folder")
 *
 *     standardButtons: Kirigami.Dialog.NoButton
 *     customFooterActions: [
 *         Kirigami.Action {
 *             text: qsTr("Create Folder")
 *             icon.name: "dialog-ok"
 *             onTriggered: {
 *                 showPassiveNotification("Created");
 *                 textPromptDialog.close();
 *             }
 *         },
 *         Kirigami.Action {
 *             text: qsTr("Cancel")
 *             icon.name: "dialog-cancel"
 *             onTriggered: {
 *                 textPromptDialog.close();
 *             }
 *         }
 *     ]
 *
 *     QQC2.TextField {
 *         placeholderText: qsTr("Folder name…")
 *     }
 * }
 * @endcode
 *
 * @inherit Dialog
 */
Kirigami.Dialog {
    id: root

    default property alias mainItem: wrapper.contentItem

    /**
     * The text to use in the dialog's contents.
     */
    property string subtitle

    /**
     * The padding around the content, within the scroll area.
     *
     * Default is `Kirigami.Units.largeSpacing`.
     */
    property real contentPadding: Kirigami.Units.largeSpacing

    /**
     * The top padding of the content, within the scroll area.
     */
    property real contentTopPadding: contentPadding

    /**
     * The bottom padding of the content, within the scroll area.
     */
    property real contentBottomPadding: contentPadding

    /**
     * The left padding of the content, within the scroll area.
     */
    property real contentLeftPadding: contentPadding

    /**
     * The right padding of the content, within the scroll area.
     */
    property real contentRightPadding: contentPadding

    padding: 0 // we want content padding, not padding of the scrollview

    contentData: [
        Component {
            id: defaultContentItemComponent
            Kirigami.SelectableLabel {
                text: root.subtitle
                wrapMode: TextEdit.Wrap
            }
        }
    ]

    Kirigami.Padding {
        id: wrapper

        topPadding: root.contentTopPadding
        leftPadding: root.contentLeftPadding
        rightPadding: root.contentRightPadding
        bottomPadding: root.contentBottomPadding
    }

    Component.onCompleted: {
        if (!wrapper.contentItem) {
            preferredWidth = Kirigami.Units.gridUnit * 18;
            wrapper.contentItem = defaultContentItemComponent.createObject(wrapper);
        }
    }
}
