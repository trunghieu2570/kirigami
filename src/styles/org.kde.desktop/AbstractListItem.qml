/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.4
import "private"
import "../../templates" as T

T.AbstractListItem {
    id: listItem

    // we use focusColor with low opacity and alpha for the background
    // which is very soft, so the highlighted text color should be the normal text color
    Theme.highlightedTextColor: Theme.textColor
    Theme.inherit: false

    background: DefaultListItemBackground {}
}
