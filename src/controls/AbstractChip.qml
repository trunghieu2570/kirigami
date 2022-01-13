// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.19 as Kirigami
import "templates" as T
import "private"

/**
 * A AbstractCard is the base for chips. A Chip is a visual object that provides
 * an very friendly way to display predetermined options.
 * providing just the look and the base properties and signals for an AbstractButton.
 *
 * @see Chip
 * @inherit org::kde::kirigami::templates::AbstractChip
 * @since 2.19
 */
T.AbstractChip {
    id: root

    background: DefaultChipBackground {}
}
