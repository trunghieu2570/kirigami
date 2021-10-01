/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.18 as Kirigami
import "private" as Private
import "../templates/private" as TPrivate

SystemDialog {
    id: root
    
    default property Item mainItem
    
    /**
     * Title of the dialog.
     */
    property string title: ""
    
    /**
     * Subtitle of the dialog.
     */
    property string subtitle: ""
    
    property string iconName: ""
    
    /**
     * This property holds the default padding of the content.
     */
    property real padding: Kirigami.Units.smallSpacing
    
    /**
     * This property holds the left padding of the content. If not specified, it uses `padding`.
     */
    property real leftPadding: padding
    
    /**
     * This property holds the right padding of the content. If not specified, it uses `padding`.
     */
    property real rightPadding: padding
    
    /**
     * This property holds the top padding of the content. If not specified, it uses `padding`.
     */
    property real topPadding: padding
    
    /**
     * This property holds the bottom padding of the content. If not specified, it uses `padding`.
     */
    property real bottomPadding: padding
    
    /**
     * This property holds the list of actions for this dialog.
     *
     * Each action will be rendered as a button that the user will be able
     * to click.
     */
    property list<Kirigami.Action> actions
    
    bodyItem: ColumnLayout {
        id: column
        spacing: 0
        
        RowLayout {
            Layout.margins: Kirigami.Units.gridUnit
            spacing: Kirigami.Units.gridUnit
            
            Kirigami.Icon {
                source: root.iconName
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
            }
            
            ColumnLayout {
                spacing: Kirigami.Units.largeSpacing
                Kirigami.Heading {
                    Layout.fillWidth: true
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    level: 2
                    text: root.title
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                }
                Label {
                    Layout.fillWidth: true
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.alignment: Qt.AlignVCenter
                    text: root.subtitle
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                }
                Control {
                    leftPadding: 0
                    rightPadding: 0
                    bottomPadding: 0
                    topPadding: 0
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    contentItem: root.mainItem
                }
            }
        }
        
        RowLayout {
            Layout.margins: Kirigami.Units.largeSpacing
            
            spacing: Kirigami.Units.smallSpacing
            Item { Layout.fillWidth: true }
            Repeater {
                model: root.actions
                
                delegate: Button {
                    text: modelData.text
                    icon: modelData.icon
                    onClicked: modelData.trigger()
                }
            }
        }
    }
}

