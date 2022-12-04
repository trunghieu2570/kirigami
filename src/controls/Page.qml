/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T2
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "private" as P

/**
 * Page is a container for all the app pages: everything pushed to the
 * ApplicationWindow's pageStack should be a Page.
 *
 * @see ScrollablePage
 * For content that should be scrollable, such as ListViews, use ScrollablePage instead.
 * @inherit QtQuick.Controls.Page
 */
QQC2.Page {
    id: root

//BEGIN properties
    padding: Kirigami.Units.gridUnit

    /**
     * @brief If the central element of the page is a Flickable
     * (ListView and Gridview as well) you can set it there.
     *
     * Normally, you wouldn't need to do that, but just use the
     * ScrollablePage element instead.
     *
     * Use this if your flickable has some non standard properties, such as not covering the whole Page.
     *
     * @see ScrollablePage
     */
    property Flickable flickable

    /**
     * @brief This property holds the actions for the page.
     *
     * These actions will be displayed in the toolbar on the desktop and inside
     * the ContextDrawer on mobile.
     *
     * @code
     * import org.kde.kirigami 2 as Kirigami
     *
     * Kirigami.Page {
     *     actions: [
     *         Kirigami.Action {...},
     *         Kirigami.Action {...}
     *     }
     * }
     * @endcode
     */
    property list<Kirigami.Action> actions

    /**
     * @brief This property tells us if it is the currently active page.
     *
     * Specifies if it's the currently selected page in the window's pages row, or if layers
     * are used whether this is the topmost item on the layers stack. If the page is
     * not attached to either a column view or a stack view, expect this to be true.
     *
     * @since 2.1
     */
    //TODO KF6: remove this or at least all the assumptions about the internal tree structure of items
    readonly property bool isCurrentPage: Kirigami.ColumnView.view
            ? (Kirigami.ColumnView.index === Kirigami.ColumnView.view.currentIndex && Kirigami.ColumnView.view.parent.parent.currentItem === Kirigami.ColumnView.view.parent)
            : (parent && parent instanceof QQC2.StackView
                ? parent.currentItem === root
                : true)

    /**
     * An item which stays on top of every other item in the page,
     * if you want to make sure some elements are completely in a
     * layer on top of the whole content, parent items to this one.
     * It's a "local" version of ApplicationWindow's overlay
     *
     * @property Item overlay
     * @since 2.5
     */
    readonly property alias overlay: overlayItem

    /**
     * @brief This holds the icon that represents this page.
     * @property var icon
     */
    property P.ActionIconGroup icon: P.ActionIconGroup {}

    /**
     * @brief Progress of a task this page is doing.
     *
     * Set to undefined to indicate that there are no ongoing tasks.
     *
     * default: ``undefined``
     *
     * @property real progress
     */
    property var progress: undefined

    /**
     * @brief The delegate which will be used to draw the page title.
     *
     * It can be customized to put any kind of Item in there.
     *
     * @since 2.7
     */
    property Component titleDelegate: Component {
        id: defaultTitleDelegate
        P.DefaultPageTitleDelegate {
            text: root.title
        }
    }

    /**
     * The item used as global toolbar for the page
     * present only if we are in a PageRow as a page or as a layer,
     * and the style is either Titles or ToolBar.
     *
     * @since 2.5
     */
    readonly property Item globalToolBarItem: globalToolBar.item

    /**
     * The style for the automatically generated global toolbar: by default the Page toolbar is the one set globally in the PageRow in its globalToolBar.style property.
     * A single page can override the application toolbar style for itself.
     * It is discouraged to use this, except very specific exceptions, like a chat
     * application which can't have controls on the bottom except the text field.
     * If the Page is not in a PageRow, by default the toolbar will be invisible,
     * so has to be explicitly set to Kirigami.ApplicationHeaderStyle.ToolBar if
     * desired to be used in that case.
     */
    property int globalToolBarStyle: {
        if (globalToolBar.row && !globalToolBar.stack) {
            return globalToolBar.row.globalToolBar.actualStyle;
        } else if (globalToolBar.stack) {
            return Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.ToolBar;
        } else {
            return Kirigami.ApplicationHeaderStyle.None;
        }
    }
    
    /**
     * Whether to perform an animation when the page is shown, useful during lateral navigation.
     * This will set the transform property on the page's contents in order to perform a translation on `y`.
     * 
     * By default, this is set to false.
     * 
     * @since 2.20
     */
    property bool animateWhenShown: false
    
    /**
     * Whether to perform an animation on the header when the page is shown, useful during lateral navigation.
     * This will set the transform property on the page header in order to perform a translation on `y`.
     * 
     * By default, this is the value of `animateWhenShown`.
     * 
     * @since 2.20
     */
    property bool animateHeaderWhenShown: animateWhenShown
    
    /**
     * Whether to perform an animation on the footer when the page is shown, useful during lateral navigation.
     * This will set the transform property on the page footer in order to perform a translation on `y`.
     * 
     * By default, this is the value of `animateWhenShown`.
     * 
     * @since 2.20
     */
    property bool animateFooterWhenShown: animateWhenShown
    
//END properties

//BEGIN signal and signal handlers
    /**
     * @brief Emitted when the application requests a Back action.
     *
     * For instance a global "back" shortcut or the Android
     * Back button has been pressed.
     * The page can manage the back event by itself,
     * and if it set event.accepted = true, it will stop the main
     * application to manage the back event.
     */
    signal backRequested(var event);

    // NOTE: contentItem will be created if not existing (and contentChildren of Page would become its children) This with anchors enforces the geometry we want, where globalToolBar is a super-header, on top of header
    contentItem: Item {
        anchors {
            top: (root.header && root.header.visible)
                    ? root.header.bottom
                    : (globalToolBar.visible ? globalToolBar.bottom : parent.top)
            topMargin: root.topPadding + root.spacing
            bottom: (root.footer && root.footer.visible) ? root.footer.top : parent.bottom
            bottomMargin: root.bottomPadding + root.spacing
        }
    }

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }

    implicitHeight: ((header && header.visible) ? header.implicitHeight : 0) + ((footer && footer.visible) ? footer.implicitHeight : 0) + contentItem.implicitHeight + topPadding + bottomPadding
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding

    // FIXME: on material the shadow would bleed over
    clip: root.header !== null;

    onHeaderChanged: {
        if (header) {
            header.anchors.top = Qt.binding(() => globalToolBar.visible ? globalToolBar.bottom : root.top);
        }
    }

    Component.onCompleted: {
        headerChanged();
        parentChanged(root.parent);
        globalToolBar.syncSource();
        bottomToolBar.pageComplete = true

        // run page shown animation if needed
        pageAnimController.runShownAnimation();
    }

    onParentChanged: {
        if (!parent) {
            return;
        }
        globalToolBar.stack = null;
        globalToolBar.row = null;

        if (root.Kirigami.ColumnView.view) {
            globalToolBar.row = root.Kirigami.ColumnView.view.__pageRow;
        }
        if (root.T2.StackView.view) {
            globalToolBar.stack = root.T2.StackView.view;
            globalToolBar.row = root.T2.StackView.view ? root.T2.StackView.view.parent : null;
        }
        if (globalToolBar.row) {
            root.globalToolBarStyleChanged.connect(globalToolBar.syncSource);
            globalToolBar.syncSource();
        }
    }

    onVisibleChanged: {
        if (!root.visible) { 
            pageAnimController.runShownAnimation(); 
        }
    }
