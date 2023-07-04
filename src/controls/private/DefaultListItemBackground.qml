/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami 2 as Kirigami

Rectangle {
    id: background

    required property T.Control listItem

    readonly property bool selected: listItem.highlighted || listItem.checked || (listItem.down && !listItem.checked && !listItem.sectionDelegate) || listItem.visualFocus

    radius: Kirigami.Units.mediumSpacing

    color: if (listItem.activeFocus || listItem.hovered) {
        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.highlightColor, 0.15)
    } else if (background.selected) {
        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.10)
    } else {
        Kirigami.Theme.backgroundColor
    }

    border {
        color: listItem.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.5)
        width: background.selected || listItem.activeFocus ? 1 : 0
    }

    Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }

    Kirigami.Separator {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
        }
        visible: {
            // Whether there is visual feedback (do not show the separator)
            const visualFeedback = listItem.highlighted || listItem.down || listItem.checked || listItem.ListView.isCurrentItem

            // Show the separator when activeBackgroundColor is set to "transparent",
            // when the item is hovered. Check commit 344aec26.
            const bgTransparent = !listItem.hovered || listItem.activeBackgroundColor.a === 0

            // Whether the next item is a section delegate or is from another section (do not show the separator)
            const anotherSection = listItem.ListView.view === null || listItem.ListView.nextSection === listItem.ListView.section

            // Whether this item is the last item in the view (do not show the separator)
            const lastItem = listItem.ListView.view === null || listItem.ListView.count - 1 !== index

            return listItem.separatorVisible && !visualFeedback && bgTransparent
                && !listItem.sectionDelegate && anotherSection && lastItem
        }
        weight: Kirigami.Separator.Weight.Light
    }
}

