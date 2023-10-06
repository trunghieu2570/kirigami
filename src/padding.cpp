/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "padding.h"

#include <QMarginsF>
#include <qnumeric.h>
#include <qtypes.h>

class PaddingPrivate
{
    Padding *const q;

public:
    enum Paddings {
        Left = 1 << 0,
        Top = 1 << 1,
        Right = 1 << 2,
        Bottom = 1 << 3,
        Horizontal = Left | Right,
        Vertical = Top | Bottom,
        All = Horizontal | Vertical
    };

    PaddingPrivate(Padding *qq)
        : q(qq)
    {
    }

    void calculateImplicitSize();
    void signalPaddings(const QMarginsF &oldPaddings, Paddings paddings);
    QMarginsF margins() const;

    QPointer<QQuickItem> m_contentItem;

    qreal m_padding = 0;

    std::optional<qreal> m_horizontalPadding;
    std::optional<qreal> m_verticalPadding;

    std::optional<qreal> m_leftPadding;
    std::optional<qreal> m_topPadding;
    std::optional<qreal> m_rightPadding;
    std::optional<qreal> m_bottomPadding;
};

void PaddingPrivate::calculateImplicitSize()
{
    qreal impWidth = 0;
    qreal impHeight = 0;

    if (m_contentItem) {
        impWidth += m_contentItem->implicitWidth();
        impHeight += m_contentItem->implicitHeight();
    }

    impWidth += q->leftPadding() + q->rightPadding();
    impHeight += q->topPadding() + q->bottomPadding();

    q->setImplicitSize(impWidth, impHeight);
}

QMarginsF PaddingPrivate::margins() const
{
    return {q->leftPadding(), q->topPadding(), q->rightPadding(), q->bottomPadding()};
}

void PaddingPrivate::signalPaddings(const QMarginsF &oldPaddings, Paddings which)
{
    if ((which & Left) && !qFuzzyCompare(q->leftPadding(), oldPaddings.left())) {
        Q_EMIT q->leftPaddingChanged();
    }
    if ((which & Top) && !qFuzzyCompare(q->topPadding(), oldPaddings.top())) {
        Q_EMIT q->topPaddingChanged();
    }
    if ((which & Right) && !qFuzzyCompare(q->rightPadding(), oldPaddings.right())) {
        Q_EMIT q->rightPaddingChanged();
    }
    if ((which & Bottom) && !qFuzzyCompare(q->bottomPadding(), oldPaddings.bottom())) {
        Q_EMIT q->bottomPaddingChanged();
    }
    if (!qFuzzyCompare(q->leftPadding() + q->rightPadding(), oldPaddings.left() + oldPaddings.right())) {
        if (which & Horizontal) {
            Q_EMIT q->horizontalPaddingChanged();
        }
        Q_EMIT q->availableWidthChanged();
    }
    if (!qFuzzyCompare(q->topPadding() + q->bottomPadding(), oldPaddings.top() + oldPaddings.bottom())) {
        if (which & Vertical) {
            Q_EMIT q->verticalPaddingChanged();
        }
        Q_EMIT q->availableHeightChanged();
    }
}

Padding::Padding(QQuickItem *parent)
    : QQuickItem(parent)
    , d(std::make_unique<PaddingPrivate>(this))
{
}

Padding::~Padding()
{
    disconnect(d->m_contentItem, nullptr, this, nullptr);
}

void Padding::setContentItem(QQuickItem *item)
{
    if (d->m_contentItem == item) {
        return;
    }

    if (d->m_contentItem) {
        disconnect(d->m_contentItem, nullptr, this, nullptr);
    }

    d->m_contentItem = item;

    if (d->m_contentItem) {
        d->m_contentItem->setParentItem(this);
        connect(d->m_contentItem, &QQuickItem::implicitWidthChanged, this, &Padding::polish);
        connect(d->m_contentItem, &QQuickItem::implicitHeightChanged, this, &Padding::polish);
        connect(d->m_contentItem, &QQuickItem::visibleChanged, this, &Padding::polish);
        connect(d->m_contentItem, &QQuickItem::implicitWidthChanged, this, &Padding::implicitContentWidthChanged);
        connect(d->m_contentItem, &QQuickItem::implicitHeightChanged, this, &Padding::implicitContentHeightChanged);
    }

    polish();

    Q_EMIT contentItemChanged();
    Q_EMIT implicitContentWidthChanged();
    Q_EMIT implicitContentWidthChanged();
}

