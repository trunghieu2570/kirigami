/*
 *  SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2

/**
 * This is a label which supports text selection.
 *
 * You can use all elements of the QML TextArea component, in particular
 * the "text" property to define the label text.
 *
 * @code{.qml}
 *     Kirigami.SelectableLabel {
 *         text: "Label"
 *     }
 * @endcode
 *
 * @inherit QtQuick.Controls.TextArea
 * @see https://bugreports.qt.io/browse/QTBUG-14077
 * @since 5.95
 * @since org.kde.kirigami 2.20
 */
QQC2.TextArea {
    id: selectableLabel

    /**
     * This property holds the cursor shape that will appear whenever
     * the mouse is hovering over the label.
     *
     * The default value is @c Qt.IBeamCursor
     *
     * @property Qt::CursorShape cursorShape
     */
    property alias cursorShape: hoverHandler.cursorShape

    padding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    readOnly: true
    wrapMode: Text.WordWrap
    textFormat: TextEdit.AutoText
    verticalAlignment: TextEdit.AlignTop

    Accessible.selectableText: true
    Accessible.editable: false

    background: Item {}

    HoverHandler {
        id: hoverHandler
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
    }
}
