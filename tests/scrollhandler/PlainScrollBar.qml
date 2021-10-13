/* SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick 2.15
import QtQuick.Templates 2.15 as T

T.ScrollBar {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                            implicitContentHeight + topPadding + bottomPadding)

    padding: 5
    visible: (size < 1 && policy === T.ScrollBar.AsNeeded) || policy === T.ScrollBar.AlwaysOn
    minimumSize: horizontal ? height / width : width / height

    contentItem: Rectangle {
        implicitWidth: 10
        implicitHeight: 10
        color: control.pressed ? control.palette.highlight : control.palette.buttonText
        radius: Math.min(width, height) / 2
    }

    background: Rectangle {
        color: control.palette.button
        opacity: 0.5
    }
}
