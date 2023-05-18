/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import QtTest 1.15

TestCase {
    id: root

    name: "ScenePositionTest"
    visible: true
    when: windowShown

    width: 300
    height: 300

    Item {
        id: anchorsFillItem
        anchors.fill: parent

        Item {
            id: itemA
            x: 50
            y: 100
        }

        Item {
            id: itemB
            x: 150
            y: 200

            Item {
                id: itemB1
                x: 25
                y: 50
            }
        }

        Item {
            id: itemF
            x: 3.5
            y: 6.25

            Item {
                id: itemF1
                x: -0.25
                y: 1.125
            }
        }

        Item {
            id: itemPlaceholder
            x: 56
            y: 78

            property Item __reparentedItem: Item {
                id: reparentedItem
                parent: null
                x: 12
                y: 34
            }
        }

        Rectangle {
            id: itemTransform

            x: 100
            y: 200
            width: 10
            height: 10
            color: "red"

            scale: 2.0
            rotation: 30
            transform: [
                Rotation {
                    angle: 30
                },
                Scale {
                    xScale: 2.0
                    yScale: 3.0
                },
                Translate {
                    x: 12
                    y: 34
                },
                Matrix4x4 {
                    property real a: Math.PI / 4
                    matrix: Qt.matrix4x4(Math.cos(a), -Math.sin(a), 0, 0,
                                         Math.sin(a),  Math.cos(a), 0, 0,
                                         0,           0,            1, 0,
                                         0,           0,            0, 1)
                }
            ]
        }
    }

    function test_root() {
        compare(root.Kirigami.ScenePosition.x, 0);
        compare(root.Kirigami.ScenePosition.y, 0);

        compare(anchorsFillItem.Kirigami.ScenePosition.x, 0);
        compare(anchorsFillItem.Kirigami.ScenePosition.y, 0);
    }

    function test_not_nested() {
        compare(itemA.Kirigami.ScenePosition.x, itemA.x);
        compare(itemA.Kirigami.ScenePosition.y, itemA.y);

        compare(itemB.Kirigami.ScenePosition.x, itemB.x);
        compare(itemB.Kirigami.ScenePosition.y, itemB.y);
    }

    function test_nested() {
        compare(itemB1.Kirigami.ScenePosition.x, itemB.x + itemB1.x);
        compare(itemB1.Kirigami.ScenePosition.y, itemB.y + itemB1.y);
    }

    function test_floating() {
        compare(itemF1.Kirigami.ScenePosition.x, 3.25);
        compare(itemF1.Kirigami.ScenePosition.y, 7.375);
    }

    function test_reparented() {
        reparentedItem.parent = null;
        compare(reparentedItem.Kirigami.ScenePosition.x, reparentedItem.x);
        compare(reparentedItem.Kirigami.ScenePosition.y, reparentedItem.y);

        itemPlaceholder.x = 56;
        itemPlaceholder.y = 78;
        reparentedItem.parent = itemPlaceholder;
        compare(reparentedItem.Kirigami.ScenePosition.x, itemPlaceholder.x + reparentedItem.x);
        compare(reparentedItem.Kirigami.ScenePosition.y, itemPlaceholder.y + reparentedItem.y);

        itemPlaceholder.x += 10;
        itemPlaceholder.y += 20;
        compare(reparentedItem.Kirigami.ScenePosition.x, itemPlaceholder.x + reparentedItem.x);
        compare(reparentedItem.Kirigami.ScenePosition.y, itemPlaceholder.y + reparentedItem.y);
    }

    function test_transform() {
        // transformations are not supported by ScenePosition
        compare(itemTransform.Kirigami.ScenePosition.x, itemTransform.x);
        compare(itemTransform.Kirigami.ScenePosition.y, itemTransform.y);
    }
}
