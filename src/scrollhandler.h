/* SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#pragma once

#include <QObject>
#include <QPoint>
#include <QQuickItem>
#include <QtQml>
#include <memory>

class KirigamiWheelEvent;
class ScrollHandlerPrivate;

/**
 * @brief Handles scrolling for a Flickable and 2 ScrollBars.
 *
 * ScrollHandler filters events from a Flickable, a vertical ScrollBar and a horizontal ScrollBar.
 * Wheel and KeyPress events (when `keyNavigationEnabled` is true) are used to scroll the Flickable.
 * When `filterMouseEvents` is true, ScrollHandler blocks mouse button input from reaching the Flickable
 * and sets the `interactive` property of the scrollbars to false when touch input is used.
 *
 * Wheel event handling behavior:
 *
 * - If there is a pixel delta, use that instead of angle delta.
 * - When using angle delta, scroll using the step increments defined via `verticalStepMode`, `horizontalStepMode`, `verticalStepSize` and `horizontalStepSize`.
 * - When one of the keyboard modifiers in `horizontalScrollModifiers` is used, use the Y axis angle delta to scroll horizontally.
 * If horizontal scrolling is not possible and `pageScrollModifiers` uses the same modifier as the one being used for horizontal scrolling,
 * the Flickable will scroll vertically by pages instead.
 * - When one of the keyboard modifiers in `pageScrollModifiers` is used, scroll by pages.
 * When using a device that doesn't use 120 angle delta unit increments such as a touchpad,
 * this will increase the speed of scrolling rather than skipping whole pages at once.
 * - When vertical scrolling is not possible, automatically use the Y axis angle delta to scroll horizontally.
 *
 * Common usage with a Flickable:
 *
 * @include scrollhandler/FlickableUsage.qml
 *
 * Common usage with a ScrollView:
 *
 * @include scrollhandler/ScrollViewUsage.qml
 *
 * @sa filterMouseEvents, keyNavigationEnabled, verticalStepMode, horizontalStepMode, verticalStepSize, horizontalStepSize, horizontalScrollModifiers,
 * pageScrollModifiers
 *
 * @since KDE Frameworks 5.88, org.kde.kirigami 2.20
 */
class ScrollHandler : public QObject
{
    Q_OBJECT

    /**
     * @brief This property holds the Qt Quick Flickable that the ScrollHandler will control.
     *
     * @sa verticalScrollBar, horizontalScrollBar
     */
    Q_PROPERTY(QQuickItem *target READ target WRITE setTarget NOTIFY targetChanged FINAL)

    /**
     * @brief This property holds the vertical Qt Quick Controls ScrollBar that the ScrollHandler will control.
     *
     * @sa target, horizontalScrollBar
     */
    Q_PROPERTY(QQuickItem *verticalScrollBar READ verticalScrollBar
               WRITE setVerticalScrollBar NOTIFY verticalScrollBarChanged FINAL)

    /**
     * @brief This property holds the horizontal Qt Quick Controls ScrollBar that the ScrollHandler will control.
     *
     * @sa target, verticalScrollBar
     */
    Q_PROPERTY(QQuickItem *horizontalScrollBar READ horizontalScrollBar
               WRITE setHorizontalScrollBar NOTIFY horizontalScrollBarChanged FINAL)

    /**
     * @brief This property holds the vertical step mode.
     *
     * The default value is `PixelStepMode`.
     *
     * @sa verticalStepSize, StepMode
     */
    Q_PROPERTY(StepMode verticalStepMode READ verticalStepMode
               WRITE setVerticalStepMode RESET resetVerticalStepMode
               NOTIFY verticalStepModeChanged FINAL)

    /**
     * @brief This property holds the horizontal step mode.
     *
     * The default value is `PixelStepMode`.
     *
     * @sa horizontalStepSize, StepMode
     */
    Q_PROPERTY(StepMode horizontalStepMode READ horizontalStepMode
               WRITE setHorizontalStepMode RESET resetHorizontalStepMode
               NOTIFY horizontalStepModeChanged FINAL)

    /**
     * @brief This property holds the vertical step size.
     *
     * When `verticalStepMode` is set to `PixelStepMode`, the default value is equivalent to `20 * Qt.styleHints.wheelScrollLines`. This is consistent with the default increment for QScrollArea.
     *
     * When `verticalStepMode` is set to `PercentStepMode`, the default value is `0.1` (10%). This is consistent with the default increment for Qt Quick Controls ScrollBar.
     *
     * @sa verticalStepMode, StepMode
     */
    Q_PROPERTY(qreal verticalStepSize READ verticalStepSize
               WRITE setVerticalStepSize RESET resetVerticalStepSize
               NOTIFY verticalStepSizeChanged FINAL)

