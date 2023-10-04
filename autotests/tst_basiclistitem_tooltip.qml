/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import QtTest

// Note about tooltips: they set `visible: true` as soon as they start enter
// animation, and stay that way until exit animation completes. Actual
// tooltip instance's visible state is not the same as QQC2.ToolTip.visible
// attached property value.
// Delays (timeouts) in tests are slightly increased to mitigate possible races.
TestCase {
    name: "BasicListItemToolTip"
    visible: true
    when: windowShown

    width: ui.implicitWidth
    height: ui.implicitHeight

    BasicListItem_ToolTip_Test {
        id: ui
        anchors.fill: parent
    }

    function test_bothNotElided() {
        mouseMove(ui.itemBothNotElided);
        wait(QQC2.ToolTip.toolTip.delay * 1.1);
        compare(QQC2.ToolTip.toolTip.visible, false);
    }

    function test_labelElided() {
        mouseMove(ui.itemLabelElided);
        tryCompare(QQC2.ToolTip.toolTip, "visible", true, QQC2.ToolTip.toolTip.delay * 1.1);
        compare(QQC2.ToolTip.toolTip.text, ui.itemLabelElided.label);
    }

    function test_subtitleElided() {
        mouseMove(ui.itemSubtitleElided);
        tryCompare(QQC2.ToolTip.toolTip, "visible", true, QQC2.ToolTip.toolTip.delay * 1.1);
        compare(QQC2.ToolTip.toolTip.text, ui.itemSubtitleElided.subtitle);
    }

    function test_bothElided() {
        mouseMove(ui.itemBothElided);
        tryCompare(QQC2.ToolTip.toolTip, "visible", true, QQC2.ToolTip.toolTip.delay * 1.1);
        compare(QQC2.ToolTip.toolTip.text, `${ui.itemBothElided.label}<br/><br/>${ui.itemBothElided.subtitle}`);
    }

    function test_htmlElided() {
        mouseMove(ui.itemHtmlElided);
        tryCompare(QQC2.ToolTip.toolTip, "visible", true, QQC2.ToolTip.toolTip.delay * 1.1);
        compare(QQC2.ToolTip.toolTip.text, `${ui.itemHtmlElided.label}<br/><br/>${ui.itemHtmlElided.subtitle}`);
    }
}
