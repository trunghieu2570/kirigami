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
import QtQuick.Window 2.2
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
Controls.ApplicationWindow {
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
    readonly property real absoluteMaximumHeight: applicationWindow().height - Kirigami.Units.largeSpacing * 2

    /**
     * The absolute maximum width the dialog can be.
     *
     * By default, it is the window width, subtracted by largeSpacing on both
     * the top and bottom.
     */
    readonly property real absoluteMaximumWidth: applicationWindow().width - Kirigami.Units.largeSpacing * 2

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

    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint;
    width: {
        let backgroundWidth = implicitBackgroundWidth + leftInset + rightInset,
            contentWidth = contentItem.implicitWidth + leftPadding + rightPadding;
        return Math.ceil(Math.min(root.maximumWidth, Math.max(backgroundWidth, contentWidth, implicitHeaderWidth, implicitFooterWidth)));
    }
    height: {
        let backgroundHeight = implicitBackgroundHeight + topInset + bottomInset,
            contentHeight = contentItem.implicitHeight + topPadding + bottomPadding
                            + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                            + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0);
        return Math.ceil(Math.min(root.maximumHeight, Math.max(backgroundHeight, contentHeight)));
    }
    title: root.title

    // dialog content
    ColumnLayout {
        Private.ScrollView {
            id: contentControl
            contentItem: root.mainItem
            canFlickWithMouse: true

            // ensure view colour scheme, and background color
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.View

            // needs to explicitly be set for each side to work
            leftPadding: 0; topPadding: 0
            rightPadding: 0; bottomPadding: 0

            // height of everything else in the dialog other than the content
            property real otherHeights: root.header.height + root.footer.height + root.topPadding + root.bottomPadding;

            property real calculatedMaximumWidth: root.maximumWidth > root.absoluteMaximumWidth ? root.absoluteMaximumWidth : root.maximumWidth
            property real calculatedMaximumHeight: root.maximumHeight > root.absoluteMaximumHeight ? root.absoluteMaximumHeight - otherHeight: root.maximumHeight
            property real calculatedImplicitWidth: (root.mainItem.implicitWidth ? root.mainItem.implicitWidth : root.mainItem.width) + leftPadding + rightPadding
            property real calculatedImplicitHeight: (root.mainItem.implicitHeight ? root.mainItem.implicitHeight : root.mainItem.height) + topPadding + bottomPadding

            // don't enforce preferred width and height if not set
            Layout.preferredWidth: root.preferredWidth >= 0 ? root.preferredWidth : calculatedImplicitWidth
            Layout.preferredHeight: root.preferredHeight >= 0 ? root.preferredHeight - otherHeights : calculatedImplicitHeight

            Layout.fillWidth: true
            Layout.maximumWidth: calculatedMaximumWidth
            Layout.maximumHeight: calculatedMaximumHeight

            // give an implied width and height to the contentItem so that features like word wrapping/eliding work
            // cannot placed directly in contentControl as a child, so we must use a property
            property var widthHint: Binding {
                target: root.mainItem
                property: "width"
                // we want to avoid horizontal scrolling, so we apply maximumWidth as a hint if necessary
                property real preferredWidthHint: contentControl.Layout.preferredWidth - contentControl.leftPadding - contentControl.rightPadding
                property real maximumWidthHint: contentControl.calculatedMaximumWidth - contentControl.leftPadding - contentControl.rightPadding
                value: maximumWidthHint < preferredWidthHint ? maximumWidthHint : preferredWidthHint
            }
            property var heightHint: Binding {
                target: root.mainItem
                property: "height"
                // we are okay with overflow, if it exceeds maximumHeight we will allow scrolling
                value: contentControl.Layout.preferredHeight - contentControl.topPadding - contentControl.bottomPadding
            }

            // give explicit warnings since the maximumHeight is ignored when negative, so developers aren't confused
            Component.onCompleted: {
                if (contentControl.Layout.maximumHeight < 0 || contentControl.Layout.maximumHeight === Infinity) {
                    console.log("Dialog Warning: the calculated maximumHeight for the content is less than zero, ignoring...", root.absoluteMaximumHeight, calculatedMaximumHeight, root.maximumHeight);
                }
            }
        }
    }

    header: T.Control {
        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                implicitContentWidth + leftPadding + rightPadding)
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                implicitContentHeight + topPadding + bottomPadding)

        padding: Kirigami.Units.largeSpacing
        bottomPadding: verticalPadding + headerSeparator.implicitHeight // add space for bottom separator

        contentItem: RowLayout {
            Kirigami.Heading {
                id: heading
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                level: 2
                text: root.title == "" ? " " : root.title // always have text to ensure header height
                elide: Text.ElideRight

                // use tooltip for long text that is elided
                Controls.ToolTip.visible: truncated && titleHoverHandler.hovered
                Controls.ToolTip.text: root.title
                HoverHandler { id: titleHoverHandler }
            }
        }
        // header background
        background: Kirigami.ShadowedRectangle {
            corners.topLeftRadius: Kirigami.Units.smallSpacing
            corners.topRightRadius: Kirigami.Units.smallSpacing
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor
            Kirigami.Separator {
                id: headerSeparator
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }
    }
    // use top level control rather than toolbar, since toolbar causes button rendering glitches
    footer: T.Control {
        id: footerToolBar

        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                implicitContentWidth + leftPadding + rightPadding)
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                implicitContentHeight + topPadding + bottomPadding)

        leftPadding: Kirigami.Units.smallSpacing
        rightPadding: Kirigami.Units.smallSpacing
        bottomPadding: Kirigami.Units.smallSpacing
        topPadding: Kirigami.Units.smallSpacing + footerSeparator.implicitHeight

        contentItem: RowLayout {
            spacing: parent.spacing

            Loader {
                id: leadingLoader
                sourceComponent: root.footerLeadingComponent
            }

            // footer buttons
            Controls.DialogButtonBox {
                // we don't explicitly set padding, to let the style choose the padding
                id: dialogButtonBox
                standardButtons: root.standardButtons
                visible: count > 0

                Layout.fillWidth: true
                Layout.alignment: dialogButtonBox.alignment

                position: Controls.DialogButtonBox.Footer

                // we need to hook all of the buttonbox events to the dialog events
                onAccepted: root.accept()
                onRejected: root.reject()
                onApplied: root.applied()
                onDiscarded: root.discarded()
                onHelpRequested: root.helpRequested()
                onReset: root.reset()

                // add custom footer buttons
                Repeater {
                    model: root.customFooterActions
                    // we have to use Button instead of ToolButton, because ToolButton has no visual distinction when disabled
                    delegate: Controls.Button {
                        flat: flatFooterButtons
                        action: modelData
                        visible: modelData.visible
                    }
                }
            }

            Loader {
                id: trailingLoader
                sourceComponent: root.footerTrailingComponent
            }
        }

        background: Item {
            // separator above footer
            Kirigami.Separator {
                id: footerSeparator
                visible: contentControl.height < contentControl.flickableItem.contentHeight
                width: parent.width
                anchors.top: parent.top
            }
        }
    }
}
