/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12

import org.kde.kirigami 2.16

pragma Singleton

/**
 * Basic theme definition that contains some default colors.
 *
 * Please Note: This is instantiated by Kirigami and acts as backend for the
 * Theme attached property. Properties here do not necessarily reflect those of
 * the attached property, see Kirigami::PlatformTheme for the properties that
 * should be used instead.
 */
BasicThemeDefinition {
    textColor: "#31363b"
    disabledTextColor: "#9931363b"

    highlightColor: "#2196F3"
    highlightedTextColor: "#eff0fa"
    backgroundColor: "#eff0f1"
    alternateBackgroundColor: "#bdc3c7"

    activeTextColor: "#0176D3"
    activeBackgroundColor: "#0176D3"
    linkColor: "#2196F3"
    linkBackgroundColor: "#2196F3"
    visitedLinkColor: "#2196F3"
    visitedLinkBackgroundColor: "#2196F3"
    negativeTextColor: "#DA4453"
    negativeBackgroundColor: "#DA4453"
    neutralTextColor: "#F67400"
    neutralBackgroundColor: "#F67400"
    positiveTextColor: "#27AE60"
    positiveBackgroundColor: "#27AE60"

    buttonTextColor: "#31363b"
    buttonBackgroundColor: "#eff0f1"
    buttonAlternateBackgroundColor: "#bdc3c7"
    buttonHoverColor: "#2196F3"
    buttonFocusColor: "#2196F3"

    viewTextColor: "#31363b"
    viewBackgroundColor: "#fcfcfc"
    viewAlternateBackgroundColor: "#eff0f1"
    viewHoverColor: "#2196F3"
    viewFocusColor: "#2196F3"

    selectionTextColor: "#eff0fa"
    selectionBackgroundColor: "#2196F3"
    selectionAlternateBackgroundColor: "#1d99f3"
    selectionHoverColor: "#2196F3"
    selectionFocusColor: "#2196F3"

    tooltipTextColor: "#eff0f1"
    tooltipBackgroundColor: "#31363b"
    tooltipAlternateBackgroundColor: "#4d4d4d"
    tooltipHoverColor: "#2196F3"
    tooltipFocusColor: "#2196F3"

    complementaryTextColor: "#eff0f1"
    complementaryBackgroundColor: "#31363b"
    complementaryAlternateBackgroundColor: "#3b4045"
    complementaryHoverColor: "#2196F3"
    complementaryFocusColor: "#2196F3"

    headerTextColor: "#232629"
    headerBackgroundColor: "#e3e5e7"
    headerAlternateBackgroundColor: "#eff0f1"
    headerHoverColor: "#2196F3"
    headerFocusColor: "#93cee9"
}
