/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    id: testCase

    name: "HeaderFooterLayoutTests"
    when: windowShown

    width: 300
    height: 300
    visible: true

    Component {
        id: implicitSizeComponent
        Kirigami.HeaderFooterLayout {
            header: Rectangle {
                color: "red"
                implicitHeight: 30
                implicitWidth: 100
            }
            contentItem: Rectangle {
                color: "green"
                implicitHeight: 40
                implicitWidth: 110
            }
            footer: Rectangle {
                color: "blue"
                implicitHeight: 25
                implicitWidth: 120
            }
        }
    }

    Component {
        id: nestedLayoutComponent
        ColumnLayout {
            Rectangle {
                color: "red"
                Layout.fillWidth: true
                Layout. minimumHeight: 50
            }
            Kirigami.HeaderFooterLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                header: Rectangle {
                    color: "red"
                    implicitHeight: 30
                    implicitWidth: 100
                }
                contentItem: Rectangle {
                    color: "green"
                    implicitHeight: 40
                    implicitWidth: 110
                }
                footer: Rectangle {
                    color: "blue"
                    implicitHeight: 25
                    implicitWidth: 120
                }
            }
        }
    }

    function test_implicit_sizes_standalone_layout() {
        const layout = createTemporaryObject(implicitSizeComponent, this);
        verify(layout);
        verify(waitForRendering(layout))
        compare(layout.implicitHeight, 95);
        compare(layout.implicitWidth, 120);
        compare(layout.height, 95);
        compare(layout.width, 120);

        compare(layout.header.width, 120);
        compare(layout.header.height, 30);

        compare(layout.footer.width, 120);
        compare(layout.footer.height, 25);

        compare(layout.contentItem.width, 120);
        compare(layout.contentItem.height, 40);

        layout.height = 130;
        wait(50);

        // Header and footer don't change
        compare(layout.header.width, 120);
        compare(layout.header.height, 30);

        compare(layout.footer.width, 120);
        compare(layout.footer.height, 25);

        // ContentItem stretchesvertically
        compare(layout.contentItem.width, 120);
        compare(layout.contentItem.height, 75);

        layout.width = 200;
        wait(50);

        // Everything stretched only horizontally
        compare(layout.header.width, 200);
        compare(layout.header.height, 30);

        compare(layout.footer.width, 200);
        compare(layout.footer.height, 25);

        compare(layout.contentItem.width, 200);
        compare(layout.contentItem.height, 75);

        // change header implicit size
        layout.header.implicitHeight = 40;
        wait(50);

        compare(layout.implicitHeight, 105);
        compare(layout.implicitWidth, 120);
        compare(layout.height, 130);
        compare(layout.width, 200);

        compare(layout.header.width, 200);
        compare(layout.header.height, 40);

        compare(layout.footer.width, 200);
        compare(layout.footer.height, 25);

        compare(layout.contentItem.width, 200);
        compare(layout.contentItem.height, 65);

        // hide header
        layout.header.visible = false;
        wait(50);

        compare(layout.implicitHeight, 65);
        compare(layout.implicitWidth, 120);
        compare(layout.height, 130);
        compare(layout.width, 200);

        compare(layout.header.width, 200);
        compare(layout.header.height, 40);

        compare(layout.footer.width, 200);
        compare(layout.footer.height, 25);

        compare(layout.contentItem.width, 200);
        compare(layout.contentItem.height, 105);
    }

    function test_implicit_sizes_nested_layout() {
        const columnLayout = createTemporaryObject(nestedLayoutComponent, this);
        verify(columnLayout);
        const headerFooterLayout = columnLayout.children[1];
        verify(waitForRendering(columnLayout));
        verify(headerFooterLayout instanceof Kirigami.HeaderFooterLayout);

        compare(columnLayout.implicitHeight, 95 + 50 + columnLayout.spacing);
        compare(columnLayout.implicitHeight, columnLayout.height);

        compare(headerFooterLayout.implicitHeight, 95);
        compare(headerFooterLayout.implicitWidth, 120);
        compare(headerFooterLayout.height, 95);
        compare(headerFooterLayout.width, 120);

        compare(headerFooterLayout.header.width, 120);
        compare(headerFooterLayout.header.height, 30);

        compare(headerFooterLayout.footer.width, 120);
        compare(headerFooterLayout.footer.height, 25);

        compare(headerFooterLayout.contentItem.width, 120);
        compare(headerFooterLayout.contentItem.height, 40);

        columnLayout.height = 200;
        wait(50);

        // headerFooterLayoutshould have stretched
        compare(headerFooterLayout.implicitHeight, 95);
        compare(headerFooterLayout.implicitWidth, 120);
        compare(headerFooterLayout.height, 145);
        compare(headerFooterLayout.width, 120);

        compare(headerFooterLayout.header.width, 120);
        compare(headerFooterLayout.header.height, 30);

        compare(headerFooterLayout.footer.width, 120);
        compare(headerFooterLayout.footer.height, 25);

        compare(headerFooterLayout.contentItem.width, 120);
        compare(headerFooterLayout.contentItem.height, 90);

        // change header implicit size
        headerFooterLayout.header.implicitHeight = 40;
        wait(50);

        compare(headerFooterLayout.implicitHeight, 105);
        compare(headerFooterLayout.implicitWidth, 120);
        compare(headerFooterLayout.height, 145);
        compare(headerFooterLayout.width, 120);

        compare(headerFooterLayout.header.width, 120);
        compare(headerFooterLayout.header.height, 40);

        compare(headerFooterLayout.footer.width, 120);
        compare(headerFooterLayout.footer.height, 25);

        compare(headerFooterLayout.contentItem.width, 120);
        compare(headerFooterLayout.contentItem.height, 80);

        // hide header
        headerFooterLayout.header.visible = false;
        wait(50);

        compare(headerFooterLayout.implicitHeight, 65);
        compare(headerFooterLayout.implicitWidth, 120);
        compare(headerFooterLayout.height, 145);
        compare(headerFooterLayout.width, 120);

        compare(headerFooterLayout.header.width, 120);
        compare(headerFooterLayout.header.height, 40);

        compare(headerFooterLayout.footer.width, 120);
        compare(headerFooterLayout.footer.height, 25);

        compare(headerFooterLayout.contentItem.width, 120);
        compare(headerFooterLayout.contentItem.height, 120);
    }
}
