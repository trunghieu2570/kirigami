import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.21 as Kirigami
import QtTest 1.0

TestCase {
    name: "SizeGroupTests"
    when: windowShown

    Kirigami.SizeGroup {
        id: wGroup
        mode: Kirigami.SizeGroup.Width
    }

    Kirigami.SizeGroup {
        id: hGroup
        mode: Kirigami.SizeGroup.Height
    }

    function test_a_init() {
        wGroup.items = [];
        compare(wGroup.maxWidth, 0);
        compare(wGroup.maxHeight, 0);
    }

    function test_b_cleanup() {
        wGroup.items = [];
        item1.Layout.preferredWidth = -1;
        compare(item1.Layout.preferredWidth, -1);

        wGroup.items.push(item1);
        compare(wGroup.maxWidth, 42);
        compare(item1.implicitWidth, 42);
        compare(item1.Layout.preferredWidth, 42);

        wGroup.items = [];
        compare(wGroup.items.length, 0);
        compare(item1.Layout.preferredWidth, -1);
        compare(wGroup.maxWidth, 0);
        compare(wGroup.maxHeight, 0);
    }

    function test_c_wide() {
        wGroup.items = [];
        wGroup.items.push(item1);
        compare(wGroup.maxWidth, 42);
        compare(wGroup.maxHeight, 0);
        compare(item1.Layout.preferredWidth, 42);
        compare(item1.Layout.preferredHeight, -1);
        wGroup.items.push(item2);
        compare(wGroup.maxWidth, 123);
        compare(wGroup.maxHeight, 0);
        compare(item1.Layout.preferredWidth, 123);
        compare(item2.Layout.preferredWidth, 123);
    }

    function test_d_tall() {
        hGroup.items = [];
        hGroup.items.push(item1);
        compare(hGroup.maxWidth, 0);
        compare(hGroup.maxHeight, 37);
        compare(item1.Layout.preferredHeight, 37);
        hGroup.items.push(item2);
        compare(hGroup.maxHeight, 37);
        compare(item1.Layout.preferredHeight, 37);
        compare(item2.Layout.preferredHeight, 37);
    }

    function test_e_animated() {
        const children = column.children;
        wGroup.items = [];
        wGroup.items = children;
        compare(wGroup.maxWidth, 50);
        compare(column.children[0].width, 50);
        column.children[1].implicitWidth = 100;
        wait(100);
        fuzzyCompare(column.children[0].width, 75, 5);
    }

    Item {
        id: item1
        implicitWidth: 42
        implicitHeight: 37
    }

    Item {
        id: item2
        implicitWidth: 123
        implicitHeight: 10
    }

    ColumnLayout {
        id: column
        Rectangle {
            color: "red"
            implicitWidth: 50
            implicitHeight: 50
            Behavior on Layout.preferredWidth {
                // Do not animate to/from uninitialized state
                enabled: targetProperty.object[targetProperty.name] !== -1 && targetValue !== -1
                NumberAnimation { duration: 200; easing.type: Easing.Linear }
            }
        }
        Rectangle {
            color: "green"
            implicitWidth: 50
            implicitHeight: 50
        }
        Rectangle {
            color: "blue"
            implicitWidth: 50
            implicitHeight: 50
        }
    }
}