    /**
     * @brief This property holds the horizontal step size.
     *
     * When `horizontalStepMode` is set to `PixelStepMode`, the default value is equivalent to `20 * Qt.styleHints.wheelScrollLines`. This is consistent with the default increment for QScrollArea.
     *
     * When `horizontalStepMode` is set to `PercentStepMode`, the default value is `0.1` (10%). This is consistent with the default increment for Qt Quick Controls ScrollBar.
     *
     * @sa horizontalStepMode, StepMode
     */
    Q_PROPERTY(qreal horizontalStepSize READ horizontalStepSize
               WRITE setHorizontalStepSize RESET resetHorizontalStepSize
               NOTIFY horizontalStepSizeChanged FINAL)

    /**
     * @brief This property holds whether the ScrollHandler is scrolling.
     *
     * Scrolling is actually instant, so to make this property useful, `scrollingTimeoutDelay` sets the delay before this is set to false again.
     *
     * @sa scrollingTimeoutDelay
     */
    Q_PROPERTY(bool scrolling READ scrolling NOTIFY scrollingChanged FINAL)

    /**
     * @brief This property holds the delay before the `scrolling` property is set to false again.
     *
     * The default value is `400` milliseconds.
     *
     * @sa scrolling
     */
    Q_PROPERTY(int scrollingTimeoutDelay READ scrollingTimeoutDelay
               WRITE setScrollingTimeoutDelay RESET resetScrollingTimeoutDelay
               NOTIFY scrollingTimeoutDelayChanged FINAL)

    /**
     * @brief This property holds the keyboard modifiers that will be used to start horizontal scrolling using the Y axis pixelDelta or angleDelta.
     *
     * When horizontal scrolling isn't possible, vertical page scrolling will be used instead when `pageScrollModifiers` and `horizontalScrollModifiers` share the modifier being used.
     *
     * The wheel event will always be accepted when horizontal scrolling is used to prevent the Flickable from using the wheel event for vertical scrolling.
     *
     * The default value is equivalent to `Qt.ShiftModifier`.
     *
     * @sa pageScrollModifiers
     */
    Q_PROPERTY(Qt::KeyboardModifiers horizontalScrollModifiers READ horizontalScrollModifiers
               WRITE setHorizontalScrollModifiers RESET resetHorizontalScrollModifiers
               NOTIFY horizontalScrollModifiersChanged FINAL)

    /**
     * @brief This property holds the keyboard modifiers that will be used to start page scrolling.
     *
     * The default value is equivalent to `Qt.ControlModifier | Qt.ShiftModifier`. This matches QScrollBar, which uses QAbstractSlider behavior.
     *
     * @sa horizontalScrollModifiers
     */
    Q_PROPERTY(Qt::KeyboardModifiers pageScrollModifiers READ pageScrollModifiers
               WRITE setPageScrollModifiers RESET resetPageScrollModifiers
               NOTIFY pageScrollModifiersChanged FINAL)

    /**
     * @brief This property holds whether the ScrollHandler filters mouse events like a Qt Quick Controls ScrollView would.
     *
     * Touch events are allowed to flick the view and make the scrollbars not interactive.
     *
     * Mouse events are not allowed to flick the view and make the scrollbars interactive.
     *
     * The default value is `false`.
     *
     * @sa keyNavigationEnabled
     */
    Q_PROPERTY(bool filterMouseEvents READ filterMouseEvents
               WRITE setFilterMouseEvents NOTIFY filterMouseEventsChanged FINAL)

    /**
     * @brief This property holds whether the ScrollHandler filters key events.
     *
     * - Left arrow scrolls a step to the left.
     * - Right arrow scrolls a step to the right.
     * - Up arrow scrolls a step upwards.
     * - Down arrow scrolls a step downwards.
     * - PageUp scrolls to the previous page.
     * - PageDown scrolls to the next page.
     * - Home scrolls to the beginning.
     * - End scrolls to the end.
     * - When one of the keyboard modifiers in `horizontalScrollModifiers` is used, scroll horizontally when using PageUp, PageDown, Home or End.
     *
     * The default value is `false`.
     *
     * @sa filterMouseEvents
     */
    Q_PROPERTY(bool keyNavigationEnabled READ keyNavigationEnabled
               WRITE setKeyNavigationEnabled NOTIFY keyNavigationEnabledChanged FINAL)

    /**
     * @brief This property holds whether the ScrollHandler is recieving touch input.
     *
     * This property can be used on the `interactive` properties of Qt Quick Flickable
     * and Qt Quick Controls ScrollBar to disable flicking with the mouse or dragging
     * scrollbars with touch input.
     */
    Q_PROPERTY(bool touched READ touched NOTIFY touchedChanged FINAL)

public:
    explicit ScrollHandler(QObject *parent = nullptr);
    ~ScrollHandler() override;

