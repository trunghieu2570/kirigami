/*
 *  SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.kirigami.private as KirigamiPrivate
import QtTest

TestCase {
    id: root

    property url urlFromString: "http://example.com"
    property url urlFromResolved: Qt.resolvedUrl("http://example.com")
    property url urlFromJavaScript: new URL("http://example.com")

    name: "TypesHelperTest"

    function test_isUrl(): void {
        verify(KirigamiPrivate.TypesHelper.isUrl(urlFromString));
        verify(KirigamiPrivate.TypesHelper.isUrl(urlFromResolved));
        verify(KirigamiPrivate.TypesHelper.isUrl(urlFromJavaScript));
        verify(!KirigamiPrivate.TypesHelper.isUrl("http://example.com"));
    }
}