QQuickItem *Padding::contentItem()
{
    return d->m_contentItem;
}

void Padding::setPadding(qreal padding)
{
    if (qFuzzyCompare(padding, d->m_padding)) {
        return;
    }

    const QMarginsF oldPadding = d->margins();
    d->m_padding = padding;

    Q_EMIT paddingChanged();

    d->signalPaddings(oldPadding, PaddingPrivate::All);

    polish();
}

void Padding::resetPadding()
{
    if (qFuzzyCompare(d->m_padding, 0)) {
        return;
    }

    const QMarginsF oldPadding = d->margins();
    d->m_padding = 0;

    Q_EMIT paddingChanged();

    d->signalPaddings(oldPadding, PaddingPrivate::All);

    polish();
}

qreal Padding::padding() const
{
    return d->m_padding;
}

void Padding::setHorizontalPadding(qreal padding)
{
    if (qFuzzyCompare(padding, horizontalPadding()) && d->m_horizontalPadding.has_value()) {
        return;
    }

    const QMarginsF oldPadding = d->margins();
    d->m_horizontalPadding = padding;

    d->signalPaddings(oldPadding, PaddingPrivate::Horizontal);

    polish();
}

void Padding::resetHorizontalPadding()
{
    if (qFuzzyCompare(horizontalPadding(), 0.0) && d->m_horizontalPadding.has_value()) {
        return;
    }

    const QMarginsF oldPadding = d->margins();
    d->m_horizontalPadding.reset();

    d->signalPaddings(oldPadding, PaddingPrivate::Horizontal);

    polish();
}

qreal Padding::horizontalPadding() const
{
    return d->m_horizontalPadding.value_or(d->m_padding);
}

void Padding::setVerticalPadding(qreal padding)
{
    if (qFuzzyCompare(padding, verticalPadding()) && d->m_verticalPadding.has_value()) {
        return;
    }

    const QMarginsF oldPadding = d->margins();
    d->m_verticalPadding = padding;

    d->signalPaddings(oldPadding, PaddingPrivate::Vertical);

    polish();
}

void Padding::resetVerticalPadding()
{
    if (qFuzzyCompare(verticalPadding(), 0.0) && d->m_verticalPadding.has_value()) {
        return;
    }

    const QMarginsF oldPadding = d->margins();
    d->m_verticalPadding.reset();

    d->signalPaddings(oldPadding, PaddingPrivate::Vertical);

    polish();
}

qreal Padding::verticalPadding() const
{
    return d->m_verticalPadding.value_or(d->m_padding);
}

void Padding::setLeftPadding(qreal padding)
{
    const qreal oldLeftPadding = leftPadding();
    if (qFuzzyCompare(padding, oldLeftPadding) && d->m_leftPadding.has_value()) {
        return;
    }

    d->m_leftPadding = padding;

    if (!qFuzzyCompare(padding, oldLeftPadding)) {
        Q_EMIT leftPaddingChanged();
        Q_EMIT availableWidthChanged();
    }

    polish();
}

void Padding::resetLeftPadding()
{
    const qreal oldLeftPadding = leftPadding();
    if (qFuzzyCompare(oldLeftPadding, 0.0) && d->m_leftPadding.has_value()) {
        return;
    }

    d->m_leftPadding.reset();

    if (!qFuzzyCompare(oldLeftPadding, 0.0)) {
        Q_EMIT leftPaddingChanged();
        Q_EMIT availableWidthChanged();
    }

    polish();
}