    enum StepMode {
        PixelStepMode, ///< Interpret the step size as a specific amount of pixels.
        PercentStepMode ///< Interpret the step size as a percent of the Flickable's contentWidth or contentHeight.
        // TODO: Add ItemStepMode for use in ListView, GridView and TableView?
        // PixelStepMode can be used to go item-by-item, but it's a bit less
        // elegant and isn't guaranteed to go item-by-item with devices that
        // don't do 120 angleDelta unit increments, such as touchpads.
        // I think managing the currentIndex of a view should be out of scope
        // for ScrollHandler, so let's avoid getting too fancy.
    };
    Q_ENUM(StepMode)

    QQuickItem *target() const;
    void setTarget(QQuickItem *target);
    Q_SIGNAL void targetChanged();

    QQuickItem *verticalScrollBar() const;
    void setVerticalScrollBar(QQuickItem *scrollBar);
    void resetVerticalScrollBar();
    Q_SIGNAL void verticalScrollBarChanged();

    QQuickItem *horizontalScrollBar() const;
    void setHorizontalScrollBar(QQuickItem *scrollBar);
    void resetHorizontalScrollBar();
    Q_SIGNAL void horizontalScrollBarChanged();

    StepMode verticalStepMode() const;
    void setVerticalStepMode(StepMode mode);
    void resetVerticalStepMode();
    Q_SIGNAL void verticalStepModeChanged();

    StepMode horizontalStepMode() const;
    void setHorizontalStepMode(StepMode mode);
    void resetHorizontalStepMode();
    Q_SIGNAL void horizontalStepModeChanged();

    qreal verticalStepSize() const;
    void setVerticalStepSize(qreal stepSize);
    void resetVerticalStepSize();
    Q_SIGNAL void verticalStepSizeChanged();

    qreal horizontalStepSize() const;
    void setHorizontalStepSize(qreal stepSize);
    void resetHorizontalStepSize();
    Q_SIGNAL void horizontalStepSizeChanged();

    bool scrolling() const;
    Q_SIGNAL void scrollingChanged();

    int scrollingTimeoutDelay() const;
    void setScrollingTimeoutDelay(int delay);
    void resetScrollingTimeoutDelay();
    Q_SIGNAL void scrollingTimeoutDelayChanged();

    Qt::KeyboardModifiers horizontalScrollModifiers() const;
    void setHorizontalScrollModifiers(Qt::KeyboardModifiers modifiers);
    void resetHorizontalScrollModifiers();
    Q_SIGNAL void horizontalScrollModifiersChanged();

    Qt::KeyboardModifiers pageScrollModifiers() const;
    void setPageScrollModifiers(Qt::KeyboardModifiers modifiers);
    void resetPageScrollModifiers();
    Q_SIGNAL void pageScrollModifiersChanged();

    bool filterMouseEvents() const;
    void setFilterMouseEvents(bool enabled);
    Q_SIGNAL void filterMouseEventsChanged();

    bool keyNavigationEnabled() const;
    void setKeyNavigationEnabled(bool enabled);
    Q_SIGNAL void keyNavigationEnabledChanged();

    bool touched() const;
    void setTouched(bool touched);
    Q_SIGNAL void touchedChanged();

    /**
     * Scroll with x and y pixel deltas.
     * 
     * returns true if the contentItem was moved.
     */
    Q_INVOKABLE bool scrollPixels(qreal xPixelDelta, qreal yPixelDelta);
    /**
     * Scroll up one step. If the stepSize parameter is not set, the verticalStepSize will be used.
     * 
     * returns true if the contentItem was moved.
     */
    Q_INVOKABLE bool scrollUp(qreal stepSize = 0);
    /**
     * Scroll down one step. If the stepSize parameter is not set, the verticalStepSize will be used.
     * 
     * returns true if the contentItem was moved.
     */
    Q_INVOKABLE bool scrollDown(qreal stepSize = 0);
    /**
     * Scroll left one step. If the stepSize parameter is not set, the horizontalStepSize will be used.
     * 
     * returns true if the contentItem was moved.
     */
    Q_INVOKABLE bool scrollLeft(qreal stepSize = 0);
    /**
     * Scroll right one step. If the stepSize parameter is not set, the horizontalStepSize will be used.
     * 
     * returns true if the contentItem was moved.
     */
    Q_INVOKABLE bool scrollRight(qreal stepSize = 0);

    /**
     * This signal is emitted when a wheel event reaches the event filter.
     */
    Q_SIGNAL void wheel(KirigamiWheelEvent *wheel);

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    const std::unique_ptr<ScrollHandlerPrivate> d;
    Q_DISABLE_COPY(ScrollHandler)
};

QML_DECLARE_TYPE(ScrollHandler)
