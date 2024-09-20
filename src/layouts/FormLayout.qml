/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

/*!
 * This is the base class for Form layouts conforming to the
 * Kirigami Human Interface Guidelines. The layout consists
 * of two columns: the left column contains only right-aligned
 * labels provided by a Kirigami.FormData attached property,
 * the right column contains left-aligned child types.
 *
 * Child types can be sectioned using an QtQuick.Item
 * or Kirigami.Separator with a Kirigami.FormData
 * attached property, see FormLayoutAttached::isSection for details.
 *
 * Example usage:
 * \code
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.FormLayout {
 *    QQC2.TextField {
 *       Kirigami.FormData.label: "Label:"
 *    }
 *    Kirigami.Separator {
 *        Kirigami.FormData.label: "Section Title"
 *        Kirigami.FormData.isSection: true
 *    }
 *    QQC2.TextField {
 *       Kirigami.FormData.label: "Label:"
 *    }
 *    QQC2.TextField {
 *    }
 * }
 * \endcode
 * \sa FormLayoutAttached
 * \since Kirigami 2.3
 * @inherit QtQuick.Item
 */
Item {
    id: root

    /*!
     * \brief This property tells whether the form layout is in wide mode.
     *
     * If true, the layout will be optimized for a wide screen, such as
     * a desktop machine (the labels will be on a left column,
     * the fields on a right column beside it), if false (such as on a phone)
     * everything is laid out in a single column.
     *
     * By default this property automatically adjusts the layout
     * if there is enough screen space.
     *
     * Set this to true for a convergent design,
     * set this to false for a mobile-only design.
     */
    property bool wideMode: width >= lay.wideImplicitWidth

    /*!
     * If for some implementation reason multiple FormLayouts have to appear
     * on the same page, they can have each other in twinFormLayouts,
     * so they will vertically align with each other perfectly
     *
     * \since Kirigami 5.53
     */
    property list<Item> twinFormLayouts  // should be list<FormLayout> but we can't have a recursive declaration

    onTwinFormLayoutsChanged: {
        for (const twinFormLayout of twinFormLayouts) {
            if (!(root in twinFormLayout.children[0].reverseTwins)) {
                twinFormLayout.children[0].reverseTwins.push(root)
                Qt.callLater(() => twinFormLayout.children[0].reverseTwinsChanged());
            }
        }
    }

    Component.onCompleted: {
        relayoutTimer.triggered();
    }

    Component.onDestruction: {
        for (const twinFormLayout of twinFormLayouts) {
            const child = twinFormLayout.children[0];
            child.reverseTwins = child.reverseTwins.filter(value => value !== root);
        }
    }

    implicitWidth: lay.wideImplicitWidth
    implicitHeight: lay.implicitHeight
    Layout.preferredHeight: lay.implicitHeight
    Layout.fillWidth: true
    Accessible.role: Accessible.Form

    GridLayout {
        id: lay
        property int wideImplicitWidth
        columns: root.wideMode ? 2 : 1
        rowSpacing: Kirigami.Units.smallSpacing
        columnSpacing: Kirigami.Units.largeSpacing

        //TODO: use state machine
        Binding {
            when: !root.wideMode
            target: lay
            property: "width"
            value: root.width
            restoreMode: Binding.RestoreBinding
        }
        Binding {
            when: root.wideMode
            target: lay
            property: "width"
            value: root.implicitWidth
            restoreMode: Binding.RestoreBinding
        }
        anchors {
            horizontalCenter: root.wideMode ? root.horizontalCenter : undefined
            left: root.wideMode ? undefined : root.left
        }

        property var reverseTwins: []
        property var knownItems: []
        property var buddies: []
        property int knownItemsImplicitWidth: {
            let hint = 0;
            for (const item of knownItems) {
                if (typeof item.Layout === "undefined") {
                    // Items may have been dynamically destroyed. Even
                    // printing such zombie wrappers results in a
                    // meaningless "TypeError: Type error". Normally they
                    // should be cleaned up from the array, but it would
                    // trigger a binding loop if done here.
                    //
                    // This is, so far, the only way to detect them.
                    continue;
                }
                const actualWidth = item.Layout.preferredWidth > 0
                    ? item.Layout.preferredWidth
                    : item.implicitWidth;

                hint = Math.max(hint, item.Layout.minimumWidth, Math.min(actualWidth, item.Layout.maximumWidth));
            }
            return hint;
        }
        property int buddiesImplicitWidth: {
            let hint = 0;

            for (const buddy of buddies) {
                if (buddy.visible && buddy.item !== null && !buddy.item.Kirigami.FormData.isSection) {
                    hint = Math.max(hint, buddy.implicitWidth);
                }
            }
            return hint;
        }
        readonly property var actualTwinFormLayouts: {
            // We need to copy that array by value
            const list = lay.reverseTwins.slice();
            for (const parentLay of root.twinFormLayouts) {
                if (!parentLay || !parentLay.hasOwnProperty("children")) {
                    continue;
                }
                list.push(parentLay);
                for (const childLay of parentLay.children[0].reverseTwins) {
                    if (childLay && !(childLay in list)) {
                        list.push(childLay);
                    }
                }
            }
            return list;
        }

        Timer {
            id: hintCompression
            interval: 0
            onTriggered: {
                if (root.wideMode) {
                    lay.wideImplicitWidth = lay.implicitWidth;
                }
            }
        }
        onImplicitWidthChanged: hintCompression.restart();
        //This invisible row is used to sync alignment between multiple layouts

        Item {
            Layout.preferredWidth: {
                let hint = lay.buddiesImplicitWidth;
                for (const item of lay.actualTwinFormLayouts) {
                    if (item && item.hasOwnProperty("children")) {
                        hint = Math.max(hint, item.children[0].buddiesImplicitWidth);
                    }
                }
                return hint;
            }
            Layout.preferredHeight: 2
        }
        Item {
            Layout.preferredWidth: {
                let hint = Math.min(root.width, lay.knownItemsImplicitWidth);
                for (const item of lay.actualTwinFormLayouts) {
                    if (item.hasOwnProperty("children")) {
                        hint = Math.max(hint, item.children[0].knownItemsImplicitWidth);
                    }
                }
                return hint;
            }
            Layout.preferredHeight: 2
        }
    }

    Item {
        id: temp

        /*!
         * The following two functions are used in the label buddy items.
         *
         * They're in this mostly unused item to keep them private to the FormLayout
         * without creating another QObject.
         *
         * Normally, such complex things in bindings are kinda bad for performance
         * but this is a fairly static property. If for some reason an application
         * decides to obsessively change its alignment, V8's JIT hotspot optimisations
         * will kick in.
         */

        /*!
         * @param {Item} item
         * @returns {Qt::Alignment}
         */
        function effectiveLayout(item: Item): /*Qt.Alignment*/ int {
            if (!item) {
                return 0;
            }
            const verticalAlignment =
                item.Kirigami.FormData.labelAlignment !== 0
                ? item.Kirigami.FormData.labelAlignment
                : Qt.AlignTop;

            if (item.Kirigami.FormData.isSection) {
                return Qt.AlignHCenter;
            }
            if (root.wideMode) {
                return Qt.AlignRight | verticalAlignment;
            }
            return Qt.AlignLeft | Qt.AlignBottom;
        }

        /*!
         * @param {Item} item
         * @returns vertical alignment of the item passed as an argument.
         */
        function effectiveTextLayout(item: Item): /*Qt.Alignment*/ int {
            if (!item) {
                return 0;
            }
            if (root.wideMode && !item.Kirigami.FormData.isSection) {
                return item.Kirigami.FormData.labelAlignment !== 0 ? item.Kirigami.FormData.labelAlignment : Text.AlignVCenter;
            }
            return Text.AlignBottom;
        }
    }

    Timer {
        id: relayoutTimer
        interval: 0
        onTriggered: {
            const __items = root.children;
            // exclude the layout and temp
            for (let i = 2; i < __items.length; ++i) {
                const item = __items[i];

                // skip items that are already there
                if (lay.knownItems.indexOf(item) !== -1 || item instanceof Repeater) {
                    continue;
                }
                lay.knownItems.push(item);

                const itemContainer = itemComponent.createObject(temp, { item });

                // if it's a labeled section header, add extra spacing before it
                if (item.Kirigami.FormData.label.length > 0 && item.Kirigami.FormData.isSection) {
                    placeHolderComponent.createObject(lay, { item });
                }

                const buddy = buddyComponent.createObject(lay, { item, index: i - 2 });

                itemContainer.parent = lay;
                lay.buddies.push(buddy);
            }
            lay.knownItemsChanged();
            lay.buddiesChanged();
            hintCompression.triggered();
        }
    }

    onChildrenChanged: relayoutTimer.restart();

    Component {
        id: itemComponent
        Item {
            id: container

            property Item item

            enabled: item?.enabled ?? false
            visible: item?.visible ?? false

            // NOTE: work around a  GridLayout quirk which doesn't lay out items with null size hints causing things to be laid out incorrectly in some cases
            implicitWidth: item !== null ? Math.max(item.implicitWidth, 1) : 0
            implicitHeight: item !== null ? Math.max(item.implicitHeight, 1) : 0
            Layout.preferredWidth: item !== null ? Math.max(1, item.Layout.preferredWidth > 0 ? item.Layout.preferredWidth : Math.ceil(item.implicitWidth)) : 0
            Layout.preferredHeight: item !== null ? Math.max(1, item.Layout.preferredHeight > 0 ? item.Layout.preferredHeight : Math.ceil(item.implicitHeight)) : 0

            Layout.minimumWidth: item?.Layout.minimumWidth ?? 0
            Layout.minimumHeight: item?.Layout.minimumHeight ?? 0

            Layout.maximumWidth: item?.Layout.maximumWidth ?? 0
            Layout.maximumHeight: item?.Layout.maximumHeight ?? 0

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: item !== null && (item instanceof TextInput || item.Layout.fillWidth || item.Kirigami.FormData.isSection)
            Layout.columnSpan: item?.Kirigami.FormData.isSection ? lay.columns : 1
            onItemChanged: {
                if (!item) {
                    container.destroy();
                }
            }
            onXChanged: if (item !== null) { item.x = x + lay.x; }
            // Assume lay.y is always 0
            onYChanged: if (item !== null) { item.y = y + lay.y; }
            onWidthChanged: if (item !== null) { item.width = width; }
            Component.onCompleted: item.x = x + lay.x;
            Connections {
                target: lay
                function onXChanged(): void {
                    if (container.item !== null) {
                        container.item.x = container.x + lay.x;
                    }
                }
            }
        }
    }
    Component {
        id: placeHolderComponent
        Item {
            property Item item

            enabled: item?.enabled ?? false
            visible: item?.visible ?? false

            width: Kirigami.Units.smallSpacing
            height: Kirigami.Units.smallSpacing
            Layout.topMargin: item?.height > 0 ? Kirigami.Units.smallSpacing : 0
            onItemChanged: {
                if (!item) {
                    destroy();
                }
            }
        }
    }
    Component {
        id: buddyComponent
        Kirigami.Heading {
            id: labelItem

            property Item item
            property int index

            enabled: item?.enabled ?? false
            visible: (item?.visible && (root.wideMode || text.length > 0)) ?? false
            Kirigami.MnemonicData.enabled: item?.Kirigami.FormData.buddyFor?.activeFocusOnTab ?? false
            Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.FormLabel
            Kirigami.MnemonicData.label: item?.Kirigami.FormData.label ?? ""
            text: Kirigami.MnemonicData.richTextLabel
            type: item?.Kirigami.FormData.isSection ? Kirigami.Heading.Type.Primary : Kirigami.Heading.Type.Normal

            level: item?.Kirigami.FormData.isSection ? 3 : 5

            Layout.columnSpan: item?.Kirigami.FormData.isSection ? lay.columns : 1
            Layout.preferredHeight: {
                if (!item) {
                    return 0;
                }
                if (item.Kirigami.FormData.label.length > 0) {
                    // Add extra whitespace before textual section headers, which
                    // looks better than separator lines
                    if (item.Kirigami.FormData.isSection && labelItem.index !== 0) {
                        return implicitHeight + Kirigami.Units.largeSpacing * 2;
                    }
                    else if (root.wideMode && !(item.Kirigami.FormData.buddyFor instanceof TextEdit)) {
                        return Math.max(implicitHeight, item.Kirigami.FormData.buddyFor.height)
                    }
                    return implicitHeight;
                }
                return Kirigami.Units.smallSpacing;
            }

            Layout.alignment: temp.effectiveLayout(item)
            verticalAlignment: temp.effectiveTextLayout(item)

            Layout.fillWidth: !root.wideMode
            wrapMode: Text.Wrap

            Layout.topMargin: {
                if (!item) {
                    return 0;
                }
                if (root.wideMode && item.Kirigami.FormData.buddyFor.parent !== root) {
                    return item.Kirigami.FormData.buddyFor.y;
                }
                if (index === 0 || root.wideMode) {
                    return 0;
                }
                return Kirigami.Units.largeSpacing * 2;
            }
            onItemChanged: {
                if (!item) {
                    destroy();
                }
            }
            Shortcut {
                sequence: labelItem.Kirigami.MnemonicData.sequence
                onActivated: labelItem.item.Kirigami.FormData.buddyFor.forceActiveFocus()
            }
        }
    }
}
