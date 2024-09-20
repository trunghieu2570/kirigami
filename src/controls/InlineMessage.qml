/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2018 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as KT

KT.InlineMessage {
    id: root

    // a rectangle padded with anchors.margins is used to simulate a border
    leftPadding: bgFillRect.anchors.leftMargin + Kirigami.Units.smallSpacing
    topPadding: bgFillRect.anchors.topMargin + Kirigami.Units.smallSpacing
    rightPadding: bgFillRect.anchors.rightMargin + Kirigami.Units.smallSpacing
    bottomPadding: bgFillRect.anchors.bottomMargin + Kirigami.Units.smallSpacing

    background: Rectangle {
        id: bgBorderRect

        color: switch (root.type) {
            case Kirigami.MessageType.Positive: return Kirigami.Theme.positiveTextColor;
            case Kirigami.MessageType.Warning: return Kirigami.Theme.neutralTextColor;
            case Kirigami.MessageType.Error: return Kirigami.Theme.negativeTextColor;
            default: return Kirigami.Theme.activeTextColor;
        }

        radius: root.position === KT.InlineMessage.Position.Inline ? Kirigami.Units.cornerRadius : 0

        Rectangle {
            id: bgFillRect

            anchors.fill: parent
            anchors {
                leftMargin: root.position === KT.InlineMessage.Position.Inline ? 1 : 0
                topMargin: root.position === KT.InlineMessage.Position.Header ? 0 : 1
                rightMargin: root.position === KT.InlineMessage.Position.Inline ? 1 : 0
                bottomMargin: root.position === KT.InlineMessage.Position.Footer ? 0 : 1
            }

            color: Kirigami.Theme.backgroundColor

            radius: bgBorderRect.radius * 0.60
        }

        Rectangle {
            anchors.fill: bgFillRect

            color: bgBorderRect.color

            opacity: 0.20

            radius: bgFillRect.radius
        }
    }
}
