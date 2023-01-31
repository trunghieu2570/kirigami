/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: root

    // without content
    property alias headerNotTruncated: headerNotTruncated
    property alias headerNotTruncatedWithoutRoomForSeparator: headerNotTruncatedWithoutRoomForSeparator
    property alias headerExactFitText: headerExactFitText
    property alias headerTruncated: headerTruncated
    // with fixed content
    property alias headerWideWithFixedContent: headerWideWithFixedContent
    property alias headerWithFixedContentWithoutRoomForSeparator: headerWithFixedContentWithoutRoomForSeparator
    property alias headerWithFixedContentFollowsImplicitSize: headerWithFixedContentFollowsImplicitSize
    property alias headerTruncatedWithFixedContent: headerTruncatedWithFixedContent
    property alias headerTruncatedWithFixedContentButton: headerTruncatedWithFixedContentButton
    // with adaptive content
    property alias headerWithContentFillWidth: headerWithContentFillWidth
    property alias headerWithPreferredWidthContent: headerWithPreferredWidthContent
    property alias headerWithWidePreferredWidthContent: headerWithWidePreferredWidthContent

    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    width: implicitWidth
    height: implicitHeight

    color: Kirigami.Theme.backgroundColor

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextMetrics {
        id: headingMetrics
        font: root.getHeading(dummyHeader).font
        text: "ABCDEF 123456"
    }

    Kirigami.ListSectionHeader {
        id: dummyHeader
        opacity: 0
        z: -1
        enabled: false
        text: "ABCDEF 123456"
        QQC2.ToolButton {
            id: buttonMetrics
            icon.name: "edit-copy"
        }
    }

    component ListSectionHeaderWithBrightBackground : Kirigami.ListSectionHeader {
        text: headingMetrics.text
        background: Rectangle {
            color: "green"
            border.color: "#000"
            border.width: 1
            radius: 5
        }
    }

    // Can be squeezed, but prefers to be wider.
    component ButtonWithWidePreferences : QQC2.ToolButton {
        icon.name: "edit-paste"
        Layout.preferredWidth: implicitWidth + Kirigami.Units.gridUnit * 2
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: 0

        // Plenty of room for text and separator.
        ListSectionHeaderWithBrightBackground {
            id: headerNotTruncated
            Layout.preferredWidth: (Math.ceil(headingMetrics.advanceWidth) + leftPadding + rightPadding) * 1.5
            Layout.fillWidth: false
        }

        // A bit more room than needed for text, but not enough for separator.
        ListSectionHeaderWithBrightBackground {
            id: headerNotTruncatedWithoutRoomForSeparator
            Layout.fillWidth: false
            Layout.preferredWidth: Math.ceil(headingMetrics.advanceWidth) + leftPadding + rightPadding + Kirigami.Units.gridUnit
        }

        // Just enough width to fit text.
        ListSectionHeaderWithBrightBackground {
            id: headerExactFitText
            Layout.fillWidth: false
            Layout.preferredWidth: Math.ceil(headingMetrics.advanceWidth) + leftPadding + rightPadding
        }

        // Barely not enough width to fit text.
        ListSectionHeaderWithBrightBackground {
            id: headerTruncated
            Layout.fillWidth: false
            Layout.preferredWidth: Math.ceil(headingMetrics.advanceWidth) + leftPadding + rightPadding - 1
        }

        // Text should not elide, separator should be visible
        ListSectionHeaderWithBrightBackground {
            id: headerWideWithFixedContent
            Layout.fillWidth: false
            Layout.preferredWidth: Math.ceil(headingMetrics.advanceWidth) + buttonMetrics.implicitWidth + Kirigami.Units.largeSpacing * 2 + leftPadding + rightPadding + Kirigami.Units.gridUnit
            QQC2.ToolButton {
                icon.name: "edit-copy"
            }
        }

        // Text should not elide, separator should not be visible
        ListSectionHeaderWithBrightBackground {
            id: headerWithFixedContentWithoutRoomForSeparator
            Layout.fillWidth: false
            Layout.preferredWidth: Math.ceil(headingMetrics.advanceWidth) + buttonMetrics.implicitWidth + Kirigami.Units.largeSpacing * 2 + leftPadding + rightPadding + Kirigami.Units.largeSpacing
            QQC2.ToolButton {
                icon.name: "edit-copy"
            }
        }

        // Should be just text and button, but no separator
        ListSectionHeaderWithBrightBackground {
            id: headerWithFixedContentFollowsImplicitSize
            Layout.fillWidth: false
            Layout.preferredWidth: implicitWidth
            QQC2.ToolButton {
                icon.name: "edit-copy"
            }
        }

        ListSectionHeaderWithBrightBackground {
            id: headerTruncatedWithFixedContent
            Layout.fillWidth: false
            Layout.preferredWidth: implicitWidth - 1
            QQC2.ToolButton {
                id: headerTruncatedWithFixedContentButton
                icon.name: "edit-copy"
            }
        }

        // `Layout.fillWidth: true` should not stretch
        ListSectionHeaderWithBrightBackground {
            id: headerWithContentFillWidth
            Layout.fillWidth: false
            Layout.preferredWidth: Math.ceil(headingMetrics.advanceWidth) + buttonMetrics.implicitWidth + Kirigami.Units.largeSpacing * 2 + leftPadding + rightPadding + Kirigami.Units.gridUnit * 3
            QQC2.ToolButton {
                icon.name: "edit-copy"
                Layout.fillWidth: true
            }
        }

        // Preferred width should be honored
        ListSectionHeaderWithBrightBackground {
            id: headerWithPreferredWidthContent
            Layout.fillWidth: false
            Layout.preferredWidth: headerWithContentFillWidth.Layout.preferredWidth

            ButtonWithWidePreferences {
            }
        }

        // Ideally, header text should take precedence, so that button would
        // shrink to its minimum size first. But there's no layouts API which
        // would allow specifying such behavior.
        ListSectionHeaderWithBrightBackground {
            id: headerWithWidePreferredWidthContent
            Layout.fillWidth: false
            Layout.preferredWidth: headerWithContentFillWidth.Layout.preferredWidth

            ButtonWithWidePreferences {
                Layout.minimumWidth: implicitWidth
                Layout.preferredWidth: implicitWidth + Kirigami.Units.gridUnit * 4
            }
        }
    }

    function getHeading(header): QQC2.Label {
        return header.contentItem.children[0];
    }

    function getSeparator(header): Kirigami.Separator {
        return header.contentItem.children[1];
    }
}
