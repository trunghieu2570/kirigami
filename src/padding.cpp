/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "padding.h"

#include <QDebug>
#include <QMarginsF>
#include <qnumeric.h>
#include <qtypes.h>

class PaddingPrivate
{
    Padding *const q;

public:
    enum ValidPaddings { Horizontal = 1 << 0, Vertical = 1 << 1, Left = 1 << 2, Top = 1 << 3, Right = 1 << 4, Bottom = 1 << 5 };

    PaddingPrivate(Padding *qq)
        : q(qq)
    {
    }

    void calculateImplicitSize();
    QMarginsF margins() const;

    QPointer<QQuickItem> m_contentItem;

    qreal m_padding = 0;

    qreal m_horizontalPadding = 0;
    qreal m_verticalPadding = 0;

    qreal m_leftPadding = 0;
    qreal m_topPadding = 0;
    qreal m_rightPadding = 0;
    qreal m_bottomPadding = 0;

    qint8 m_validPaddings = 0;
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

    const QMarginsF oldMargins = d->margins();
    d->m_padding = padding;
    const QMarginsF newMargins = d->margins();

    Q_EMIT paddingChanged();

    if (!qFuzzyCompare(newMargins.left(), oldMargins.left())) {
        Q_EMIT leftPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.top(), oldMargins.top())) {
        Q_EMIT topPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.right(), oldMargins.right())) {
        Q_EMIT rightPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.bottom(), oldMargins.bottom())) {
        Q_EMIT bottomPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.left() + newMargins.right(), oldMargins.left() + oldMargins.right())) {
        Q_EMIT horizontalPaddingChanged();
        Q_EMIT availableWidthChanged();
    }
    if (!qFuzzyCompare(newMargins.top() + newMargins.bottom(), oldMargins.top() + oldMargins.bottom())) {
        Q_EMIT verticalPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

void Padding::resetPadding()
{
    if (qFuzzyCompare(d->m_padding, 0)) {
        return;
    }

    const QMarginsF oldMargins = d->margins();
    d->m_padding = 0;
    const QMarginsF newMargins = d->margins();

    Q_EMIT paddingChanged();

    if (!qFuzzyCompare(newMargins.left(), oldMargins.left())) {
        Q_EMIT leftPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.top(), oldMargins.top())) {
        Q_EMIT topPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.right(), oldMargins.right())) {
        Q_EMIT rightPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.bottom(), oldMargins.bottom())) {
        Q_EMIT bottomPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.left() + newMargins.right(), oldMargins.left() + oldMargins.right())) {
        Q_EMIT horizontalPaddingChanged();
        Q_EMIT availableWidthChanged();
    }
    if (!qFuzzyCompare(newMargins.top() + newMargins.bottom(), oldMargins.top() + oldMargins.bottom())) {
        Q_EMIT verticalPaddingChanged();
        Q_EMIT availableHeightChanged();
    }
}

qreal Padding::padding() const
{
    return d->m_padding;
}

void Padding::setHorizontalPadding(qreal padding)
{
    if (qFuzzyCompare(padding, horizontalPadding()) && (d->m_validPaddings & PaddingPrivate::Horizontal)) {
        return;
    }

    const QMarginsF oldMargins = d->margins();
    d->m_horizontalPadding = padding;
    d->m_validPaddings |= PaddingPrivate::Horizontal;
    const QMarginsF newMargins = d->margins();

    if (!qFuzzyCompare(newMargins.left(), oldMargins.left())) {
        Q_EMIT leftPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.right(), oldMargins.right())) {
        Q_EMIT rightPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.left() + newMargins.right(), oldMargins.left() + oldMargins.right())) {
        Q_EMIT horizontalPaddingChanged();
        Q_EMIT availableWidthChanged();
    }

    polish();
}

