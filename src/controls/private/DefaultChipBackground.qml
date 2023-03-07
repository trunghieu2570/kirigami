// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

Rectangle {

    /**
     * @brief This property holds the chip's default background color.
     */
    property color defaultColor: Kirigami.Theme.backgroundColor

    /**
     * @brief This property holds the color of the Chip's background when it is being pressed.
     * @see QtQuick.AbstractButton::down
     */
    property color pressedColor: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.3)

    /**
     * @brief This property holds the color of the Chip's background when it is checked.
     * @see QtQuick.AbstractButton::checked
     */
    property color checkedColor: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2)

    /**
     * @brief This property holds the chip's default border color.
     */
    property color defaultBorderColor: Qt.darker(defaultColor, 1.1)

    /**
     * @brief This property holds the color of the Chip's border when it is checked.
     * @see QtQuick.AbstractButton::checked
     */
    property color checkedBorderColor: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.9)

    /**
     * @brief This property holds the color of the Chip's border when it is being pressed.
     * @see QtQuick.AbstractButton::down
     */
    property color pressedBorderColor: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.7)

    Kirigami.Theme.colorSet: Kirigami.Theme.Header
    Kirigami.Theme.inherit: false

    color: {
        if (parent.down) {
            return pressedColor
        } else if (parent.checked) {
            return checkedColor
        } else {
            return defaultColor
        }
    }
    border.color: {
        if (parent.down) {
            return pressedBorderColor
        } else if (parent.checked) {
            return checkedBorderColor
        } else {
            return defaultBorderColor
        }
    }
    border.width: 1
    radius: 3
}
