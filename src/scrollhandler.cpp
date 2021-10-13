/* SPDX-FileCopyrightText: 2017 The Qt Company Ltd.
 * SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#include "scrollhandler.h"
#include "wheelhandler.h"
#include <QDebug>
#include <QGuiApplication>
#include <QMouseEvent>
#include <QStyleHints>
#include <QTimer>
#include <QTouchEvent>
#include <QWheelEvent>

class ScrollHandlerPrivate
{
public:
    ScrollHandlerPrivate(ScrollHandler *q);

    qreal defaultVStepSize() const;
    qreal defaultHStepSize() const;
    void setVScrollBarStepSize(qreal stepSize);
    void setHScrollBarStepSize(qreal stepSize);

    bool scrollFlickable(QPointF pixelDelta,
                         QPointF angleDelta = QPointF(0,0),
                         Qt::KeyboardModifiers modifiers = Qt::NoModifier);

    ScrollHandler *const q;

    QQuickItem *target = nullptr;
    QQuickItem *verticalScrollBar = nullptr;
    QQuickItem *horizontalScrollBar = nullptr;
    // Matches QScrollArea + QScrollBar
    qreal defaultPixelStepSize = 20 * QGuiApplication::styleHints()->wheelScrollLines();
    // Matches QQuickScrollBar
    constexpr static qreal defaultPercentStepSize = 0.1;
    constexpr static qreal defaultScrollingTimeoutDelay = 400;
    qreal verticalStepSize = defaultPixelStepSize;
    qreal horizontalStepSize = defaultPixelStepSize;
    qreal scrollingTimeoutDelay = defaultScrollingTimeoutDelay;
    ScrollHandler::StepMode verticalStepMode = ScrollHandler::PixelStepMode;
    ScrollHandler::StepMode horizontalStepMode = ScrollHandler::PixelStepMode;
    bool explicitVStepMode = false;
    bool explicitHStepMode = false;
    bool explicitVStepSize = false;
    bool explicitHStepSize = false;
    bool scrolling = false;
    bool filterMouseEvents = false;
    bool keyNavigationEnabled = false;
    bool wasTouched = false;
    // Same as QXcbWindow.
    // Maybe use ShiftModifier instead? Most non-Qt and even some Qt software uses Shift for horizontal scrolling.
    constexpr static Qt::KeyboardModifiers defaultHorizontalScrollModifiers = Qt::AltModifier;
    // Same as QScrollBar/QAbstractSlider.
    constexpr static Qt::KeyboardModifiers defaultPageScrollModifiers = Qt::ControlModifier | Qt::ShiftModifier;
    Qt::KeyboardModifiers pageScrollModifiers = defaultPageScrollModifiers;
    Qt::KeyboardModifiers horizontalScrollModifiers = defaultHorizontalScrollModifiers;
    QTimer scrollingTimer;
    KirigamiWheelEvent kirigamiWheelEvent;
};

ScrollHandlerPrivate::ScrollHandlerPrivate(ScrollHandler *q)
    : q(q)
{
    scrollingTimer.setSingleShot(true);
    scrollingTimer.setInterval(scrollingTimeoutDelay);
    scrollingTimer.callOnTimeout([this, q](){
        scrolling = false;
        Q_EMIT q->scrollingChanged();
    });
}

qreal ScrollHandlerPrivate::defaultVStepSize() const
{
    if (verticalStepMode == ScrollHandler::PixelStepMode) {
        return defaultPixelStepSize;
    } else {
        return defaultPercentStepSize;
    }
}

qreal ScrollHandlerPrivate::defaultHStepSize() const
{
    if (horizontalStepMode == ScrollHandler::PixelStepMode) {
        return defaultPixelStepSize;
    } else {
        return defaultPercentStepSize;
    }
}

bool ScrollHandlerPrivate::scrollFlickable(QPointF pixelDelta, QPointF angleDelta, Qt::KeyboardModifiers modifiers)
{
    if (!target) {
        return false;
    }


    const qreal width = target->width();
    const qreal height = target->height();
    const qreal contentWidth = target->property("contentWidth").toReal();
    const qreal contentHeight = target->property("contentHeight").toReal();
    const qreal contentX = target->property("contentX").toReal();
    const qreal contentY = target->property("contentY").toReal();
    const qreal topMargin = target->property("topMargin").toReal();
    const qreal bottomMargin = target->property("bottomMargin").toReal();
    const qreal leftMargin = target->property("leftMaring").toReal();
    const qreal rightMargin = target->property("rightMargin").toReal();
    const qreal originX = target->property("originX").toReal();
    const qreal originY = target->property("originY").toReal();
    const qreal pageWidth = width - leftMargin - rightMargin;
    const qreal pageHeight = height - topMargin - bottomMargin;

    const qreal xTicks = angleDelta.x() / 120;
    const qreal yTicks = angleDelta.y() / 120;
    qreal xChange = 0;
    qreal yChange = 0;
    qreal newContentX = contentX;
    qreal newContentY = contentY;
    bool scrolled = false;
    bool usedHorizontalY = false;

    // Scroll X
    if (contentWidth > pageWidth) {
        // Use page size with pageScrollModifiers. Matches QScrollBar, which uses QAbstractSlider behavior.
        if (modifiers & pageScrollModifiers) {
            xChange = qBound(-pageWidth, xTicks * pageWidth, pageWidth);
        } else if (pixelDelta.x() != 0) {
            xChange = pixelDelta.x();
        } else if (verticalStepMode == ScrollHandler::PixelStepMode) {
            xChange = xTicks * horizontalStepSize;
        } else {
            xChange = xTicks * horizontalStepSize * contentWidth;
        }

        // Special case: when can't scroll vertically or using horizontal scroll modifiers, scroll horizontally with vertical wheel as well
        if (xChange == 0 && (contentHeight <= pageHeight || modifiers & horizontalScrollModifiers)) {
            usedHorizontalY = true;
            // Use page size with pageScrollModifiers, except for horizontalScrollModifiers.
            if (modifiers & (pageScrollModifiers & ~horizontalScrollModifiers)) {
                xChange = qBound(-pageWidth, yTicks * pageWidth, pageWidth);
            } else if (pixelDelta.y() != 0) {
                xChange = pixelDelta.y();
            } else if (verticalStepMode == ScrollHandler::PixelStepMode) {
                xChange = yTicks * horizontalStepSize;
            } else {
                xChange = yTicks * horizontalStepSize * contentWidth;
            }
        }

        qreal minXExtent = leftMargin - originX;
        qreal maxXExtent = width - (contentWidth + rightMargin + originX);

        newContentX = qBound(-minXExtent, contentX - xChange, -maxXExtent);
        if (contentX != newContentX) {
            scrolled = true;
            target->setProperty("contentX", newContentX);
        }
    }

    // Scroll Y
    if (contentHeight > pageHeight && !usedHorizontalY) {
        if (modifiers & pageScrollModifiers) {
            yChange = qBound(-pageHeight, yTicks * pageHeight, pageHeight);
        } else if (pixelDelta.y() != 0) {
            yChange = pixelDelta.y();
        } else if (verticalStepMode == ScrollHandler::PixelStepMode) {
            yChange = yTicks * verticalStepSize;
        } else {
            yChange = yTicks * verticalStepSize * contentHeight;
        }

        qreal minYExtent = topMargin - originY;
        qreal maxYExtent = height - (contentHeight + bottomMargin + originY);

        newContentY = qBound(-minYExtent, contentY - yChange, -maxYExtent);
        if (contentY != newContentY) {
            scrolled = true;
            target->setProperty("contentY", newContentY);
        }
    }

    if (scrolled) {
        // this is just for making the scrollbar
        target->metaObject()->invokeMethod(target, "flick", Q_ARG(qreal, xChange / qMax(std::abs(xChange), 1.0)), Q_ARG(qreal, yChange / qMax(std::abs(yChange), 1.0)));
        target->metaObject()->invokeMethod(target, "cancelFlick");
        scrollingTimer.start();
        if (!scrolling) {
            scrolling = true;
            Q_EMIT q->scrollingChanged();
        }
    }
    // accept all horizontal scrolling to prevent the default vertical scrolling behavior from being used;
    return scrolled || usedHorizontalY;
}

///////////////////////////////

// FIXME: putting ScrollHandler in a ScrollView without putting it in the
// `data` property causes a segfault when you try to interact with scrollbars.
// Kirigami WheelHandler has the same problem.
// Reparenting the ScrollHandler to the ScrollView doesn't fix the problem.

ScrollHandler::ScrollHandler(QObject *parent)
    : QObject(parent)
    , d(new ScrollHandlerPrivate(this))
{
    connect(QGuiApplication::styleHints(), &QStyleHints::wheelScrollLinesChanged, this, [this](int scrollLines) {
        d->defaultPixelStepSize = 20 * scrollLines;
        if (!d->explicitVStepSize && d->verticalStepMode == PixelStepMode && d->verticalStepSize != d->defaultPixelStepSize) {
            d->verticalStepSize = d->defaultPixelStepSize;
            Q_EMIT verticalStepSizeChanged();
        }
        if (!d->explicitHStepSize && d->horizontalStepMode == PixelStepMode && d->horizontalStepSize != d->defaultPixelStepSize) {
            d->horizontalStepSize = d->defaultPixelStepSize;
            Q_EMIT horizontalStepSizeChanged();
        }
    });
}

ScrollHandler::~ScrollHandler() noexcept = default;

/* TODO:
 * - Stop wheel events from reaching children of the Flickable while scrolling.
 *   - Can be done from outside ScrollHandler via the `scrolling` property, but automatic would be nicer.
 * - Allow drag events to work with children of the Flickable when mouse filtering is enabled.
 */