void Padding::resetHorizontalPadding()
{
    if (qFuzzyCompare(horizontalPadding(), 0.0) && (d->m_validPaddings & PaddingPrivate::Horizontal)) {
        return;
    }

    const QMarginsF oldMargins = d->margins();
    d->m_horizontalPadding = 0;
    d->m_validPaddings &= ~PaddingPrivate::Horizontal;
    const QMarginsF newMargins = d->margins();

    if (!qFuzzyCompare(newMargins.left(), oldMargins.left())) {
        Q_EMIT leftPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.right(), oldMargins.right())) {
        Q_EMIT rightPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.left() + newMargins.right(), oldMargins.left() + oldMargins.right())) {
        Q_EMIT horizontalPaddingChanged();
        Q_EMIT availableWidthChanged();
    }
}

qreal Padding::horizontalPadding() const
{
    if (d->m_validPaddings & PaddingPrivate::Horizontal) {
        return d->m_horizontalPadding;
    } else {
        return d->m_padding;
    }
}

void Padding::setVerticalPadding(qreal padding)
{
    if (qFuzzyCompare(padding, verticalPadding()) && (d->m_validPaddings & PaddingPrivate::Vertical)) {
        return;
    }

    const QMarginsF oldMargins = d->margins();
    d->m_verticalPadding = padding;
    d->m_validPaddings |= PaddingPrivate::Vertical;
    const QMarginsF newMargins = d->margins();

    if (!qFuzzyCompare(newMargins.top(), oldMargins.top())) {
        Q_EMIT topPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.bottom(), oldMargins.bottom())) {
        Q_EMIT bottomPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.top() + newMargins.bottom(), oldMargins.top() + oldMargins.bottom())) {
        Q_EMIT verticalPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

void Padding::resetVerticalPadding()
{
    if (qFuzzyCompare(verticalPadding(), 0.0) && (d->m_validPaddings & PaddingPrivate::Vertical)) {
        return;
    }

    const QMarginsF oldMargins = d->margins();
    d->m_verticalPadding = 0.0;
    d->m_validPaddings &= ~PaddingPrivate::Vertical;
    const QMarginsF newMargins = d->margins();

    if (!qFuzzyCompare(newMargins.top(), oldMargins.top())) {
        Q_EMIT topPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.bottom(), oldMargins.bottom())) {
        Q_EMIT bottomPaddingChanged();
    }
    if (!qFuzzyCompare(newMargins.top() + newMargins.bottom(), oldMargins.top() + oldMargins.bottom())) {
        Q_EMIT verticalPaddingChanged();
        Q_EMIT availableHeightChanged();
    }
}

qreal Padding::verticalPadding() const
{
    if (d->m_validPaddings & PaddingPrivate::Vertical) {
        return d->m_verticalPadding;
    } else {
        return d->m_padding;
    }
}

void Padding::setLeftPadding(qreal padding)
{
    const qreal oldLeftPadding = leftPadding();
    if (qFuzzyCompare(padding, oldLeftPadding) && (d->m_validPaddings & PaddingPrivate::Left)) {
        return;
    }

    d->m_leftPadding = padding;
    d->m_validPaddings |= PaddingPrivate::Left;

    if (!qFuzzyCompare(padding, oldLeftPadding)) {
        Q_EMIT leftPaddingChanged();
        Q_EMIT availableWidthChanged();
    }

    polish();
}

void Padding::resetLeftPadding()
{
    const qreal oldLeftPadding = leftPadding();
    if (qFuzzyCompare(oldLeftPadding, 0.0) && (d->m_validPaddings & PaddingPrivate::Left)) {
        return;
    }

    d->m_leftPadding = 0.0;
    d->m_validPaddings &= ~PaddingPrivate::Left;

    if (!qFuzzyCompare(oldLeftPadding, 0.0)) {
        Q_EMIT leftPaddingChanged();
        Q_EMIT availableWidthChanged();
    }
}

qreal Padding::leftPadding() const
{
    if (d->m_validPaddings & PaddingPrivate::Left) {
        return d->m_leftPadding;
    } else if (d->m_validPaddings & PaddingPrivate::Horizontal) {
        return d->m_horizontalPadding;
    } else {
        return d->m_padding;
    }
}

