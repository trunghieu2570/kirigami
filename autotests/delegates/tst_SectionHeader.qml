/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import QtTest 1.15

TestCase {
    id: testCase
    name: "ListSectionHeader"
    when: windowShown
    visible: true

    width: ui.implicitWidth
    height: ui.implicitHeight

    SectionHeader_Test {
        id: ui
    }

    // without content
    function test_headerNotTruncated() {
        const h = ui.getHeading(ui.headerNotTruncated);
        const s = ui.getSeparator(ui.headerNotTruncated);
        verify(!h.truncated);
        verify(s.visible);
    }
    function test_headerNotTruncatedWithoutRoomForSeparator() {
        const h = ui.getHeading(ui.headerNotTruncatedWithoutRoomForSeparator);
        const s = ui.getSeparator(ui.headerNotTruncatedWithoutRoomForSeparator);
        verify(!h.truncated);
        verify(!s.visible);
    }
    function test_headerExactFitText() {
        const h = ui.getHeading(ui.headerExactFitText);
        const s = ui.getSeparator(ui.headerExactFitText);
        verify(!h.truncated);
        verify(!s.visible);
    }
    function test_headerTruncated() {
        const h = ui.getHeading(ui.headerTruncated);
        const s = ui.getSeparator(ui.headerTruncated);
        verify(h.truncated);
        verify(!s.visible);
    }
    function test_truncatedToolTip() {
        mouseMove(ui.headerTruncated, ui.headerTruncated.width / 2, ui.headerTruncated.height / 2);
        tryCompare(QQC2.ToolTip.toolTip, "visible", true, QQC2.ToolTip.toolTip.delay * 1.1);
        compare(QQC2.ToolTip.toolTip.text, ui.headerTruncated.text);
    }
    // with fixed content
    function test_headerWideWithFixedContent() {
        const h = ui.getHeading(ui.headerWideWithFixedContent);
        const s = ui.getSeparator(ui.headerWideWithFixedContent);
        verify(!h.truncated);
        verify(s.visible);
    }
    function test_headerWithFixedContentWithoutRoomForSeparator() {
        const h = ui.getHeading(ui.headerWithFixedContentWithoutRoomForSeparator);
        const s = ui.getSeparator(ui.headerWithFixedContentWithoutRoomForSeparator);
        verify(!h.truncated);
        verify(!s.visible);
    }
    function test_headerWithFixedContentFollowsImplicitSize() {
        const h = ui.getHeading(ui.headerWithFixedContentFollowsImplicitSize);
        const s = ui.getSeparator(ui.headerWithFixedContentFollowsImplicitSize);
        verify(!h.truncated);
        verify(!s.visible);
    }
    function test_headerTruncatedWithFixedContent() {
        const h = ui.getHeading(ui.headerTruncatedWithFixedContent);
        const s = ui.getSeparator(ui.headerTruncatedWithFixedContent);
        const b = ui.headerTruncatedWithFixedContentButton;
        verify(h.truncated);
        verify(!s.visible);
        verify(b.width, b.implicitWidth);
    }
    // with adaptive content
    function test_headerWithContentFillWidth() {
        const h = ui.getHeading(ui.headerWithContentFillWidth);
        const s = ui.getSeparator(ui.headerWithContentFillWidth);
        verify(!h.truncated);
        verify(s.visible);
        compare(s.width, Kirigami.Units.gridUnit * 3);
    }
    function test_headerWithPreferredWidthContent() {
        const h = ui.getHeading(ui.headerWithPreferredWidthContent);
        const s = ui.getSeparator(ui.headerWithPreferredWidthContent);
        verify(!h.truncated);
        verify(s.visible);
        compare(s.width, Kirigami.Units.gridUnit * 1);
    }
    function test_headerWithWidePreferredWidthContent() {
        const h = ui.getHeading(ui.headerWithWidePreferredWidthContent);
        const s = ui.getSeparator(ui.headerWithWidePreferredWidthContent);
        verify(h.truncated);
        verify(!s.visible);
    }
}
