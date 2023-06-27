/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

QQC2.Menu {
    id: root

    property alias actions: actionsInstantiator.model

    property Component submenuComponent
    property Component itemDelegate: ActionMenuItem {}
    property Component separatorDelegate: QQC2.MenuSeparator { property var action }
    property Component loaderDelegate: Loader { property var action }
    property QQC2.Action parentAction
    property QQC2.MenuItem parentItem

    z: 999999999

    Instantiator {
        id: actionsInstantiator

        active: root.visible
        delegate: QtObject {
            readonly property QQC2.Action action: modelData

            property QtObject item: null
            property bool isSubMenu: false

            Component.onCompleted: {
                if (!action.hasOwnProperty("children") && !action.children || action.children.length === 0) {
                    if (action.hasOwnProperty("separator") && action.separator) {
                        item = root.separatorDelegate.createObject(null, { action });
                    } else if (action.displayComponent) {
                        item = root.loaderDelegate.createObject(null, {
                            action,
                            sourceComponent: action.displayComponent,
                        });
                    } else {
                        item = root.itemDelegate.createObject(null, { action });
                    }
                    root.addItem(item)
                } else if (root.submenuComponent) {
                    item = root.submenuComponent.createObject(null, {
                        parentAction: action,
                        title: action.text,
                        actions: action.children,
                    });

                    root.insertMenu(root.count, item);
                    item.parentItem = root.contentData[root.contentData.length - 1];
                    item.parentItem.icon = action.icon;
                    isSubMenu = true;
                }
            }

            Component.onDestruction: {
                if (isSubMenu) {
                    root.removeMenu(item);
                } else {
                    root.removeItem(item);
                }
                item.destroy();
            }
        }
    }
}
