/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import "../../private" as P
import "../../templates" as T
import org.kde.kirigami 2 as Kirigami

T.AbstractListItem {
    id: root

    background: P.DefaultListItemBackground {
        listItem: root
    }

    padding: Kirigami.Units.largeSpacing
    leftPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

    topInset: Kirigami.Units.smallSpacing / 2
    bottomInset: Kirigami.Units.smallSpacing / 2
    rightInset: Kirigami.Units.smallSpacing
    leftInset: Kirigami.Units.smallSpacing
}