bool ScrollHandler::eventFilter(QObject *watched, QEvent *event)
{
    auto item = qobject_cast<QQuickItem*>(watched);
    if (!item || !item->isEnabled()) {
        return QObject::eventFilter(watched, event);
    }

    qreal contentWidth = 0;
    qreal contentHeight = 0;
    qreal pageWidth = 0;
    qreal pageHeight = 0;
    if (d->target) {
        contentWidth = d->target->property("contentWidth").toReal();
        contentHeight = d->target->property("contentHeight").toReal();
        pageWidth = d->target->width() - d->target->property("leftMaring").toReal() - d->target->property("rightMargin").toReal();
        pageHeight = d->target->height() - d->target->property("topMargin").toReal() - d->target->property("bottomMargin").toReal();
        // skip if there's no scrolling to be done
        if (contentHeight <= pageHeight && contentWidth <= pageWidth) {
            return QObject::eventFilter(watched, event);
        }
    }

    // The code handling touch, mouse and hover events is mostly copied/adapted from QQuickScrollView::childMouseEventFilter()
    switch (event->type()) {
    case QEvent::Wheel: {
        QWheelEvent *wheelEvent = static_cast<QWheelEvent *>(event);
        // NOTE: Sometimes pixelDelta is identical to angleDelta when using a mouse that shouldn't use pixelDelta.
        // If faulty pixelDelta, reset pixelDelta to (0,0).
        if (wheelEvent->pixelDelta() == wheelEvent->angleDelta()) {
            // In order to change any of the data, we have to create a whole new QWheelEvent from its constructor.
            QWheelEvent newWheelEvent(
                wheelEvent->position(),
                wheelEvent->globalPosition(),
                QPoint(0,0), // pixelDelta
                wheelEvent->angleDelta(),
                wheelEvent->buttons(),
                wheelEvent->modifiers(),
                wheelEvent->phase(),
                wheelEvent->inverted(),
                wheelEvent->source()
            );
            d->kirigamiWheelEvent.initializeFromEvent(&newWheelEvent);
        } else {
            d->kirigamiWheelEvent.initializeFromEvent(wheelEvent);
        }

        Q_EMIT wheel(&d->kirigamiWheelEvent);

        if (d->kirigamiWheelEvent.isAccepted()) {
            return true;
        }

        return d->scrollFlickable(d->kirigamiWheelEvent.pixelDelta(),
                                  d->kirigamiWheelEvent.angleDelta(),
                                  Qt::KeyboardModifiers(d->kirigamiWheelEvent.modifiers()));
    }

    case QEvent::TouchBegin: {
        setTouched(true);
        if (!d->filterMouseEvents) {
            break;
        }
        if (d->verticalScrollBar) {
            d->verticalScrollBar->setProperty("interactive", false);
        }
        if (d->horizontalScrollBar) {
            d->horizontalScrollBar->setProperty("interactive", false);
        }
        break;
    }

    case QEvent::TouchEnd: {
        setTouched(false);
        break;
    }

    case QEvent::MouseButtonPress: {
        // NOTE: Flickable does not handle touch events, only synthesized mouse events
        setTouched(static_cast<QMouseEvent *>(event)->source() != Qt::MouseEventNotSynthesized);
        if (!d->filterMouseEvents) {
            break;
        }
        if (!d->wasTouched) {
            if (d->verticalScrollBar) {
                d->verticalScrollBar->setProperty("interactive", true);
            }
            if (d->horizontalScrollBar) {
                d->horizontalScrollBar->setProperty("interactive", true);
            }
            break;
        }
        return !d->wasTouched && item == d->target;
    }

    case QEvent::MouseMove:
    case QEvent::MouseButtonRelease: {
        if (!d->filterMouseEvents) {
            break;
        }
        if (static_cast<QMouseEvent *>(event)->source() == Qt::MouseEventNotSynthesized && item == d->target) {
            return true;
        }
        break;
    }

    case QEvent::HoverEnter:
    case QEvent::HoverMove: {
        if (!d->filterMouseEvents) {
            break;
        }
        if (d->wasTouched && (item == d->verticalScrollBar || item == d->horizontalScrollBar)) {
            if (d->verticalScrollBar) {
                d->verticalScrollBar->setProperty("interactive", true);
            }
            if (d->horizontalScrollBar) {
                d->horizontalScrollBar->setProperty("interactive", true);
            }
        }
        break;
    }

    case QEvent::KeyPress: {
        if (!d->keyNavigationEnabled) {
            break;
        }
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
        bool horizontalScroll = keyEvent->modifiers() & d->horizontalScrollModifiers;
        switch (keyEvent->key()) {
        case Qt::Key_Up: return scrollUp();
        case Qt::Key_Down: return scrollDown();
        case Qt::Key_Left: return scrollLeft();
        case Qt::Key_Right: return scrollRight();
        case Qt::Key_PageUp: return horizontalScroll ? scrollLeft(pageWidth) : scrollUp(pageHeight);
        case Qt::Key_PageDown: return horizontalScroll ? scrollRight(pageWidth) : scrollDown(pageHeight);
        case Qt::Key_Home: return horizontalScroll ? scrollLeft(contentWidth) : scrollUp(contentHeight);
        case Qt::Key_End: return horizontalScroll ? scrollRight(contentWidth) : scrollDown(contentHeight);
        default: break;
        }
        break;
    }

    default: break;
    }

    return QObject::eventFilter(watched, event);
}

