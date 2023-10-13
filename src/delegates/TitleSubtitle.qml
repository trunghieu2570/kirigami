/*
 * SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 * SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

/**
 * A simple item containing a title and subtitle label.
 *
 * This is mainly intended as a replacement for a list delegate content item,
 * but can be used as a replacement for other content items as well.
 *
 * When using it as a contentItem, make sure to bind the appropriate properties
 * to those of the Control. Prefer binding to the Control's properties over
 * setting the properties directly, as the Control's properties may affect other
 * things like setting accessible names.
 *
 * Example usage as contentItem of an ItemDelegate:
 *
 * ```qml
 * ItemDelegate {
 *     id: delegate
 *
 *     text: "Example"
 *
 *     contentItem: Kirigami.TitleSubtitle {
 *         title: delegate.text
 *         subtitle: "This is an example."
 *         font: delegate.font
 *         selected: delegate.highlighted
 *     }
 * }
 * ```
 *
 * \sa Kirigami::Delegates::IconTitleSubtitle
 * \sa Kirigami::Delegates::ItemDelegate
 */
Item {
    id: root

    /**
     * The title to display.
     */
    required property string title
    /**
     * The subtitle to display.
     */
    property string subtitle
    /**
     * The color to use for the title.
     *
     * By default this is `Kirigami.Theme.textColor` unless `selected` is true
     * in which case this is `Kirigami.Theme.highlightedTextColor`.
     */
    property color color: selected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
    /**
     * The color to use for the subtitle.
     *
     * By default this is `color` mixed with the background color.
     */
    property color subtitleColor: Kirigami.ColorUtils.linearInterpolation(color, Kirigami.Theme.backgroundColor, 0.3)
    /**
     * The font used to display the title.
     */
    property font font: Kirigami.Theme.defaultFont
    /**
     * The font used to display the subtitle.
     */
    property font subtitleFont: Kirigami.Theme.smallFont
    /**
     * The text elision mode used for both the title and subtitle.
     */
    property int elide: Text.ElideRight
    /**
     * Make the implicit height use the subtitle's height even if no subtitle is set.
     */
    property bool reserveSpaceForSubtitle: false
    /**
     * Should this item be displayed in a selected style?
     */
    property bool selected: false
    /**
     * Is the subtitle visible?
     */
    readonly property bool subtitleVisible: subtitleItem.visible || reserveSpaceForSubtitle
    /**
     * Is the title or subtitle truncated?
     */
    readonly property bool truncated: labelItem.truncated || subtitleItem.truncated

    implicitWidth: Math.max(labelItem.implicitWidth, subtitleItem.implicitWidth)
    implicitHeight: labelItem.implicitHeight + (subtitleVisible ? subtitleItem.implicitHeight : 0)

    Text {
        id: labelItem

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        text: root.title
        color: root.color
        font: root.font
        elide: root.elide

        renderType: Text.NativeRendering

        // Note: Can't do this through ordinary bindings as the order between
        // binding evaluation is not defined which leads to incorrect sizing or
        // the QML engine complaining about not being able to anchor to null items.
        states: State {
            when: subtitleItem.visible
            AnchorChanges {
                target: labelItem
                anchors.verticalCenter: undefined
                anchors.bottom: subtitleItem.top
            }
        }
    }

    Text {
        id: subtitleItem

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        text: root.subtitle
        color: root.subtitleColor
        font: root.subtitleFont
        elide: root.elide

        visible: text.length > 0

        renderType: Text.NativeRendering
    }
}
