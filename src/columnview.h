/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QPointer>
#include <QQuickItem>
#include <QVariant>

class ContentItem;
class ColumnView;

class ScrollIntentionEvent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointF delta MEMBER delta CONSTANT)
    Q_PROPERTY(bool accepted MEMBER accepted)
public:
    ScrollIntentionEvent()
    {
    }
    ~ScrollIntentionEvent() override
    {
    }

    QPointF delta;
    bool accepted = false;
};

/**
 * This attached property is available to every child Item of the ColumnView,
 * giving access to view and page information such as position and information for layouting.
 * @since org.kde.kirigami 2.7
 */
class ColumnViewAttached : public QObject
{
    Q_OBJECT

    /**
     * @brief The index position of the column in the view, starting from 0.
     */
    Q_PROPERTY(int index READ index WRITE setIndex NOTIFY indexChanged)

    /**
     * @brief This property sets whether the item will expand and take the whole viewport space minus the reservedSpace.
     */
    Q_PROPERTY(bool fillWidth READ fillWidth WRITE setFillWidth NOTIFY fillWidthChanged)

    /**
     * @brief This property holds the reserved space in pixels
     * applied to every item with fillWidth set to @c true.
     *
     * Every item that has fillWidth set to @c true will subtract this amount from the viewports width.
     */
    Q_PROPERTY(qreal reservedSpace READ reservedSpace WRITE setReservedSpace NOTIFY reservedSpaceChanged)

    /**
     * @brief This property sets whether the column view will manage input
     * events from its children.
     * 
     * The ColumnView uses an event filter to intercept information about its
     * children like layouting information. This may conflict with its children
     * input events in special cases.
     *  
     * If you want to guarantee that a child of the column view will not be
     * intercepted by this event filter and that input events are managed by the
     * child, set this to @c true.
     * 
     * This is desirable in special cases where a component has a single purpose
     * and is managed solely via input events, such as a map or document viewer.
     * 
     * @see QtQuick.MouseArea.preventStealing
     */
    Q_PROPERTY(bool preventStealing READ preventStealing WRITE setPreventStealing NOTIFY preventStealingChanged)

    /**
     * @brief This property sets whether this page will always be visible.
     *
     * When set to @c true, the page will either stay at the left or right side.
     */
    Q_PROPERTY(bool pinned READ isPinned WRITE setPinned NOTIFY pinnedChanged)

    /**
     * @brief This is an attached property for Items to directly access the ColumnView.
     */
    Q_PROPERTY(ColumnView *view READ view NOTIFY viewChanged)

    /**
     * @brief This property holds whether this column is at least partly visible in ColumnView's viewport.
     * @since KDE Frameworks 5.77
     */
    Q_PROPERTY(bool inViewport READ inViewport NOTIFY inViewportChanged)

public:
    ColumnViewAttached(QObject *parent = nullptr);
    ~ColumnViewAttached() override;

    void setIndex(int index);
    int index() const;

    void setFillWidth(bool fill);
    bool fillWidth() const;

    qreal reservedSpace() const;
    void setReservedSpace(qreal space);

    ColumnView *view();
    void setView(ColumnView *view);

    // Private API, not for QML use
    QQuickItem *originalParent() const;
    void setOriginalParent(QQuickItem *parent);

    bool shouldDeleteOnRemove() const;
    void setShouldDeleteOnRemove(bool del);

    bool preventStealing() const;
    void setPreventStealing(bool prevent);

    bool isPinned() const;
    void setPinned(bool pinned);

    bool inViewport() const;
    void setInViewport(bool inViewport);

Q_SIGNALS:
    void indexChanged();
    void fillWidthChanged();
    void reservedSpaceChanged();
    void viewChanged();
    void preventStealingChanged();
    void pinnedChanged();
    void scrollIntention(ScrollIntentionEvent *event);
    void inViewportChanged();

private:
    int m_index = -1;
    bool m_fillWidth = false;
    qreal m_reservedSpace = 0;
    QPointer<ColumnView> m_view;
    QPointer<QQuickItem> m_originalParent;
    bool m_customFillWidth = false;
    bool m_customReservedSpace = false;
    bool m_shouldDeleteOnRemove = true;
    bool m_preventStealing = false;
    bool m_pinned = false;
    bool m_inViewport = false;
};

