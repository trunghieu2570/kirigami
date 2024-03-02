/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQml
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

T.ToolButton {
    id: control

    signal menuAboutToShow()

    implicitWidth: Math.max((text && display !== T.AbstractButton.IconOnly ?
        implicitBackgroundWidth : implicitHeight) + leftInset + rightInset,
        implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    hoverEnabled: Qt.styleHints.useHoverEffects

    display: QQC2.ToolButton.TextBesideIcon

    property bool showMenuArrow: !Kirigami.DisplayHint.displayHintSet(action, Kirigami.DisplayHint.HideChildIndicator)

    property list<T.Action> menuActions: {
        if (action instanceof Kirigami.Action) {
            return action.children;
        }
        return []
    }

    property Component menuComponent: ActionsMenu {
        submenuComponent: ActionsMenu { }
    }

    property QtObject menu: null

    // We create the menu instance only when there are any actual menu items.
    // This also happens in the background, avoiding slowdowns due to menu item
    // creation on the main thread.
    onMenuActionsChanged: {
        if (menuComponent && menuActions.length > 0) {
            if (!menu) {
                const setupIncubatedMenu = incubatedMenu => {
                    menu = incubatedMenu
                    // Important: We handle the press on parent in the parent, so ignore it here.
                    menu.closePolicy = QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent
                    menu.closed.connect(() => control.checked = false)
                    menu.actions = control.menuActions
                }
                const incubator = menuComponent.incubateObject(control, { actions: menuActions })
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = status => {
                        if (status === Component.Ready) {
                            setupIncubatedMenu(incubator.object)
                        }
                    }
                } else {
                    setupIncubatedMenu(incubator.object);
                }
            } else {
                menu.actions = menuActions
            }
        }
    }

    visible: action instanceof Kirigami.Action ? action.visible : true

    property bool highlightBackground: down || checked
    property bool highlightBorder: control.enabled && control.down || control.checked || control.highlighted || control.visualFocus || control.hovered

    background: Rectangle {
        property color flatColor: Qt.rgba(
            Kirigami.Theme.backgroundColor.r,
            Kirigami.Theme.backgroundColor.g,
            Kirigami.Theme.backgroundColor.b,
            0
        )

        color: if (buttonDelegate.highlightBackground) {
            return Kirigami.Theme.alternateBackgroundColor
        } else if (buttonDelegate.flat) {
            return flatColor
        } else {
            return Kirigami.Theme.backgroundColor
        }

        radius: 3

        border {
            color: if (highlightBorder) {
                return Kirigami.Theme.focusColor
            } else {
                return Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)
            }
            width: 1
        }
    }

    contentItem: RowLayout {
        Kirigami.Icon {
            source: control.icon.name ? control.icon.name : control.icon.source
            Layout.preferredHeight: Kirigami.Units.iconSizes.sizeForLabels
            Layout.preferredWidth: Kirigami.Units.iconSizes.sizeForLabels
        }

        QQC2.Label {
            text: control.text
        }
    }

    padding: Kirigami.Units.mediumSpacing

    // Workaround for QTBUG-85941
    Binding {
        target: control
        property: "checkable"
        value: (control.action?.checkable ?? false) || (control.menuActions.length > 0)
        restoreMode: Binding.RestoreBinding
    }

    onToggled: {
        if (menuActions.length > 0 && menu) {
            if (checked) {
                control.menuAboutToShow();
                menu.popup(control, 0, control.height)
            } else {
                menu.dismiss()
            }
        }
    }

    QQC2.ToolTip {
        visible: control.hovered && text.length > 0 && !(control.menu && control.menu.visible) && !control.pressed
        text: {
            const a = control.action;
            if (a) {
                if (a.tooltip) {
                    return a.tooltip;
                } else if (control.display === QQC2.Button.IconOnly) {
                    return a.text;
                }
            }
            return "";
        }
    }

    // This will set showMenuArrow when using qqc2-desktop-style.
    Accessible.role: (control.showMenuArrow && control.menuActions.length > 0) ? Accessible.ButtonMenu : Accessible.Button
    Accessible.ignored: !visible
}
