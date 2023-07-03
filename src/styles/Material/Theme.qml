/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls.Material 2.0
import org.kde.kirigami 2.16 as Kirigami

/**
 * \internal
 */
Kirigami.BasicThemeDefinition {
    textColor: Material.foreground
    disabledTextColor: Qt.rgba(theme.textColor.r, theme.textColor.g, theme.textColor.b, 0.6)

    highlightColor: Material.accent
    //FIXME: something better?
    highlightedTextColor: Material.background
    backgroundColor: Material.background
    alternateBackgroundColor: Qt.darker(Material.background, 1.05)

    hoverColor: Material.highlightedButtonColor
    focusColor: Material.highlightedButtonColor

    activeTextColor: Material.primary
    activeBackgroundColor: Material.primary
    linkColor: "#2980B9"
    linkBackgroundColor: "#2980B9"
    visitedLinkColor: "#7F8C8D"
    visitedLinkBackgroundColor: "#7F8C8D"
    negativeTextColor: "#DA4453"
    negativeBackgroundColor: "#DA4453"
    neutralTextColor: "#F67400"
    neutralBackgroundColor: "#F67400"
    positiveTextColor: "#27AE60"
    positiveBackgroundColor: "#27AE60"

    buttonTextColor: Material.foreground
    buttonBackgroundColor: Material.buttonColor
    buttonAlternateBackgroundColor: Qt.darker(Material.buttonColor, 1.05)
    buttonHoverColor: Material.highlightedButtonColor
    buttonFocusColor: Material.highlightedButtonColor

    viewTextColor: Material.foreground
    viewBackgroundColor: Material.dialogColor
    viewAlternateBackgroundColor: Qt.darker(Material.dialogColor, 1.05)
    viewHoverColor: Material.listHighlightColor
    viewFocusColor: Material.listHighlightColor

    selectionTextColor: Material.primaryHighlightedTextColor
    selectionBackgroundColor: Material.textSelectionColor
    selectionAlternateBackgroundColor: Qt.darker(Material.textSelectionColor, 1.05)
    selectionHoverColor: Material.highlightedButtonColor
    selectionFocusColor: Material.highlightedButtonColor

    tooltipTextColor: fontMetrics.Material.foreground
    tooltipBackgroundColor: fontMetrics.Material.tooltipColor
    tooltipAlternateBackgroundColor: Qt.darker(Material.tooltipColor, 1.05)
    tooltipHoverColor: fontMetrics.Material.highlightedButtonColor
    tooltipFocusColor: fontMetrics.Material.highlightedButtonColor

    complementaryTextColor: fontMetrics.Material.foreground
    complementaryBackgroundColor: fontMetrics.Material.background
    complementaryAlternateBackgroundColor: Qt.lighter(fontMetrics.Material.background, 1.05)
    complementaryHoverColor: Material.highlightedButtonColor
    complementaryFocusColor: Material.highlightedButtonColor

    headerTextColor: fontMetrics.Material.primaryTextColor
    headerBackgroundColor: fontMetrics.Material.primaryColor
    headerAlternateBackgroundColor: Qt.lighter(fontMetrics.Material.primaryColor, 1.05)
    headerHoverColor: Material.highlightedButtonColor
    headerFocusColor: Material.highlightedButtonColor

    defaultFont: fontMetrics.font

    property list<QtObject> children: [
        TextMetrics {
            id: fontMetrics
            //this is to get a source of dark colors
            Material.theme: Material.Dark
        }
    ]

    onSync: object => {
        //TODO: actually check if it's a dark or light color
        if (object.Kirigami.Theme.colorSet === Kirigami.Theme.Complementary) {
            object.Material.theme = Material.Dark
        } else {
            object.Material.theme = Material.Light
        }

        object.Material.foreground = object.Kirigami.Theme.textColor
        object.Material.background = object.Kirigami.Theme.backgroundColor
        object.Material.primary = object.Kirigami.Theme.highlightColor
        object.Material.accent = object.Kirigami.Theme.highlightColor
    }
}
