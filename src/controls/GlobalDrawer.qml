/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import "private" as KP

/*!
 * A specialized form of the Drawer intended for showing an application's
 * always-available global actions. Think of it like a mobile version of
 * a desktop application's menubar.
 *
 * Example usage:
 * \code
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *             Kirigami.Action {
 *                 text: "View"
 *                 icon.name: "view-list-icons"
 *                 Kirigami.Action {
 *                     text: "action 1"
 *                 }
 *                 Kirigami.Action {
 *                     text: "action 2"
 *                 }
 *                 Kirigami.Action {
 *                     text: "action 3"
 *                 }
 *             },
 *             Kirigami.Action {
 *                 text: "Sync"
 *                 icon.name: "folder-sync"
 *             }
 *         ]
 *     }
 * }
 * \endcode
 */
Kirigami.OverlayDrawer {
    id: root

    edge: Qt.application.layoutDirection === Qt.RightToLeft ? Qt.RightEdge : Qt.LeftEdge

    handleClosedIcon.source: null
    handleOpenIcon.source: null

    handleVisible: {
        // When drawer is inline with content and opened, there is no point is showing handle.
        if (!modal && drawerOpen) {
            return false;
        }

        // GlobalDrawer can be hidden by controlsVisible...
        if (typeof applicationWindow === "function") {
            const w = applicationWindow();
            if (w && !w.controlsVisible) {
                return false;
            }
        }

        // ...but it still performs additional checks.
        return !isMenu || Kirigami.Settings.isMobile;
    }

    enabled: !isMenu || Kirigami.Settings.isMobile

//BEGIN properties
    /*!
     * \brief This property holds the title displayed at the top of the drawer.
     * \sa org::kde::kirigami::private::BannerImage::title
     * @property string title
     */
    property string title

    /*!
     * \brief This property holds an icon to be displayed alongside the title.
     * \sa org::kde::kirigami::private::BannerImage::titleIcon
     * \sa org::kde::kirigami::Icon::source
     * @property var titleIcon
     */
    property var titleIcon

    /*!
     * \brief This property holds the actions displayed in the drawer.
     *
     * The list of actions can be nested having a tree structure.
     * A tree depth bigger than 2 is discouraged.
     *
     * Example usage:
     *
     * \code
     * import org.kde.kirigami as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [
     *            Kirigami.Action {
     *                text: "View"
     *                icon.name: "view-list-icons"
     *                Kirigami.Action {
     *                    text: "action 1"
     *                }
     *                Kirigami.Action {
     *                    text: "action 2"
     *                }
     *                Kirigami.Action {
     *                    text: "action 3"
     *                }
     *            },
     *            Kirigami.Action {
     *                text: "Sync"
     *                icon.name: "folder-sync"
     *            }
     *         ]
     *     }
     * }
     * \endcode
     * @property list<T.Action> actions
     */
    property list<T.Action> actions

    /*!
     * \brief This property holds an item that will always be displayed at the top of the drawer.
     *
     * If the drawer contents can be scrolled, this item will stay still and won't scroll.
     *
     * @note This property is mainly intended for toolbars.
     * @since 2.12
     */
    property alias header: mainLayout.header

    /*!
     * \brief This property holds an item that will always be displayed at the bottom of the drawer.
     *
     * If the drawer contents can be scrolled, this item will stay still and won't scroll.
     *
     * @note This property is mainly intended for toolbars.
     * @since 6.0
     */
    property alias footer: mainLayout.footer

    /*!
     * \brief This property holds items that are displayed above the actions.
     *
     * Example usage:
     * \code
     * import org.kde.kirigami as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         topContent: [Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }]
     *     }
     *  [...]
     * }
     * \endcode
     * @property list<QtObject> topContent
     */
    property alias topContent: topContent.data

    /*!
     * \brief This property holds items that are displayed under the actions.
     *
     * Example usage:
     * \code
     * import org.kde.kirigami as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }
     *     }
     *  [...]
     * }
     * \endcode
     * @note This is a `default` property.
     * @property list<QtObject> content
     */
    default property alias content: mainContent.data

    /*!
     * \brief This property sets whether content items at the top should be shown.
     * when the drawer is collapsed as a sidebar.
     *
     * If you want to keep some items visible and some invisible, set this to
     * false and control the visibility/opacity of individual items,
     * binded to the collapsed property
     *
     * default: ``false``
     *
     * @since 2.5
     */
    property bool showTopContentWhenCollapsed: false

    /*!
     * \brief This property sets whether content items at the bottom should be shown.
     * when the drawer is collapsed as a sidebar.
     *
     * If you want to keep some items visible and some invisible, set this to
     * false and control the visibility/opacity of individual items,
     * binded to the collapsed property
     *
     * default: ``false``
     *
     * \sa content
     * @since 2.5
     */
    property bool showContentWhenCollapsed: false

    // TODO
    property bool showHeaderWhenCollapsed: false

    /*!
     * \brief This property sets whether activating a leaf action resets the
     * menu to show leaf's parent actions.
     *
     * A leaf action is an action without any child actions.
     *
     * default: ``true``
     */
    property bool resetMenuOnTriggered: true

    /*!
     * \brief This property points to the action acting as a submenu
     */
    readonly property T.Action currentSubMenu: stackView.currentItem?.current ?? null

    /*!
     * \brief This property sets whether the drawer becomes a menu on the desktop.
     *
     * default: ``false``
     *
     * @since 2.11
     */
    property bool isMenu: false

    /*!
     * \brief This property sets the visibility of the collapse button
     * when the drawer collapsible.
     *
     * default: ``true``
     *
     * @since 2.12
     */
    property bool collapseButtonVisible: true
//END properties

    /*!
     * \brief This function reverts the menu back to its initial state
     */
    function resetMenu() {
        stackView.pop(stackView.get(0, T.StackView.DontLoad));
        if (root.modal) {
            root.drawerOpen = false;
        }
    }

    // rightPadding: !Kirigami.Settings.isMobile && mainFlickable.contentHeight > mainFlickable.height ? Kirigami.Units.gridUnit : Kirigami.Units.smallSpacing

    Kirigami.Theme.colorSet: modal ? Kirigami.Theme.Window : Kirigami.Theme.View

    onIsMenuChanged: drawerOpen = false

    Component {
        id: menuComponent

        Column {
            property alias model: actionsRepeater.model
            property T.Action current
            property int level: 0

            spacing: 0
            Layout.maximumHeight: Layout.minimumHeight

            QQC2.ItemDelegate {
                id: backItem

                visible: level > 0
                width: parent.width
                icon.name: mirrored ? "go-previous-symbolic-rtl" : "go-previous-symbolic"

                text: Kirigami.MnemonicData.richTextLabel
                activeFocusOnTab: true

                Kirigami.MnemonicData.enabled: enabled && visible
                Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
                Kirigami.MnemonicData.label: qsTr("Back")

                onClicked: stackView.pop()

                Keys.onEnterPressed: stackView.pop()
                Keys.onReturnPressed: stackView.pop()

                Keys.onDownPressed: nextItemInFocusChain().focus = true
                Keys.onUpPressed: nextItemInFocusChain(false).focus = true
            }

            Shortcut {
                sequence: backItem.Kirigami.MnemonicData.sequence
                onActivated: backItem.clicked()
            }

            Repeater {
                id: actionsRepeater

                readonly property bool withSections: {
                    for (const action of root.actions) {
                        if (action.hasOwnProperty("expandible") && action.expandible) {
                            return true;
                        }
                    }
                    return false;
                }

                model: root.actions

                delegate: ActionDelegate {
                    required property T.Action modelData

                    tAction: modelData
                    withSections: actionsRepeater.withSections
                }
            }
        }
    }

    component ActionDelegate : Column {
        id: delegate

        required property int index
        required property T.Action tAction
        required property bool withSections

        // `as` case operator is still buggy
        readonly property Kirigami.Action kAction: tAction instanceof Kirigami.Action ? tAction : null

        readonly property bool isExpanded: {
            return !root.collapsed
                && kAction
                && kAction.expandible
                && kAction.children.length > 0;
        }

        visible: kAction?.visible ?? true

        width: parent.width

        KP.GlobalDrawerActionItem {
            Kirigami.Theme.colorSet: !root.modal && !root.collapsed && delegate.withSections
                ? Kirigami.Theme.Window : parent.Kirigami.Theme.colorSet

            visible: !delegate.isExpanded
            width: parent.width

            tAction: delegate.tAction

            onCheckedChanged: {
                // move every checked item into view
                if (checked && topContent.height + backItem.height + (delegate.index + 1) * height - mainFlickable.contentY > mainFlickable.height) {
                    mainFlickable.contentY += height
                }
            }
        }

        Item {
            id: headerItem

            visible: delegate.isExpanded
            height: sectionHeader.implicitHeight
            width: parent.width

            Kirigami.ListSectionHeader {
                id: sectionHeader

                anchors.fill: parent
                Kirigami.Theme.colorSet: root.modal ? Kirigami.Theme.View : Kirigami.Theme.Window

                contentItem: RowLayout {
                    spacing: sectionHeader.spacing

                    Kirigami.Icon {
                        property int size: Kirigami.Units.iconSizes.smallMedium
                        Layout.minimumHeight: size
                        Layout.maximumHeight: size
                        Layout.minimumWidth: size
                        Layout.maximumWidth: size
                        source: delegate.tAction.icon.name || delegate.tAction.icon.source
                    }

                    Kirigami.Heading {
                        level: 4
                        text: delegate.tAction.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Repeater {
            model: delegate.isExpanded ? (delegate.kAction?.children ?? null) : null

            NestedActionDelegate {
                required property T.Action modelData

                tAction: modelData
                withSections: delegate.withSections
            }
        }
    }

    component NestedActionDelegate : KP.GlobalDrawerActionItem {
        required property bool withSections

        width: parent.width
        opacity: !root.collapsed
        leftPadding: withSections && !root.collapsed && !root.modal ? padding * 2 : padding * 4
    }

    contentItem: Kirigami.HeaderFooterLayout {
        id: mainLayout

        anchors {
            fill: parent
            topMargin: root.collapsed && !showHeaderWhenCollapsed ? -contentItem.y : 0
        }

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        header: RowLayout {
            visible: root.title.length > 0 || Boolean(root.titleIcon)
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: root.titleIcon
            }

            Kirigami.Heading {
                text: root.title
                elide: Text.ElideRight
                visible: !root.collapsed
                Layout.fillWidth: true
            }
        }

        contentItem: QQC2.ScrollView {
            id: scrollView

            //ensure the attached property exists
            Kirigami.Theme.inherit: true

            // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

            implicitWidth: Math.min(Kirigami.Units.gridUnit * 20, root.parent.width * 0.8)

            Flickable {
                id: mainFlickable

                contentWidth: width
                contentHeight: mainColumn.Layout.minimumHeight

                clip: (mainLayout.header?.visible ?? false) || (mainLayout.footer?.visible ?? false)

                ColumnLayout {
                    id: mainColumn
                    width: mainFlickable.width
                    spacing: 0
                    height: Math.max(scrollView.height, Layout.minimumHeight)

                    ColumnLayout {
                        id: topContent

                        spacing: 0

                        Layout.alignment: Qt.AlignHCenter
                        Layout.leftMargin: root.leftPadding
                        Layout.rightMargin: root.rightPadding
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                        Layout.topMargin: root.topPadding
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: implicitHeight * opacity
                        // NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                        // as items are added only after this column creation
                        Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding

                        visible: children.length > 0 && childrenRect.height > 0 && opacity > 0
                        opacity: !root.collapsed || showTopContentWhenCollapsed

                        Behavior on opacity {
                            // not an animator as is binded
                            NumberAnimation {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    T.StackView {
                        id: stackView

                        property KP.ActionsMenu openSubMenu

                        clip: true
                        Layout.fillWidth: true
                        Layout.minimumHeight: currentItem ? currentItem.implicitHeight : 0
                        Layout.maximumHeight: Layout.minimumHeight

                        initialItem: menuComponent

                        // NOTE: it's important those are NumberAnimation and not XAnimators
                        // as while the animation is running the drawer may close, and
                        // the animator would stop when not drawing see BUG 381576
                        popEnter: Transition {
                            NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * -stackView.width; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                        }

                        popExit: Transition {
                            NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * stackView.width; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                        }

                        pushEnter: Transition {
                            NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                        }

                        pushExit: Transition {
                            NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                        }

                        replaceEnter: Transition {
                            NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                        }

                        replaceExit: Transition {
                            NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: root.actions.length > 0
                        Layout.minimumHeight: Kirigami.Units.smallSpacing
                    }

                    ColumnLayout {
                        id: mainContent
                        Layout.alignment: Qt.AlignHCenter
                        Layout.leftMargin: root.leftPadding
                        Layout.rightMargin: root.rightPadding
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        // NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                        // as items are added only after this column creation
                        Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                        visible: children.length > 0 && (opacity > 0 || mainContentAnimator.running)
                        opacity: !root.collapsed || showContentWhenCollapsed
                        Behavior on opacity {
                            OpacityAnimator {
                                id: mainContentAnimator
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Item {
                        Layout.minimumWidth: Kirigami.Units.smallSpacing
                        Layout.minimumHeight: root.bottomPadding
                    }

                    QQC2.ToolButton {
                        Layout.fillWidth: true

                        icon.name: {
                            if (root.collapsible && root.collapseButtonVisible) {
                                // Check for edge regardless of RTL/locale/mirrored status,
                                // because edge can be set externally.
                                const mirrored = root.edge === Qt.RightEdge;

                                if (root.collapsed) {
                                    return mirrored ? "sidebar-expand-right" : "sidebar-expand-left";
                                } else {
                                    return mirrored ? "sidebar-collapse-right" : "sidebar-collapse-left";
                                }
                            }
                            return "";
                        }

                        visible: root.collapsible && root.collapseButtonVisible
                        text: root.collapsed ? "" : qsTr("Close Sidebar")

                        onClicked: root.collapsed = !root.collapsed

                        QQC2.ToolTip.visible: root.collapsed && (Kirigami.Settings.tabletMode ? pressed : hovered)
                        QQC2.ToolTip.text: qsTr("Open Sidebar")
                        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    }
                }
            }
        }
    }
}
