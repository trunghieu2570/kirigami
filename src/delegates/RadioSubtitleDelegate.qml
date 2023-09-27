/*
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2

/**
 * A convenience wrapper combining QtQuick Controls RadioDelegate and IconTitleSubtitle
 *
 * This is an intentionally minimal wrapper that replaces the RadioDelegate's
 * contentItem with an IconTitleSubtitle and adds a subtitle property.
 *
 * If you wish to customize the layout further, create your own `RadioDelegate`
 * subclass with the `contentItem:` property set to the content of your choice.
 * This can include `IconTitleSubtitle` inside a Layout, for example.
 *
 * \note If you don't need a subtitle, use `RadioDelegate` directly.
 *
 * \sa Kirigami::Delegates::TitleSubtitle
 * \sa Kirigami::Delegates::IconTitleSubtitle
 */
QQC2.RadioDelegate {
    id: delegate

    // Please see the developer note in ItemDelegate

    /**
     * The subtitle to display.
     */
    property string subtitle

    contentItem: IconTitleSubtitle {
        icon: icon.fromControlsIcon(delegate.icon)
        title: delegate.text
        subtitle: delegate.subtitle
        selected: delegate.highlighted
        font: delegate.font
    }
}