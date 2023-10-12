/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.impl as QQC2Impl
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

QQC2.ItemDelegate {
    id: listItem

    required property T.Action tAction
    // `as` case operator is still buggy
    readonly property Kirigami.Action kAction: tAction instanceof Kirigami.Action ? tAction : null

    readonly property bool wideMode: width > height * 2
    readonly property bool isSeparator: modelData.hasOwnProperty("separator") && modelData.separator

    readonly property bool isExpandable: modelData && modelData.hasOwnProperty("expandible") && modelData.expandible

    checked: modelData.checked || (actionsMenu && actionsMenu.visible)
    highlighted: checked
    width: parent.width

    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            id: iconItem
            color: modelData.icon.color
            source: modelData.icon.name || modelData.icon.source

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
            text:  width > height * 2 ? listItem.Kirigami.MnemonicData.mnemonicLabel : ""

            // Work around Qt bug where left aligned text is not right aligned
            // in RTL mode unless horizontalAlignment is explicitly set.
            // https://bugreports.qt.io/browse/QTBUG-95873
            horizontalAlignment: Text.AlignLeft

            Layout.fillWidth: true
            mnemonicVisible: listItem.Kirigami.MnemonicData.active
            color: (listItem.highlighted || listItem.checked || listItem.down) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
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
                    duration: Kirigami.Units.longDuration/2
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
            Layout.preferredHeight: !root.collapsed ? Kirigami.Units.iconSizes.small : Kirigami.Units.iconSizes.small/2
            opacity: 0.7
            selected: listItem.checked || listItem.down
            Layout.preferredWidth: Layout.preferredHeight
            source: listItem.mirrored ? "go-next-symbolic-rtl" : "go-next-symbolic"
            visible: (!isExpandable || root.collapsed) && !listItem.isSeparator && modelData.hasOwnProperty("children") && modelData.children!==undefined && modelData.children.length > 0
        }
    }
    Kirigami.MnemonicData.enabled: listItem.enabled && listItem.visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
    Kirigami.MnemonicData.label: modelData.text
    property ActionsMenu actionsMenu: ActionsMenu {
        x: Qt.application.layoutDirection === Qt.RightToLeft ? -width : listItem.width
        actions: modelData.hasOwnProperty("children") ? modelData.children : null
        submenuComponent: Component {
            ActionsMenu {}
        }
        onVisibleChanged: {
            if (visible) {
                stackView.openSubMenu = listItem.actionsMenu;
            } else if (stackView.openSubMenu === listItem.actionsMenu) {
                stackView.openSubMenu = null;
            }
        }
    }

    // TODO: animate the hide by collapse
    visible: (model ? model.visible || model.visible===undefined : modelData.visible) && opacity > 0
    opacity: !root.collapsed || iconItem.source.length > 0
    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration/2
            easing.type: Easing.InOutQuad
        }
    }
    enabled: (model && model.enabled !== undefined) ? model.enabled : modelData.enabled

    hoverEnabled: (!isExpandable || root.collapsed) && !Kirigami.Settings.tabletMode && !listItem.isSeparator
    font.pointSize: isExpandable ? Kirigami.Theme.defaultFont.pointSize * 1.30 : Kirigami.Theme.defaultFont.pointSize
    height: implicitHeight * opacity

    data: [
        QQC2.ToolTip {
            visible: !listItem.isSeparator && (modelData.hasOwnProperty("tooltip") && modelData.tooltip.length || root.collapsed) && (!actionsMenu || !actionsMenu.visible) &&  listItem.hovered && text.length > 0
            text: modelData.hasOwnProperty("tooltip") && modelData.tooltip.length ? modelData.tooltip : modelData.text
            delay: Kirigami.Units.toolTipDelay
            y: listItem.height/2 - height/2
            x: Qt.application.layoutDirection === Qt.RightToLeft ? -width : listItem.width
        }
    ]

    onHoveredChanged: {
        if (!hovered) {
            return;
        }
        if (stackView.openSubMenu) {
            stackView.openSubMenu.visible = false;

            if (!listItem.actionsMenu.hasOwnProperty("count") || listItem.actionsMenu.count>0) {
                if (listItem.actionsMenu.hasOwnProperty("popup")) {
                    listItem.actionsMenu.popup(listItem, listItem.width, 0)
                } else {
                    listItem.actionsMenu.visible = true;
                }
            }
        }
    }

    onClicked: trigger()
    Keys.onEnterPressed: event => trigger()
    Keys.onReturnPressed: event => trigger()

    function trigger() {
        modelData.trigger();
        if (modelData.hasOwnProperty("children") && modelData.children!==undefined && modelData.children.length > 0) {
            if (root.collapsed) {
                // fallbacks needed for Qt 5.9
                if ((!listItem.actionsMenu.hasOwnProperty("count") || listItem.actionsMenu.count>0) && !listItem.actionsMenu.visible) {
                    stackView.openSubMenu = listItem.actionsMenu;
                    if (listItem.actionsMenu.hasOwnProperty("popup")) {
                        listItem.actionsMenu.popup(listItem, listItem.width, 0)
                    } else {
                        listItem.actionsMenu.visible = true;
                    }
                }
            } else {
                stackView.push(menuComponent, {model: modelData.children, level: level + 1, current: modelData });
            }
        } else if (root.resetMenuOnTriggered) {
            root.resetMenu();
        }
        checked = Qt.binding(function() { return modelData.checked || (actionsMenu && actionsMenu.visible) });
    }

    Keys.onDownPressed: event => nextItemInFocusChain().focus = true
    Keys.onUpPressed: event => nextItemInFocusChain(false).focus = true
}
