/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.impl as QQC2Impl
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "." as P

Kirigami.AbstractListItem {
    id: listItem

    required action
    readonly property Kirigami.Action kAction: action as Kirigami.Action

    readonly property bool isSeparator: kAction?.separator ?? false
    readonly property bool isExpandable: kAction?.expandible ?? false

    highlighted: checked || actionsMenu.visible
    width: parent.width

    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            id: iconItem
            color: listItem.icon.color
            source: listItem.icon.name !== "" ? listItem.icon.name : listItem.icon.source

            readonly property int size: Kirigami.Units.iconSizes.smallMedium
            Layout.minimumHeight: size
            Layout.maximumHeight: size
            Layout.minimumWidth: size
            Layout.maximumWidth: size
            selected: (listItem.highlighted || listItem.checked || listItem.down)
            visible: source !== undefined && !listItem.isSeparator
        }

        QQC2Impl.MnemonicLabel {
            id: labelItem
            visible: !listItem.isSeparator
            text: width > height * 2 ? listItem.Kirigami.MnemonicData.mnemonicLabel : ""
            Layout.fillWidth: true
            mnemonicVisible: listItem.Kirigami.MnemonicData.active
            color: (listItem.highlighted || listItem.checked || listItem.down) ? listItem.activeTextColor : listItem.textColor
            elide: Text.ElideRight
            font: listItem.font
            opacity: {
                if (root.collapsed) {
                    return 0;
                } else if (!listItem.enabled) {
                    return 0.6;
                } else {
                    return 1.0;
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration / 2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Kirigami.Separator {
            id: separatorAction

            visible: listItem.isSeparator
            Layout.fillWidth: true
        }

        Kirigami.Icon {
            Shortcut {
                sequence: listItem.Kirigami.MnemonicData.sequence
                onActivated: listItem.clicked()
            }
            isMask: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: !root.collapsed ? 0 : -width
            Layout.preferredHeight: !root.collapsed ? Kirigami.Units.iconSizes.small : Kirigami.Units.iconSizes.small / 2
            opacity: 0.7
            selected: listItem.checked || listItem.down
            Layout.preferredWidth: Layout.preferredHeight
            source: listItem.mirrored ? "go-next-symbolic-rtl" : "go-next-symbolic"
            visible: (!listItem.isExpandable || root.collapsed) && !listItem.isSeparator && listItem.kAction?.children.length > 0
        }
    }

    Kirigami.MnemonicData.enabled: enabled && visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
    Kirigami.MnemonicData.label: text

    // TODO: animate the hide by collapse
    visible: (kAction?.visible ?? true) && opacity > 0
    opacity: !root.collapsed || listItem.icon.name !== "" || listItem.icon.source.toString() !== ""

    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration/2
            easing.type: Easing.InOutQuad
        }
    }

    hoverEnabled: (!isExpandable || root.collapsed) && !Kirigami.Settings.tabletMode && !isSeparator
    sectionDelegate: isExpandable
    font.pointSize: (isExpandable ? 1.30 : 1) * Kirigami.Theme.defaultFont.pointSize
    height: implicitHeight * opacity

    data: [
        P.ActionsMenu {
            id: actionsMenu

            x: listItem.mirrored ? -width : listItem.width
            actions: listItem.kAction?.children ?? []

            submenuComponent: P.ActionsMenu {}

            onVisibleChanged: {
                if (visible) {
                    stackView.openSubMenu = this;
                } else if (stackView.openSubMenu === this) {
                    stackView.openSubMenu = null;
                }
            }
        },
        QQC2.ToolTip {
            visible: !listItem.isSeparator
                && (listItem.kAction?.tooltip || root.collapsed)
                && !actionsMenu.visible
                && listItem.hovered
                && text.length > 0
            text: listItem.kAction?.tooltip || listItem.text
            delay: Kirigami.Units.toolTipDelay
            y: Math.round((listItem.height - height) / 2)
            x: listItem.mirrored ? -width : listItem.width
        }
    ]

    onHoveredChanged: {
        if (!hovered) {
            return;
        }
        if (stackView.openSubMenu) {
            stackView.openSubMenu.visible = false;

            if (actionsMenu.count > 0) {
                actionsMenu.popup(this, width, 0);
            }
        }
    }

    onClicked: trigger()
    Keys.onEnterPressed: event => trigger()
    Keys.onReturnPressed: event => trigger()
    Accessible.onPressAction: {
        if (action) {
            action.trigger();
        } else if (enabled) {
            clicked();
        }
    }

    function trigger() {
        if (kAction && kAction.children.length > 0) {
            if (root.collapsed) {
                if (actionsMenu.count > 0 && !actionsMenu.visible) {
                    stackView.openSubMenu = actionsMenu;
                    actionsMenu.popup(this, width, 0)
                }
            } else {
                stackView.push(menuComponent, {
                    model: kAction.children,
                    level: level + 1,
                    current: kAction,
                });
            }
        } else if (root.resetMenuOnTriggered) {
            root.resetMenu();
        }
    }

    Keys.onDownPressed: event => nextItemInFocusChain().focus = true
    Keys.onUpPressed: event => nextItemInFocusChain(false).focus = true
}