QQuickItem *ScrollHandler::target() const
{
    return d->target;
}

void ScrollHandler::setTarget(QQuickItem *target)
{
    if (d->target == target) {
        return;
    }

    if (target && !target->inherits("QQuickFlickable")) {
        qmlWarning(this) << "target must be a Flickable";
        return;
    }

    if (d->target) {
        d->target->removeEventFilter(this);
    }

    d->target = target;

    if (target) {
        target->installEventFilter(this);
    }

    Q_EMIT targetChanged();
}

QQuickItem *ScrollHandler::verticalScrollBar() const
{
    return d->verticalScrollBar;
}

void ScrollHandler::setVerticalScrollBar(QQuickItem *scrollBar)
{
    if (d->verticalScrollBar == scrollBar) {
        return;
    }

    if (scrollBar && !scrollBar->inherits("QQuickScrollBar")) {
        qmlWarning(this) << "verticalScrollBar must be a ScrollBar";
        return;
    }

    if (d->verticalScrollBar) {
        d->verticalScrollBar->removeEventFilter(this);
    }

    d->verticalScrollBar = scrollBar;

    if (scrollBar) {
        scrollBar->installEventFilter(this);
    }

    Q_EMIT verticalScrollBarChanged();
}

QQuickItem *ScrollHandler::horizontalScrollBar() const
{
    return d->horizontalScrollBar;
}