/**
 * ColumnView is a container that lays out items horizontally in a row,
 * when not all items fit in the ColumnView, it will behave like a Flickable and will be a scrollable view which shows only a determined number of columns.
 * The columns can either all have the same fixed size (recommended),
 * size themselves with implicitWidth, or automatically expand to take all the available width: by default the last column will always be the expanding one.
 * Items inside the ColumnView can access info of the view and set layouting hints via the ColumnView attached property.
 *
 * This is the base for the implementation of PageRow
 *
 * @see ColumnViewAttached
 * @since org.kde.kirigami 2.7
 */
class ColumnView : public QQuickItem
{
    Q_OBJECT

    /**
     * @brief This property holds the ColumnView's column resizing strategy.
     */
    Q_PROPERTY(ColumnResizeMode columnResizeMode READ columnResizeMode WRITE setColumnResizeMode NOTIFY columnResizeModeChanged)

    /**
     * @brief The width of all columns when columnResizeMode is set to ``ColumnResizeMode::FixedColumns``.
     */
    Q_PROPERTY(qreal columnWidth READ columnWidth WRITE setColumnWidth NOTIFY columnWidthChanged)

    /**
     * @brief This property holds the column count.
     */
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    /**
     * @brief This property holds the index of currently focused item.
    * @note The current item will have keyboard focus.
     */
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)

    /**
     * @brief This property points to the currently focused item.
     * @note The focused item will have keyboard focus.
     */
    Q_PROPERTY(QQuickItem *currentItem READ currentItem NOTIFY currentItemChanged)

    /**
     * @brief This property points to the contentItem of the view,
     * which is the parent of the column items.
     */
    Q_PROPERTY(QQuickItem *contentItem READ contentItem CONSTANT)

    /**
     * @brief This property holds the view's horizontal scroll value in pixels.
     */
    Q_PROPERTY(qreal contentX READ contentX WRITE setContentX NOTIFY contentXChanged)

    /**
     * @brief This property holds the compound width of all columns in the view.
     */
    Q_PROPERTY(qreal contentWidth READ contentWidth NOTIFY contentWidthChanged)

    /**
     * @brief This property holds the view's top padding.
     */
    Q_PROPERTY(qreal topPadding READ topPadding WRITE setTopPadding NOTIFY topPaddingChanged)

    /**
     * @brief This property holds the view's bottom padding.
     */
    Q_PROPERTY(qreal bottomPadding READ bottomPadding WRITE setBottomPadding NOTIFY bottomPaddingChanged)

    /**
     * @brief This property holds the scrolling animation's duration.
     */
    Q_PROPERTY(int scrollDuration READ scrollDuration WRITE setScrollDuration NOTIFY scrollDurationChanged)

    /**
     * @brief This property sets whether columns should be visually separated by a line.
     */
    Q_PROPERTY(bool separatorVisible READ separatorVisible WRITE setSeparatorVisible NOTIFY separatorVisibleChanged)

    /**
     * @brief This property holds the list of all visible items that are currently at least partially visible.
     */
    Q_PROPERTY(QList<QObject *> visibleItems READ visibleItems NOTIFY visibleItemsChanged)

    /**
     * @brief This property points to the first currently visible item.
     */
    Q_PROPERTY(QQuickItem *firstVisibleItem READ firstVisibleItem NOTIFY firstVisibleItemChanged)

    /**
     * @brief This property points to the last currently visible item.
     */
    Q_PROPERTY(QQuickItem *lastVisibleItem READ lastVisibleItem NOTIFY lastVisibleItemChanged)

    // Properties to make it similar to Flickable
    /**
     * @brief This property specifies whether the user is currently dragging the view's contents with a touch gesture.
     */
    Q_PROPERTY(bool dragging READ dragging NOTIFY draggingChanged)

    /**
     * @brief This property specifies whether the user is currently dragging
     * the view's contents with a touch gesture or if the view is animating.
     *
     */
    Q_PROPERTY(bool moving READ moving NOTIFY movingChanged)

    /**
     * @brief This property sets whether the view supports moving the contents by
     * dragging them with a touch gesture.
     */
    Q_PROPERTY(bool interactive READ interactive WRITE setInteractive NOTIFY interactiveChanged)

    /**
     * @brief This property sets whether the view supports moving the contents
     * by dragging them with a mouse.
     */
    Q_PROPERTY(bool acceptsMouse READ acceptsMouse WRITE setAcceptsMouse NOTIFY acceptsMouseChanged)

    // Default properties
    /**
     * @brief This property holds a list of every column visual item that the view currently contains.
     */
    Q_PROPERTY(QQmlListProperty<QQuickItem> contentChildren READ contentChildren NOTIFY contentChildrenChanged FINAL)

    /**
     * @brief This property holds a list of every column visual and non-visual item that the view currently contains.
     */
    Q_PROPERTY(QQmlListProperty<QObject> contentData READ contentData FINAL)
    Q_CLASSINFO("DefaultProperty", "contentData")