qreal Padding::leftPadding() const
{
    return d->m_leftPadding.value_or(horizontalPadding());
}

void Padding::setTopPadding(qreal padding)
{
    const qreal oldTopPadding = topPadding();
    if (qFuzzyCompare(padding, oldTopPadding) && d->m_topPadding.has_value()) {
        return;
    }

    d->m_topPadding = padding;

    if (!qFuzzyCompare(padding, oldTopPadding)) {
        Q_EMIT topPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

void Padding::resetTopPadding()
{
    const qreal oldTopPadding = topPadding();
    if (qFuzzyCompare(oldTopPadding, 0.0) && d->m_topPadding.has_value()) {
        return;
    }

    d->m_topPadding.reset();

    if (!qFuzzyCompare(oldTopPadding, 0.0)) {
        Q_EMIT topPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

qreal Padding::topPadding() const
{
    return d->m_topPadding.value_or(verticalPadding());
}

void Padding::setRightPadding(qreal padding)
{
    const qreal oldRightPadding = rightPadding();
    if (qFuzzyCompare(padding, oldRightPadding) && d->m_rightPadding.has_value()) {
        return;
    }

    d->m_rightPadding = padding;

    if (!qFuzzyCompare(padding, oldRightPadding)) {
        Q_EMIT rightPaddingChanged();
        Q_EMIT availableWidthChanged();
    }

    polish();
}

void Padding::resetRightPadding()
{
    const qreal oldRightPadding = rightPadding();
    if (qFuzzyCompare(oldRightPadding, 0.0) && d->m_rightPadding.has_value()) {
        return;
    }

    d->m_rightPadding.reset();

    if (!qFuzzyCompare(oldRightPadding, 0.0)) {
        Q_EMIT rightPaddingChanged();
        Q_EMIT availableWidthChanged();
    }

    polish();
}

qreal Padding::rightPadding() const
{
    return d->m_rightPadding.value_or(horizontalPadding());
}

void Padding::setBottomPadding(qreal padding)
{
    const qreal oldBottomPadding = bottomPadding();
    if (qFuzzyCompare(padding, oldBottomPadding) && d->m_bottomPadding.has_value()) {
        return;
    }

    d->m_bottomPadding = padding;

    if (!qFuzzyCompare(padding, oldBottomPadding)) {
        Q_EMIT bottomPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

void Padding::resetBottomPadding()
{
    const qreal oldBottomPadding = bottomPadding();
    if (qFuzzyCompare(oldBottomPadding, 0.0) && d->m_bottomPadding.has_value()) {
        return;
    }

    d->m_bottomPadding.reset();

    if (!qFuzzyCompare(oldBottomPadding, 0.0)) {
        Q_EMIT bottomPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

qreal Padding::bottomPadding() const
{
    return d->m_bottomPadding.value_or(verticalPadding());
}

qreal Padding::availableWidth() const
{
    return width() - leftPadding() - rightPadding();
}

qreal Padding::availableHeight() const
{
    return height() - topPadding() - bottomPadding();
}

qreal Padding::implicitContentWidth() const
{
    if (d->m_contentItem) {
        return d->m_contentItem->implicitWidth();
    } else {
        return 0.0;
    }
}

qreal Padding::implicitContentHeight() const
{
    if (d->m_contentItem) {
        return d->m_contentItem->implicitHeight();
    } else {
        return 0.0;
    }
}

void Padding::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    if (newGeometry != oldGeometry) {
        Q_EMIT availableWidthChanged();
        Q_EMIT availableHeightChanged();
        polish();
    }

    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

void Padding::updatePolish()
{
    d->calculateImplicitSize();
    if (!d->m_contentItem) {
        return;
    }

    d->m_contentItem->setPosition(QPointF(leftPadding(), topPadding()));
    d->m_contentItem->setSize(QSizeF(availableWidth(), availableHeight()));
}

#include "moc_padding.cpp"
