/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami 2 as Kirigami
import QtTest

TestCase {
    name: "ColumnView"
    visible: true
    when: windowShown

    width: 500
    height: 500

    Component {
        id: columnViewComponent
        Kirigami.ColumnView {}
    }

    Component {
        id: emptyItemPageComponent
        Item {}
    }

    function createViewWith3Items() {
        const view = createTemporaryObject(columnViewComponent, this);
        verify(view);

        const zero = createTemporaryObject(emptyItemPageComponent, this, { objectName: "zero" });
        view.addItem(zero);

        const one = createTemporaryObject(emptyItemPageComponent, this, { objectName: "one" });
        view.addItem(one);

        const two = createTemporaryObject(emptyItemPageComponent, this, { objectName: "two" });
        view.addItem(two);

        compare(view.count, 3);

        return ({
            view,
            zero,
            one,
            two,
        });
    }

    function test_clear() {
        const { view } = createViewWith3Items();
        view.clear();
        compare(view.count, 0);
    }

    function test_contains() {
        const { view, zero, one, two } = createViewWith3Items();

        verify(view.containsItem(zero));
        verify(view.containsItem(one));
        verify(view.containsItem(two));

        view.removeItem(zero);
        verify(!view.containsItem(zero));

        view.addItem(zero);
        verify(view.containsItem(zero));

        verify(!view.containsItem(null));
    }

    function test_remove_by_index_leading() {
        const { view, zero: target } = createViewWith3Items();
        const item = view.removeItem(0);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_index_trailing() {
        const { view, two: target } = createViewWith3Items();
        compare(view.count - 1, 2);
        const item = view.removeItem(2);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_index_middle() {
        const { view, one: target } = createViewWith3Items();
        const item = view.removeItem(1);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_index_last() {
        const { view, zero, one, two } = createViewWith3Items();
        let item;

        item = view.removeItem(0);
        compare(item, zero);
        compare(view.count, 2);

        item = view.removeItem(1);
        compare(item, two);
        compare(view.count, 1);

        item = view.removeItem(0);
        compare(item, one);
        compare(view.count, 0);
    }

    function test_remove_by_index_negative() {
        const { view } = createViewWith3Items();
        const item = view.removeItem(-1);
        compare(item, null);
        compare(view.count, 3);
    }

    function test_remove_by_index_out_of_bounds() {
        const { view } = createViewWith3Items();
        const item = view.removeItem(view.count);
        compare(item, null);
        compare(view.count, 3);
    }

    function test_remove_by_item_leading() {
        const { view, zero: target } = createViewWith3Items();
        const item = view.removeItem(target);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_item_trailing() {
        const { view, two: target } = createViewWith3Items();
        const item = view.removeItem(target);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_item_middle() {
        const { view, one: target } = createViewWith3Items();
        const item = view.removeItem(target);
        compare(item, target);
        compare(view.count, 2);
    }

    function test_remove_by_item_last() {
        const { view, zero, one, two } = createViewWith3Items();
        let item;

        item = view.removeItem(zero);
        compare(item, zero);
        compare(view.count, 2);

        item = view.removeItem(one);
        compare(item, one);
        compare(view.count, 1);

        item = view.removeItem(two);
        compare(item, two);
        compare(view.count, 0);
    }

    function test_remove_by_item_null() {
        const { view } = createViewWith3Items();
        const item = view.removeItem(null);
        compare(item, null);
        compare(view.count, 3);
    }

    function test_remove_by_item_from_empty() {
        const view = createTemporaryObject(columnViewComponent, this);
        verify(view);
        let item;

        item = view.removeItem(null);
        compare(item, null);

        item = view.removeItem(this);
        compare(item, null);
    }

    function test_pop_no_args() {
        skip("Behavior of ColumnView::pop() is not well-defined yet.");

        const { view, zero, one, two } = createViewWith3Items();

        let last = null;

        last = view.pop();
        verify(last, two);

        last = view.pop();
        verify(last, one);

        last = view.pop();
        verify(last, zero);

        last = view.pop();
        verify(last, null);
    }

    function test_move() {
        const { view, zero, one, two } = createViewWith3Items();

        compare(view.contentChildren.length, 3);
        compare(view.contentChildren[0], zero);
        compare(view.contentChildren[2], two);

        view.moveItem(0, 2);

        compare(view.contentChildren[0], one);
        compare(view.contentChildren[1], two);
        compare(view.contentChildren[2], zero);

        // TODO: test currentIndex adjustments
    }

    function test_insert_null() {
        const { view } = createViewWith3Items();
        view.insertItem(0, null);
        compare(view.count, 3);
    }

    function test_insert_duplicate() {
        const { view, one: target } = createViewWith3Items();
        view.insertItem(0, target);
        compare(view.count, 3);
    }

    function test_insert_leading() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.insertItem(0, item);
        compare(view.count, 4)
        compare(view.contentChildren, [item, zero, one, two]);
    }

    function test_insert_trailing() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.insertItem(view.count, item);
        compare(view.count, 4)
        compare(view.contentChildren, [zero, one, two, item]);
    }

    function test_insert_middle() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.insertItem(2, item);
        compare(view.count, 4)
        compare(view.contentChildren, [zero, one, item, two]);
    }

    function test_replace_middle() {
        const { view, zero, one, two } = createViewWith3Items();
        const item = createTemporaryObject(emptyItemPageComponent, this, { objectName: "item" });
        view.replaceItem(1, item);
        compare(view.count, 3)
        compare(view.contentChildren, [zero, item, two]);
    }
}