public:
    enum ColumnResizeMode {
        /**
         * @brief Every column is fixed at the same width specified by columnWidth property.
         */
        FixedColumns = 0,

        /**
         * @brief Columns take their width from the implicitWidth property.
         */
        DynamicColumns,

        /**
         * @brief Only one column is shown, and as wide as the viewport allows it.
         */
        SingleColumn,
    };
    Q_ENUM(ColumnResizeMode)

    ColumnView(QQuickItem *parent = nullptr);
    ~ColumnView() override;

    // QML property accessors
    ColumnResizeMode columnResizeMode() const;
    void setColumnResizeMode(ColumnResizeMode mode);

    qreal columnWidth() const;
    void setColumnWidth(qreal width);

    int currentIndex() const;
    void setCurrentIndex(int index);

    int scrollDuration() const;
    void setScrollDuration(int duration);

    bool separatorVisible() const;
    void setSeparatorVisible(bool visible);

    int count() const;

    qreal topPadding() const;
    void setTopPadding(qreal padding);

    qreal bottomPadding() const;
    void setBottomPadding(qreal padding);

    QQuickItem *currentItem();

    // NOTE: It's a QList<QObject *> as QML can't correctly build an Array out of QList<QQuickItem*>
    QList<QObject *> visibleItems() const;
    QQuickItem *firstVisibleItem() const;
    QQuickItem *lastVisibleItem() const;

    QQuickItem *contentItem() const;

    QQmlListProperty<QQuickItem> contentChildren();
    QQmlListProperty<QObject> contentData();

    bool dragging() const;
    bool moving() const;
    qreal contentWidth() const;

    qreal contentX() const;
    void setContentX(qreal x) const;

    bool interactive() const;
    void setInteractive(bool interactive);

    bool acceptsMouse() const;
    void setAcceptsMouse(bool accepts);

    // Api not intended for QML use
    // can't do overloads in QML
    QQuickItem *removeItem(QQuickItem *item);
    QQuickItem *removeItem(int item);

    // QML attached property
    static ColumnViewAttached *qmlAttachedProperties(QObject *object);

public Q_SLOTS:
    /**
     * @brief This method pushes a new item to the end of the view.
     * @param item the new item which will be reparented and managed
     */
    void addItem(QQuickItem *item);

    /**
     * @brief This method inserts a new item in the view at a given position.
     *
     * The current Item will not be changed, currentIndex will be adjusted
     * accordingly if needed to keep the same current item.
     *
     * @param pos the position we want the new item to be inserted in
     * @param item the new item which will be reparented and managed
     */
    void insertItem(int pos, QQuickItem *item);

    /**
     * @brief This method replaces an item in the view at a given position with a new item.
     *
     * The current Item and currentIndex will not be changed.
     *
     * @param pos the position we want the new item to be placed in
     * @param item the new item which will be reparented and managed
     */
    void replaceItem(int pos, QQuickItem *item);

    /**
     * @brief This method swaps items at given positions.
     *
     * The currentIndex property may be changed in order to keep currentItem the same.
     *
     * @param from the old position
     * @param to the new position
     */
    void moveItem(int from, int to);

    /**
     * @brief This method removes an item from the view.
     *
     * Items will be reparented to their old parent.
     * If they have JavaScript ownership and they didn't have an old parent, they will be destroyed.
     *
     * The currentIndex property may be changed in order to keep the same currentItem.
     *
     * @param item it can either be a pointer of an item or an integer specifying the position to remove
     * @returns the item that has just been removed
     */
    QQuickItem *removeItem(const QVariant &item);

    /**
     * @brief This method removes every item after the specified @p item from
     * the column view.
     *
     * If no item is specified, only the last item will be removed.
     *
     * Items that are inserted in a column view are reparented to the column
     * view while keeping information about the original parent, if available.
     *
     * After calling this method, the items removed from the column view will
     * either be reparented back to their original parent if they had one, or be
     * deleted if they did not (this is normally the case if the item was
     * created from a JavaScript expression).
     *
     * @param item it can either be a pointer to an item or an integer
     * specifying the position to remove.
     *
     * @returns the item that has just been removed.
     */
    QQuickItem *pop(QQuickItem *item);

    /**
     * @brief This method removes every item in the view.
     *
     * Items will be reparented to their old parent.
     * If they have JavaScript ownership and they didn't have an old parent, they will be destroyed
     */
    void clear();

    /**
     * @brief This method checks whether an item is present in the view.
     */
    bool containsItem(QQuickItem *item);

    /**
     * @brief This method returns the item in the view at a given position.
     *
     * If there is no item at the point specified, or the item is not visible null is returned.
     *
     * @param x The horizontal position of the item
     * @param y The vertical position of the item
     */
    QQuickItem *itemAt(qreal x, qreal y);

