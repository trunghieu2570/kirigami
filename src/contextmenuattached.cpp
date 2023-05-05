#include "contextmenuattached.h"

#define pThis (static_cast<ContextMenuAttached *>(prop->object))

ContextMenuAttached::ContextMenuAttached(QObject *parent)
    : QObject(parent)
{
}

QQmlListProperty<QQuickItem> ContextMenuAttached::items()
{
    return QQmlListProperty<QQuickItem>(this, //
                                        nullptr,
                                        appendItem,
                                        itemCount,
                                        itemAt,
                                        clearItems);
}

ContextMenuAttached *ContextMenuAttached::qmlAttachedProperties(QObject *object)
{
    return new ContextMenuAttached(object);
}

void ContextMenuAttached::appendItem(QQmlListProperty<QQuickItem> *prop, QQuickItem *value)
{
    pThis->m_items.push_back(value);
}

int ContextMenuAttached::itemCount(QQmlListProperty<QQuickItem> *prop)
{
    return pThis->m_items.count();
}

QQuickItem *ContextMenuAttached::itemAt(QQmlListProperty<QQuickItem> *prop, int index)
{
    return pThis->m_items[index];
}

void ContextMenuAttached::clearItems(QQmlListProperty<QQuickItem> *prop)
{
    pThis->m_items.clear();
}
