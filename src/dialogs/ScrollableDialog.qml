/*
    SPDX-FileCopyrightText: 2024 Joshua Goins <josh@redstrate.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/**
 * @brief Popup dialog that is used for interactive and scrollable content, such as a list of items.
 *
 * Provides no padding ideal for scrolling content like a ListView or a ScrollView.
 *
 * @see Dialog
 *
 * Example usage:
 *
 * @code{.qml}
 * import QtQuick
 * import QtQuick.Layouts
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.ScrollableDialog {
 *     id: scrollableDialog
 *     title: i18n("Select Number")
 *
 *     ListView {
 *         id: listView
 *         // hints for the dialog dimensions
 *         implicitWidth: Kirigami.Units.gridUnit * 16
 *         implicitHeight: Kirigami.Units.gridUnit * 16
 *
 *         model: 100
 *         delegate: QQC2.RadioDelegate {
 *             topPadding: Kirigami.Units.smallSpacing * 2
 *             bottomPadding: Kirigami.Units.smallSpacing * 2
 *             implicitWidth: listView.width
 *             text: modelData
 *         }
 *     }
 * }
 * @endcode
 *
 * @inherit Dialog
 */
Kirigami.Dialog {
    id: root

    padding: 0
}