//END signals and signal handlers

    // in data in order for them to not be considered for contentItem, contentChildren, contentData
    data: [
        Item {
            id: overlayItem
            parent: root
            z: 9997
            anchors {
                fill: parent
                topMargin: globalToolBar.height
            }
        },
        // global top toolbar if we are in a PageRow (in the row or as a layer)
        Loader {
            id: globalToolBar
            z: 9999
            height: item ? item.implicitHeight : 0
            anchors {
                left:  parent.left
                right: parent.right
                top: parent.top
            }
            property Kirigami.PageRow row
            property T2.StackView stack

            // don't load async so that on slower devices we don't have the page content height changing while loading in
            // otherwise, it looks unpolished and jumpy
            asynchronous: false

            visible: active
            active: (root.titleDelegate !== defaultTitleDelegate || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.Titles)
            onActiveChanged: {
                if (active) {
                    syncSource();
                }
            }

            function syncSource() {
                if (root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.ToolBar &&
                    root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.Titles &&
                    root.titleDelegate !== defaultTitleDelegate) {
                    sourceComponent = root.titleDelegate;
                } else if (active) {
                    const url = root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                        ? "private/globaltoolbar/ToolBarPageHeader.qml"
                        : "private/globaltoolbar/TitlesPageHeader.qml";
                    // TODO: find container reliably, remove assumption
                    setSource(Qt.resolvedUrl(url), {
                        pageRow: Qt.binding(() => row),
                        page: root,
                        current: Qt.binding(() => {
                            if (!row && !stack) {
                                return true;
                            } else if (stack) {
                                return stack;
                            } else {
                                return row.currentIndex === root.Kirigami.ColumnView.level;
                            }
                        }),
                    });
                }
            }
        },

        // page animations for animateWhenShown property
        QtObject {
            id: pageAnimController
            
            // setup custom translate object to be used for y animation
            property real yTranslate: 0
            property Translate translate: Translate {
                y: pageAnimController.yTranslate
            }
            
            function addTransform(item, transform) {
                if (!item.transform.includes(transform)) {
                    item.transform.push(transform);
                }
            }

            // called when animation is run
            function runShownAnimation() {
                if (!root.animateWhenShown) {
                    return;
                }
                
                showPageOpacityAnim.properties = 'contentItem.opacity';
                addTransform(contentItem, pageAnimController.translate);

                if (root.header && root.animateHeaderWhenShown) {
                    showPageOpacityAnim.properties += ',header.opacity';
                    addTransform(root.header, pageAnimController.translate);
                }
                if (root.footer && animateFooterWhenShown) {
                    showPageOpacityAnim.properties += ',footer.opacity';
                    addTransform(root.footer, pageAnimController.translate);
                }
                if (root.flickable) {
                    showPageOpacityAnim.properties += ',flickable.opacity';
                }
                
                showPageOpacityAnim.restart();
                showPageYAnim.restart();
            }

            property var showPageOpacityAnim: NumberAnimation {
                target: root
                from: 0; to: 1
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.InOutQuad
            }

            property var showPageYAnim: NumberAnimation {
                target: pageAnimController
                properties: 'yTranslate'
                from: Kirigami.Units.gridUnit * 2; to: 0
                duration: Kirigami.Units.longDuration * 3
                easing.type: Easing.OutExpo
            }
        }
    ]
    // bottom action buttons
    footer: Loader {
        id: bottomToolBar

        property T2.Page page: root
        property bool pageComplete: false

        active: {
            // Important! Do not do anything until the page has been
            // completed, so we are sure what the globalToolBarStyle is,
            // otherwise we risk creating the content and then discarding it.
            if (!pageComplete) {
                return false;
            }

            if ((globalToolBar.row && globalToolBar.row.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.ToolBar)
                || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.None) {
                return false;
            }

            if (root.actions.length === 0) {
                return false;
            }

            // Legacy
            if (typeof applicationWindow === "undefined") {
                return true;
            }

            return true;
        }

        source: Qt.resolvedUrl("./private/globaltoolbar/ToolBarPageFooter.qml")
    }

    Layout.fillWidth: true
}
