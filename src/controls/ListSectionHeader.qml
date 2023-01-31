/*
 *  SPDX-FileCopyrightText: 2019 Björn Feber <bfeber@protonmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.10 as Kirigami

/**
 * @brief A section delegate for the primitive ListView component.
 *
 * It's intended to make all listviews look coherent.
 *
 * Example usage:
 * @code
 * import QtQuick 2.15
 * import QtQuick.Controls 2.15 as QQC2
 * import org.kde.kirigami 2.20 as Kirigami
 *
 * ListView {
 *     section.delegate: Kirigami.ListSectionHeader {
 *         label: section
 *
 *         QQC2.Button {
 *             text: "Button 1"
 *         }
 *         QQC2.Button {
 *             text: "Button 2"
 *         }
 *     }
 * }
 * @endcode
 */
Kirigami.AbstractListItem {
    id: controlRoot

    /**
     * @brief This property sets the text of the ListView's section header.
     * @property string label
     */
    property alias label: controlRoot.text

    default property alias __trailingContent: trailingContent.data

    separatorVisible: false
    sectionDelegate: true

    activeFocusOnTab: false

    // we do not need a background
    background: Item {}

    topPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

    implicitWidth: contentItem === layout
        ? (Math.ceil(textMetrics.advanceWidth) + layout.reservedWidthForTrailingContent + leftPadding + rightPadding)
        : (contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : Kirigami.Units.gridUnit * 12)

    // Ideally, we should show a ToolTip only for truncated labels, but due to
    // QTBUG-106489 we can't use enabled HoverHandler in lists. Binding to
    // the whole Control::hovered would break after showing custom tooltips
    // inside trailing content, requiring mouse cursor to re-enter the
    // delegate to activate this tooltip again, so it's a UX compromise.
    QQC2.ToolTip.text: text
    QQC2.ToolTip.visible: heading.truncated && (Kirigami.Settings.tabletMode ? controlRoot.pressed : controlRoot.hovered)
    QQC2.ToolTip.delay: Kirigami.Settings.tabletMode ? Qt.styleHints.mousePressAndHoldInterval : Kirigami.Units.toolTipDelay

    contentItem: RowLayout {
        id: layout
        spacing: 0

        readonly property bool hasTrailingContent: trailingContent.visibleChildren.length > 0
        readonly property real reservedWidthForTrailingContent: hasTrailingContent ? (trailingContent.implicitWidth + Kirigami.Units.largeSpacing) : 0
        readonly property real maximumHeaderWidth: Math.floor(controlRoot.availableWidth - reservedWidthForTrailingContent)
        readonly property bool hasRoomForSeparator: controlRoot.availableWidth - (Math.ceil(textMetrics.advanceWidth) + Kirigami.Units.largeSpacing + reservedWidthForTrailingContent) >= separator.Layout.minimumWidth

        TextMetrics {
            id: textMetrics
            font: heading.font
            text: heading.text
        }

        // Similar to Kirigami.Heading, but it's both bold (for contrast with small text) and semi-transparent.
        QQC2.Label {
            id: heading

            text: controlRoot.text

            elide: Text.ElideRight
            font.pointSize: Kirigami.Theme.defaultFont.pointSize
            font.weight: Font.Bold
            opacity: 0.7
            Accessible.role: Accessible.Heading

            Layout.fillWidth: false
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: layout.maximumHeaderWidth
        }

        Kirigami.Separator {
            id: separator

            visible: layout.hasRoomForSeparator

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: layout.hasTrailingContent ? Kirigami.Units.largeSpacing : 0
            Layout.minimumWidth: Kirigami.Units.gridUnit
        }

        RowLayout {
            id: trailingContent

            spacing: Kirigami.Units.largeSpacing

            Layout.fillWidth: false
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            Layout.leftMargin: layout.hasRoomForSeparator ? 0 : Kirigami.Units.largeSpacing
            Layout.maximumWidth: controlRoot.availableWidth
        }
    }
}
