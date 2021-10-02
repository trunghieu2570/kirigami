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
import "private"

/**
 * Component to create fullscreen dialogs that come from the system.
 */
Item {
    id: root
    
    /**
     * This property holds the dialog's contents.
     * 
     * The initial height and width of the dialog is calculated from the 
     * `implicitWidth` and `implicitHeight` of this item.
     */
    default property Item contentItem
    
    /**
     * This property holds the absolute maximum height the dialog can be
     * (including the header and footer).
     * 
     * The height restriction is solely applied on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     * 
     * This is the window height, subtracted by largeSpacing on both the top 
     * and bottom.
     */
    readonly property real absoluteMaximumHeight: Screen.height - Kirigami.Units.gridUnit * 2
    
    /**
     * This property holds the absolute maximum width the dialog can be.
     * 
     * By default, it is the window width, subtracted by largeSpacing on both 
     * the top and bottom.
     */
    readonly property real absoluteMaximumWidth: Screen.width - Kirigami.Units.gridUnit * 2
    
    /**
     * This property holds the maximum height the dialog can be (including
     * the header and footer).
     * 
     * The height restriction is solely enforced on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     * 
     * By default, this is `absoluteMaximumHeight`.
     */
    property real maximumHeight: absoluteMaximumHeight
    
    /**
     * This property holds the maximum width the dialog can be.
     * 
     * By default, this is `absoluteMaximumWidth`.
     */
    property real maximumWidth: absoluteMaximumWidth
    
    /**
     * This property holds the preferred height of the dialog.
     * 
     * The content will receive a hint for how tall it should be to have
     * the dialog to be this height.
     * 
     * If the content, header or footer require more space, then the height
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredHeight: -1
    
    /**
     * This property holds the preferred width of the dialog.
     * 
     * The content will receive a hint for how wide it should be to have
     * the dialog be this wide.
     * 
     * If the content, header or footer require more space, then the width
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredWidth: -1

    /**
     * This property holds whether the background should be darkened when the dialog opens.
     * 
     * Background refers to the window itself if the dialog is opened with `open()`, and 
     * the whole screen when opened with `openFullScreen()`.
     * 
     * By default, it's false when the dialog is of desktop types, and true when it's mobile.
     */
    property bool darkenBackground: root.type === 0 ? false : true
    
    /**
     * This property holds whether the close button is shown. Only applicable for desktop.
     */
    property bool showCloseButton: false
    
    /**
     * Title of the dialog.
     */
    property string title: ""
    
    /**
     * Subtitle of the dialog.
     */
    property string subtitle: ""
    
    /**
     * This property holds the icon used in the dialog. Only applicable for desktop.
     */
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
    
    enum Type {
        Desktop,
        MobileRow,
        MobileColumn
    }
    
    /**
     * This property holds the type of dialog style. You may either choose from Desktop, MobileRow and MobileColumn styles.
     */
    property int type: 0
    
    visible: loader.item.visible
    
    function open() {
        loader.item.show();
    }
    
    function openFullScreen() {
        loader.item.showFullScreen();
    }
    
    function close() {
        loader.item.close();
    }
    
    Loader {
        id: loader
        
        property var window: Window.window
        
        Component {
            id: desktop
            DesktopSystemDialog {
                mainItem: root.contentItem
                
                maximumHeight: root.maximumHeight
                maximumWidth: root.maximumWidth
                preferredHeight: root.preferredHeight
                preferredWidth: root.preferredWidth
                
                darkenBackground: root.darkenBackground
                showCloseButton: root.showCloseButton
                
                title: root.title
                subtitle: root.subtitle
                iconName: root.iconName
                
                padding: root.padding
                leftPadding: root.leftPadding
                rightPadding: root.rightPadding
                topPadding: root.topPadding
                bottomPadding: root.bottomPadding
                
                actions: root.actions
            }
        }
        
        Component {
            id: mobile
            MobileSystemDialog {
                mainItem: root.contentItem
                
                maximumHeight: root.maximumHeight
                maximumWidth: root.maximumWidth
                preferredHeight: root.preferredHeight
                preferredWidth: root.preferredWidth
                
                darkenBackground: root.darkenBackground
                
                title: root.title
                subtitle: root.subtitle
                
                padding: root.padding
                leftPadding: root.leftPadding
                rightPadding: root.rightPadding
                topPadding: root.topPadding
                bottomPadding: root.bottomPadding
                
                actions: root.actions
                layout: root.type === 1 ? MobileSystemDialog.Row : MobileSystemDialog.Column
            }
        }
        
        sourceComponent: root.type === 0 ? desktop : mobile
    }
}