void Padding::setTopPadding(qreal padding)
{
    const qreal oldTopPadding = topPadding();
    if (qFuzzyCompare(padding, oldTopPadding) && (d->m_validPaddings & PaddingPrivate::Top)) {
        return;
    }

    d->m_topPadding = padding;
    d->m_validPaddings |= PaddingPrivate::Top;

    if (!qFuzzyCompare(padding, oldTopPadding)) {
        Q_EMIT topPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

void Padding::resetTopPadding()
{
    const qreal oldTopPadding = topPadding();
    if (qFuzzyCompare(oldTopPadding, 0.0) && (d->m_validPaddings & PaddingPrivate::Top)) {
        return;
    }

    d->m_topPadding = 0.0;
    d->m_validPaddings &= ~PaddingPrivate::Top;

    if (!qFuzzyCompare(oldTopPadding, 0.0)) {
        Q_EMIT topPaddingChanged();
        Q_EMIT availableHeightChanged();
    }
}

qreal Padding::topPadding() const
{
    if (d->m_validPaddings & PaddingPrivate::Top) {
        return d->m_topPadding;
    } else if (d->m_validPaddings & PaddingPrivate::Vertical) {
        return d->m_verticalPadding;
    } else {
        return d->m_padding;
    }
}

void Padding::setRightPadding(qreal padding)
{
    const qreal oldRightPadding = rightPadding();
    if (qFuzzyCompare(padding, oldRightPadding) && (d->m_validPaddings & PaddingPrivate::Right)) {
        return;
    }

    d->m_rightPadding = padding;
    d->m_validPaddings |= PaddingPrivate::Right;

    if (!qFuzzyCompare(padding, oldRightPadding)) {
        Q_EMIT rightPaddingChanged();
        Q_EMIT availableWidthChanged();
    }

    polish();
}

void Padding::resetRightPadding()
{
    const qreal oldRightPadding = rightPadding();
    if (qFuzzyCompare(oldRightPadding, 0.0) && (d->m_validPaddings & PaddingPrivate::Right)) {
        return;
    }

    d->m_rightPadding = 0.0;
    d->m_validPaddings &= ~PaddingPrivate::Right;

    if (!qFuzzyCompare(oldRightPadding, 0.0)) {
        Q_EMIT rightPaddingChanged();
        Q_EMIT availableWidthChanged();
    }
}

qreal Padding::rightPadding() const
{
    if (d->m_validPaddings & PaddingPrivate::Right) {
        return d->m_rightPadding;
    } else if (d->m_validPaddings & PaddingPrivate::Horizontal) {
        return d->m_horizontalPadding;
    } else {
        return d->m_padding;
    }
}

void Padding::setBottomPadding(qreal padding)
{
    const qreal oldBottomPadding = bottomPadding();
    if (qFuzzyCompare(padding, oldBottomPadding) && (d->m_validPaddings & PaddingPrivate::Bottom)) {
        return;
    }

    d->m_bottomPadding = padding;
    d->m_validPaddings |= PaddingPrivate::Bottom;

    if (!qFuzzyCompare(padding, oldBottomPadding)) {
        Q_EMIT bottomPaddingChanged();
        Q_EMIT availableHeightChanged();
    }

    polish();
}

void Padding::resetBottomPadding()
{
    const qreal oldBottomPadding = bottomPadding();
    if (qFuzzyCompare(oldBottomPadding, 0.0) && (d->m_validPaddings & PaddingPrivate::Bottom)) {
        return;
    }

    d->m_bottomPadding = 0.0;
    d->m_validPaddings &= ~PaddingPrivate::Bottom;

    if (!qFuzzyCompare(oldBottomPadding, 0.0)) {
        Q_EMIT bottomPaddingChanged();
        Q_EMIT availableHeightChanged();
    }
}

qreal Padding::bottomPadding() const
{
    if (d->m_validPaddings & PaddingPrivate::Bottom) {
        return d->m_bottomPadding;
    } else if (d->m_validPaddings & PaddingPrivate::Vertical) {
        return d->m_verticalPadding;
    } else {
        return d->m_padding;
    }
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
