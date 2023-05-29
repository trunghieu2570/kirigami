/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef SCENEPOSITIONATTACHED_H
#define SCENEPOSITIONATTACHED_H

#include <QObject>
#include <QtQml>

class QQuickItem;

// Little helper type that caches, invalidates and updates as needed X and Y values separately.
class PositionCache
{
public:
    explicit PositionCache();

    // Note: compilers should be able to inline those functors at the call site.
    template<typename F>
    qreal getX(F updateX);
    template<typename F>
    qreal getY(F updateY);

    void invalidate();
    void invalidateX();
    void invalidateY();

private:
    qreal x;
    qreal y;
    quint32 xIsValid : 1;
    quint32 yIsValid : 1;
};

/**
 * This attached property contains the information about the scene position of the item:
 * Its global x and y coordinates will update automatically and can be binded
 * @code
 * import org.kde.kirigami 2.5 as Kirigami
 * Text {
 *    text: ScenePosition.x
 * }
 * @endcode
 * @since 2.3
 */
class ScenePositionAttached : public QObject
{
    Q_OBJECT
    /**
     * The global scene X position
     */
    Q_PROPERTY(qreal x READ x NOTIFY xChanged)

    /**
     * The global scene Y position
     */
    Q_PROPERTY(qreal y READ y NOTIFY yChanged)

public:
    explicit ScenePositionAttached(QObject *parent = nullptr);
    ~ScenePositionAttached() override;

    qreal x() const;
    qreal y() const;

    // QML attached property
    static ScenePositionAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void xChanged();
    void yChanged();

private:
    void slotXChanged();
    void slotYChanged();
    void connectAncestors(QQuickItem *item);

    QQuickItem *m_item = nullptr;
    QList<QQuickItem *> m_ancestors;

    mutable PositionCache m_cache;
};

QML_DECLARE_TYPEINFO(ScenePositionAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // SCENEPOSITIONATTACHED_H