void ScrollHandler::setHorizontalScrollBar(QQuickItem *scrollBar)
{
    if (d->horizontalScrollBar == scrollBar) {
        return;
    }

    if (scrollBar && !scrollBar->inherits("QQuickScrollBar")) {
        qmlWarning(this) << "horizontalScrollBar must be a ScrollBar";
        return;
    }

    if (d->horizontalScrollBar) {
        d->horizontalScrollBar->removeEventFilter(this);
    }

    d->horizontalScrollBar = scrollBar;

    if (scrollBar) {
        scrollBar->installEventFilter(this);
    }

    Q_EMIT horizontalScrollBarChanged();
}

ScrollHandler::StepMode ScrollHandler::verticalStepMode() const
{
    return d->verticalStepMode;
}

void ScrollHandler::setVerticalStepMode(StepMode mode)
{
    if (d->verticalStepMode == mode) {
        return;
    }
    d->explicitVStepMode = true;
    d->verticalStepMode = mode;
    if (!d->explicitVStepSize) {
        resetVerticalStepSize();
    }
    Q_EMIT verticalStepModeChanged();
}

void ScrollHandler::resetVerticalStepMode()
{
    d->explicitVStepMode = false;
    if (d->verticalStepMode == PixelStepMode) {
        return;
    }
    d->verticalStepMode = PixelStepMode;
    if (!d->explicitVStepSize) {
        resetVerticalStepSize();
    }
    Q_EMIT verticalStepModeChanged();
}

