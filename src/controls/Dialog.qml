/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15 as Controls
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.12 as Kirigami
import "templates/private" as Private

/**
 * Popup dialog that is used for short tasks and user interaction.
 *
 * Dialog consists of three components: the header, the content,
 * and the footer.
 *
 * By default, the header is a heading with text specified by the
 * `title` property.
 *
 * By default, the footer consists of a row of buttons specified by
 * the `footerActions` and `customFooterActions` properties.
 *
 * The `implicitHeight` and `implicitWidth` of the dialog contentItem is
 * the primary hint used for the dialog size. The dialog will be the
 * minimum size required for the header, footer and content unless
 * it is larger than `maximumHeight` and `maximumWidth`. Use
 * `preferredHeight` and `preferredWidth` in order to manually specify
 * a size for the dialog.
 *
 * If the content height exceeds the maximum height of the dialog, the
 * dialog's contents will become scrollable.
 *
 * If the contentItem is a <b>ListView</b>, the dialog will take care of the
 * necessary scrollbars and scrolling behaviour. Do <b>not</b> attempt
 * to nest ListViews (it must be the top level item), as the scrolling
 * behaviour will not be handled. Use ListView's `header` and `footer` instead.
 *
 * Example for a selection dialog:
 *
 * @code{.qml}
 * import QtQuick 2.15
 * import QtQuick.Layouts 1.2
 * import QtQuick.Controls 2.15 as Controls
 * import org.kde.kirigami 2.18 as Kirigami
 *
 * Kirigami.Dialog {
 *     title: i18n("Dialog")
 *     padding: 0
 *     preferredWidth: Kirigami.Units.gridUnit * 16
 *
 *     standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
 *
 *     onAccepted: console.log("OK button pressed")
 *     onRejected: console.log("Rejected")
 *
 *     ColumnLayout {
 *         spacing: 0
 *         Repeater {
 *             model: 5
 *             delegate: Controls.CheckDelegate {
 *                 topPadding: Kirigami.Units.smallSpacing * 2
 *                 bottomPadding: Kirigami.Units.smallSpacing * 2
 *                 Layout.fillWidth: true
 *                 text: modelData
 *             }
 *         }
 *     }
 * }
 * @endcode
 *
 * Example with scrolling (ListView scrolling behaviour is handled by Dialog):
 *
 * @code{.qml}
 * Kirigami.Dialog {
 *     id: scrollableDialog
 *     title: i18n("Select Number")
 *
 *     ListView {
 *         id: listView
 *         // hints for the dialog dimensions
 *         implicitWidth: Kirigami.Units.gridUnit * 16
 *         implicitHeight: Kirigami.Units.gridUnit * 16
 *
 *         model: 100
 *         delegate: Controls.RadioDelegate {
 *             topPadding: Kirigami.Units.smallSpacing * 2
 *             bottomPadding: Kirigami.Units.smallSpacing * 2
 *             implicitWidth: listView.width
 *             text: modelData
 *         }
 *     }
 * }
 * @endcode
 *
 * There are also sub-components of Dialog that target specific usecases,
 * and can reduce boilerplate code if used:
 *
 * @see PromptDialog
 * @see MenuDialog
 *
 * @inherit QtQuick.QtObject
 */
Loader {
    id: root

    /**
     * The dialog's contents.
     *
     * The initial height and width of the dialog is calculated from the
     * `implicitWidth` and `implicitHeight` of this item.
     */
    default property Item mainItem

    /**
     * The absolute maximum height the dialog can be (including the header
     * and footer).
     *
     * The height restriction is solely applied on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     *
     * This is the window height, subtracted by largeSpacing on both the top
     * and bottom.
     */
    readonly property real absoluteMaximumHeight: item ? item.absoluteMaximumHeight : 500

    /**
     * The absolute maximum width the dialog can be.
     *
     * By default, it is the window width, subtracted by largeSpacing on both
     * the top and bottom.
     */
    readonly property real absoluteMaximumWidth: item ? item.absoluteMaximumWidth : 500

    /**
     * The maximum height the dialog can be (including the header
     * and footer).
     *
     * The height restriction is solely enforced on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     *
     * By default, this is `absoluteMaximumHeight`.
     */
    property real maximumHeight: absoluteMaximumHeight

    /**
     * The maximum width the dialog can be.
     *
     * By default, this is `absoluteMaximumWidth`.
     */
    property real maximumWidth: absoluteMaximumWidth

    /**
     * Specify the preferred height of the dialog.
     *
     * The content will receive a hint for how tall it should be to have
     * the dialog to be this height.
     *
     * If the content, header or footer require more space, then the height
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredHeight: -1

    /**
     * Specify the preferred width of the dialog.
     *
     * The content will receive a hint for how wide it should be to have
     * the dialog be this wide.
     *
     * If the content, header or footer require more space, then the width
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredWidth: -1

    /**
     * The component before the footer buttons.
     */
    property Component footerLeadingComponent

    /**
     * The component after the footer buttons.
     */
    property Component footerTrailingComponent

    /**
     * Whether or not to show the close button in the header.
     */
    property bool showCloseButton: true

    /**
     * Whether or not the footer button style should be flat instead of raised.
     */
    property bool flatFooterButtons: false

    property string title

    property int standardButtons: Controls.Dialog.Close

    /**
     * Define a list of custom actions in the footer.
     *
     * @code{.qml}
     * import QtQuick 2.15
     * import QtQuick.Controls 2.15 as Controls
     * import org.kde.kirigami 2.18 as Kirigami
     *
     * Kirigami.PromptDialog {
     *     id: dialog
     *     title: i18n("Confirm Playback")
     *     subtitle: i18n("Are you sure you want to play this song? It's really loud!")
     *
     *     standardButtons: Kirigami.Dialog.Cancel
     *     customFooterActions: [
     *         Kirigami.Action {
     *             text: i18n("Play")
     *             iconName: "media-playback-start"
     *             onTriggered: {
     *                 //...
     *                 dialog.close();
     *             }
     *         }
     *     ]
     * }
     * @endcode
     *
     * @see Action
     */
    property list<Kirigami.Action> customFooterActions

    property int padding: 0
    property int leftPadding: padding
    property int rightPadding: padding
    property int topPadding: padding
    property int bottomPadding: padding

    signal accepted()
    signal rejected()

    Component {
        id: mobileDialog
        MobileDialog {
            mainItem: root.mainItem
            maximumHeight: root.maximumHeight
            maximumWidth: root.maximumWidth
            preferredHeight: root.preferredHeight
            preferredWidth: root.preferredWidth
            footerLeadingComponent: root.footerLeadingComponent
            footerTrailingComponent: root.footerTrailingComponent
            showCloseButton: root.showCloseButton
            flatFooterButtons: root.flatFooterButtons
            customFooterActions: root.customFooterActions
        }
    }

    Component {
        id: desktopDialog

        DesktopDialog {
            mainItem: root.mainItem
            maximumHeight: root.maximumHeight
            maximumWidth: root.maximumWidth
            preferredHeight: root.preferredHeight
            preferredWidth: root.preferredWidth
            footerLeadingComponent: root.footerLeadingComponent
            footerTrailingComponent: root.footerTrailingComponent
            showCloseButton: root.showCloseButton
            flatFooterButtons: root.flatFooterButtons
            customFooterActions: root.customFooterActions
        }
    }

    asynchronous: true
    sourceComponent: Kirigami.Settings.isMobile ? mobileDialog : desktopDialog
    function open() {
        item.visible = true;
    }
}
