/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#ifndef PADDING_H
#define PADDING_H

#include <QQuickItem>
#include <qtmetamacros.h>

class PaddingPrivate;

class Padding : public QQuickItem
{
    Q_OBJECT

    /**
     * This property holds the visual content Item. It will be resized taking into account all the paddings
     */
    Q_PROPERTY(QQuickItem *contentItem READ contentItem WRITE setContentItem NOTIFY contentItemChanged FINAL)

    Q_PROPERTY(qreal padding READ padding WRITE setPadding NOTIFY paddingChanged RESET resetPadding FINAL)

    Q_PROPERTY(qreal horizontalPadding READ horizontalPadding WRITE setHorizontalPadding NOTIFY horizontalPaddingChanged RESET resetHorizontalPadding FINAL)
    Q_PROPERTY(qreal verticalPadding READ verticalPadding WRITE setVerticalPadding NOTIFY verticalPaddingChanged RESET resetVerticalPadding FINAL)

    Q_PROPERTY(qreal leftPadding READ leftPadding WRITE setLeftPadding NOTIFY leftPaddingChanged RESET resetLeftPadding FINAL)
    Q_PROPERTY(qreal topPadding READ topPadding WRITE setTopPadding NOTIFY topPaddingChanged RESET resetTopPadding FINAL)
    Q_PROPERTY(qreal rightPadding READ rightPadding WRITE setRightPadding NOTIFY rightPaddingChanged RESET resetRightPadding FINAL)
    Q_PROPERTY(qreal bottomPadding READ bottomPadding WRITE setBottomPadding NOTIFY bottomPaddingChanged RESET resetBottomPadding FINAL)

    Q_PROPERTY(qreal availableWidth READ availableWidth NOTIFY availableWidthChanged FINAL)
    Q_PROPERTY(qreal availableHeight READ availableHeight NOTIFY availableHeightChanged FINAL)

    Q_PROPERTY(qreal implicitContentWidth READ implicitContentWidth NOTIFY implicitContentWidthChanged FINAL)
    Q_PROPERTY(qreal implicitContentHeight READ implicitContentHeight NOTIFY implicitContentHeightChanged FINAL)

public:
    Padding(QQuickItem *parent = nullptr);
    ~Padding() override;

    void setContentItem(QQuickItem *item);
    QQuickItem *contentItem();

    void setPadding(qreal padding);
    void resetPadding();
    qreal padding() const;

    void setHorizontalPadding(qreal padding);
    void resetHorizontalPadding();
    qreal horizontalPadding() const;

    void setVerticalPadding(qreal padding);
    void resetVerticalPadding();
    qreal verticalPadding() const;

    void setLeftPadding(qreal padding);
    void resetLeftPadding();
    qreal leftPadding() const;

    void setTopPadding(qreal padding);
    void resetTopPadding();
    qreal topPadding() const;

    void setRightPadding(qreal padding);
    void resetRightPadding();
    qreal rightPadding() const;

    void setBottomPadding(qreal padding);
    void resetBottomPadding();
    qreal bottomPadding() const;

    qreal availableWidth() const;
    qreal availableHeight() const;

    qreal implicitContentWidth() const;
    qreal implicitContentHeight() const;

Q_SIGNALS:
    void contentItemChanged();
    void paddingChanged();
    void horizontalPaddingChanged();
    void verticalPaddingChanged();
    void leftPaddingChanged();
    void topPaddingChanged();
    void rightPaddingChanged();
    void bottomPaddingChanged();
    void availableHeightChanged();
    void availableWidthChanged();
    void implicitContentWidthChanged();
    void implicitContentHeightChanged();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void updatePolish() override;

private:
    friend class PaddingPrivate;
    const std::unique_ptr<PaddingPrivate> d;
};

#endif