ScrollHandler::StepMode ScrollHandler::horizontalStepMode() const
{
    return d->horizontalStepMode;
}

void ScrollHandler::setHorizontalStepMode(StepMode mode)
{
    if (d->horizontalStepMode == mode) {
        return;
    }
    d->explicitHStepMode = true;
    d->horizontalStepMode = mode;
    if (!d->explicitHStepSize) {
        resetHorizontalStepSize();
    }
    Q_EMIT horizontalStepModeChanged();
}

void ScrollHandler::resetHorizontalStepMode()
{
    d->explicitHStepMode = false;
    if (d->horizontalStepMode == PixelStepMode) {
        return;
    }
    d->horizontalStepMode = PixelStepMode;
    if (!d->explicitHStepSize) {
        resetHorizontalStepSize();
    }
    Q_EMIT horizontalStepModeChanged();
}

qreal ScrollHandler::verticalStepSize() const
{
    return d->verticalStepSize;
}

void ScrollHandler::setVerticalStepSize(qreal stepSize)
{
    d->explicitVStepSize = true;
    if (qFuzzyCompare(d->verticalStepSize, stepSize)) {
        return;
    }
    // Mimic the behavior of QQuickScrollBar increase() and decrease() when stepSize is 0
    if (qFuzzyIsNull(stepSize)) {
        setVerticalStepMode(PercentStepMode);
        resetVerticalStepSize();
        return;
    }
    d->verticalStepSize = stepSize;
    Q_EMIT verticalStepSizeChanged();
}

void ScrollHandler::resetVerticalStepSize()
{
    d->explicitVStepSize = false;
    qreal defaultStepSize = d->defaultVStepSize();
    if (qFuzzyCompare(d->verticalStepSize, defaultStepSize)) {
        return;
    }
    d->verticalStepSize = defaultStepSize;
    Q_EMIT verticalStepSizeChanged();
}

qreal ScrollHandler::horizontalStepSize() const
{
    return d->horizontalStepSize;
}

void ScrollHandler::setHorizontalStepSize(qreal stepSize)
{
    d->explicitHStepSize = true;
    if (qFuzzyCompare(d->horizontalStepSize, stepSize)) {
        return;
    }
    // Mimic the behavior of QQuickScrollBar increase() and decrease() when stepSize is 0
    if (qFuzzyIsNull(stepSize)) {
        setHorizontalStepMode(PercentStepMode);
        resetHorizontalStepSize();
        return;
    }
    d->horizontalStepSize = stepSize;
    Q_EMIT horizontalStepSizeChanged();
}

void ScrollHandler::resetHorizontalStepSize()
{
    d->explicitHStepSize = false;
    qreal defaultStepSize = d->defaultHStepSize();
    if (qFuzzyCompare(d->horizontalStepSize, defaultStepSize)) {
        return;
    }
    d->horizontalStepSize = defaultStepSize;
    Q_EMIT horizontalStepSizeChanged();
}

bool ScrollHandler::scrolling() const
{
    return d->scrolling;
}

int ScrollHandler::scrollingTimeoutDelay() const
{
    return d->scrollingTimeoutDelay;
}

