/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    name: "ActionExtTest"

    Component {
        id: tActionComponent
        T.Action {}
    }

    Component {
        id: kActionComponent
        Kirigami.Action {}
    }

    function test_attach() {
        const action = createTemporaryObject(tActionComponent, this);
        verify(action);
        action.Kirigami.ActionExt.visible = false;
        verify(!action.Kirigami.ActionExt.visible);
    }

    function test_sync() {
        const action = createTemporaryObject(kActionComponent, this);
        verify(action);
        // defaults
        verify(action.visible);
        verify(action.Kirigami.ActionExt.visible);
        // change and check sync
        action.visible = false;
        verify(!action.visible);
        verify(!action.Kirigami.ActionExt.visible);
        action.Kirigami.ActionExt.visible = true;
        verify(action.visible);
        verify(action.Kirigami.ActionExt.visible);
    }
}
