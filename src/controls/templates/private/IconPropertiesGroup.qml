/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQml 2.15

/**
 * @brief Group of icon properties.
 *
 * This is a subset of those used in QQC2, Kirigami.Action still needs the full one as needs 100% api compatibility
 */
QtObject {
    /**
     * @brief This property holds icon name.
     *
     * The icon will be loaded from the platform theme. If the icon is found
     * in the theme, it will always be used; even if icon.source is also set.
     * If the icon is not found, icon.source will be used instead.
     */
    property string name

    /**
     * @brief This property holds the icon source.
     *
     * The icon will be loaded as a regular image.
     *
     * @see QtQuick.Image::source
     */
    property var source

    /**
     * @brief This property holds the icon tint color.
     *
     * The icon is tinted with the specified color, unless the color is set to "transparent".
     */
    property color color: Qt.rgba(0, 0, 0, 0)

    /**
     * This property holds the width of the icon.
     */
    property real width

    /**
     * This property holds the height of the icon.
     */
    property real height
}