void ScrollHandler::setScrollingTimeoutDelay(int delay)
{
    if (d->scrollingTimeoutDelay == delay) {
        return;
    }
    d->scrollingTimeoutDelay = delay;
    d->scrollingTimer.setInterval(delay);
    Q_EMIT scrollingTimeoutDelayChanged();
}

void ScrollHandler::resetScrollingTimeoutDelay()
{
    setScrollingTimeoutDelay(d->defaultScrollingTimeoutDelay);
}

Qt::KeyboardModifiers ScrollHandler::horizontalScrollModifiers() const
{
    return d->horizontalScrollModifiers;
}

void ScrollHandler::setHorizontalScrollModifiers(Qt::KeyboardModifiers modifiers)
{
    if (d->horizontalScrollModifiers == modifiers) {
        return;
    }
    d->horizontalScrollModifiers = modifiers;
    Q_EMIT horizontalScrollModifiersChanged();
}

void ScrollHandler::resetHorizontalScrollModifiers()
{
    setHorizontalScrollModifiers(d->defaultHorizontalScrollModifiers);
}

Qt::KeyboardModifiers ScrollHandler::pageScrollModifiers() const
{
    return d->pageScrollModifiers;
}

void ScrollHandler::setPageScrollModifiers(Qt::KeyboardModifiers modifiers)
{
    if (d->pageScrollModifiers == modifiers) {
        return;
    }
    d->pageScrollModifiers = modifiers;
    Q_EMIT pageScrollModifiersChanged();
}

void ScrollHandler::resetPageScrollModifiers()
{

    setPageScrollModifiers(d->defaultPageScrollModifiers);
}

bool ScrollHandler::filterMouseEvents() const
{
    return d->filterMouseEvents;
}

void ScrollHandler::setFilterMouseEvents(bool enabled)
{
    if (d->filterMouseEvents == enabled) {
        return;
    }
    d->filterMouseEvents = enabled;
    Q_EMIT filterMouseEventsChanged();
}

bool ScrollHandler::keyNavigationEnabled() const
{
    return d->keyNavigationEnabled;
}

void ScrollHandler::setKeyNavigationEnabled(bool enabled)
{
    if (d->keyNavigationEnabled == enabled) {
        return;
    }
    d->keyNavigationEnabled = enabled;
    Q_EMIT keyNavigationEnabledChanged();
}

bool ScrollHandler::touched() const
{
    return d->wasTouched;
}

void ScrollHandler::setTouched(bool touched)
{
    if (d->wasTouched == touched) {
        return;
    }
    d->wasTouched = touched;
    Q_EMIT touchedChanged();
}

bool ScrollHandler::scrollPixels(qreal xPixelDelta, qreal yPixelDelta)
{
    if (xPixelDelta == 0 && yPixelDelta == 0) {
        return false;
    }
    return d->scrollFlickable(QPointF(xPixelDelta, yPixelDelta));
}

bool ScrollHandler::scrollUp(qreal stepSize)
{
    if (stepSize == 0) {
        stepSize = d->verticalStepSize;
    }
    if (d->verticalStepMode == PercentStepMode && d->target) {
        stepSize *= d->target->property("contentHeight").toReal();
    }
    return d->scrollFlickable(QPointF(0, stepSize));
}

bool ScrollHandler::scrollDown(qreal stepSize)
{
    if (stepSize == 0) {
        stepSize = d->verticalStepSize;
    }
    if (d->verticalStepMode == PercentStepMode && d->target) {
        stepSize *= d->target->property("contentHeight").toReal();
    }
    return d->scrollFlickable(QPointF(0, -stepSize));
}

bool ScrollHandler::scrollLeft(qreal stepSize)
{
    if (stepSize == 0) {
        stepSize = d->horizontalStepSize;
    }
    if (d->horizontalStepMode == PercentStepMode && d->target) {
        stepSize *= d->target->property("contentWidth").toReal();
    }
    return d->scrollFlickable(QPoint(stepSize, 0));
}

bool ScrollHandler::scrollRight(qreal stepSize)
{
    if (stepSize == 0) {
        stepSize = d->horizontalStepSize;
    }
    if (d->horizontalStepMode == PercentStepMode && d->target) {
        stepSize *= d->target->property("contentWidth").toReal();
    }
    return d->scrollFlickable(QPoint(-stepSize, 0));
}
