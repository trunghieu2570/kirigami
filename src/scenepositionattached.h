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

/**
 * @brief This attached property contains items window-local x & y coordinates.
 *
 * Note that an Item's X and Y coordinates are relative to its parent, meaning
 * that when a list of Items has the same parent, the top-most Item will have
 * coordinates 0x0.
 *
 * Use this attached property to get the X and Y coordinates of an Item that are
 * relative to their QML scene instead of their parent. This is useful when
 * implementing custom views and animations.
 *
 * Typically the 0x0 coordinate of the QML scene starts at the top left corner
 * of the window, below the titlebar.
 *
 * Example usage:
 * @include scenepositionattached.qml
 *
 * @since org.kde.kirigami 2.3
 */
class ScenePositionAttached : public QObject
{
    Q_OBJECT
    /**
     * The global scene X position
     */
    Q_PROPERTY(int x READ x NOTIFY xChanged)

    /**
     * The global scene Y position
     */
    Q_PROPERTY(int y READ y NOTIFY yChanged)

public:
    explicit ScenePositionAttached(QObject *parent = nullptr);
    ~ScenePositionAttached() override;

    int x() const;
    int y() const;

    // QML attached property
    static ScenePositionAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void xChanged();
    void yChanged();

private:
    void connectAncestors(QQuickItem *item);

    QQuickItem *m_item = nullptr;
    QList<QQuickItem *> m_ancestors;
};

QML_DECLARE_TYPEINFO(ScenePositionAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // SCENEPOSITIONATTACHED_H
