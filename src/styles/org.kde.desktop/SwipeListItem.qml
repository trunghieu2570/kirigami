/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import "../../private" as P
import "../../templates" as T
import org.kde.kirigami 2 as Kirigami

T.SwipeListItem {
    id: root

    background: P.DefaultListItemBackground {
        listItem: root
        radius: 0
    }
}