protected:
    void classBegin() override;
    void componentComplete() override;
    void updatePolish() override;
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;
#else
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
#endif
    bool childMouseEventFilter(QQuickItem *item, QEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseUngrabEvent() override;

Q_SIGNALS:
    /**
     * @brief This signal is emitted when an item has been inserted into the view.
     * @param position where the page has been inserted
     * @param item a pointer to the new item
     */
    void itemInserted(int position, QQuickItem *item);

    /**
     * @brief This signal is emitted when an item has been removed from the view.
     * @param item a pointer to the item that has just been removed
     */
    void itemRemoved(QQuickItem *item);

    // Property notifiers
    void contentChildrenChanged();
    void columnResizeModeChanged();
    void columnWidthChanged();
    void currentIndexChanged();
    void currentItemChanged();
    void visibleItemsChanged();
    void countChanged();
    void draggingChanged();
    void movingChanged();
    void contentXChanged();
    void contentWidthChanged();
    void interactiveChanged();
    void acceptsMouseChanged();
    void scrollDurationChanged();
    void separatorVisibleChanged();
    void firstVisibleItemChanged();
    void lastVisibleItemChanged();
    void topPaddingChanged();
    void bottomPaddingChanged();

private:
    static void contentChildren_append(QQmlListProperty<QQuickItem> *prop, QQuickItem *object);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    static int contentChildren_count(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *contentChildren_at(QQmlListProperty<QQuickItem> *prop, int index);
#else
    static qsizetype contentChildren_count(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *contentChildren_at(QQmlListProperty<QQuickItem> *prop, qsizetype index);
#endif
    static void contentChildren_clear(QQmlListProperty<QQuickItem> *prop);

    static void contentData_append(QQmlListProperty<QObject> *prop, QObject *object);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    static int contentData_count(QQmlListProperty<QObject> *prop);
    static QObject *contentData_at(QQmlListProperty<QObject> *prop, int index);
#else
    static qsizetype contentData_count(QQmlListProperty<QObject> *prop);
    static QObject *contentData_at(QQmlListProperty<QObject> *prop, qsizetype index);
#endif
    static void contentData_clear(QQmlListProperty<QObject> *prop);

    QList<QObject *> m_contentData;

    ContentItem *m_contentItem;
    QPointer<QQuickItem> m_currentItem;

    qreal m_oldMouseX = -1.0;
    qreal m_startMouseX = -1.0;
    qreal m_oldMouseY = -1.0;
    qreal m_startMouseY = -1.0;
    int m_currentIndex = -1;
    qreal m_topPadding = 0;
    qreal m_bottomPadding = 0;

    bool m_mouseDown = false;
    bool m_interactive = true;
    bool m_dragging = false;
    bool m_moving = false;
    bool m_separatorVisible = true;
    bool m_complete = false;
    bool m_acceptsMouse = false;
};

QML_DECLARE_TYPEINFO(ColumnView, QML_HAS_ATTACHED_PROPERTIES)
