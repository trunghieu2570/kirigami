/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QtQml>
#include <QObject>

/*
 * A helper utility to add custom copy/paste behaviour to an item.
 *
 * @include CopyInterceptor.qml
 */
class CopyInterceptor : public QObject
{
    Q_OBJECT

    class Private;
    std::unique_ptr<Private> d;

    /*
     * copy: `function(): bool?`
     *
     * This function will be invoked before the attached item is about to receive
     * a copy event, whether from keyboard shortcut or text editing menu on mobile.
     *
     * If this returns `false` or `undefined`, the item will handle the copy
     * as normal.
     *
     * If this returns `true`, the item will not receive the copy event.
     */
    Q_PROPERTY(QJSValue copy READ copy WRITE setCopy)

    /*
     * paste: `function(data: Clipboard): bool?`
     *
     * @code ts
     * interface Clipboard {
     *     hasText: boolean
     *     text?: string
     *
     *     hasHtml: boolean
     *     html?: string
     *
     *     hasUrls: boolean
     *     urls?: string[]
     *
     *     hasImage: boolean
     *     imageData?: variant
     *
     *     hasColor: boolean
     *     colorData?: variant
     * }
     * @endcode
     *
     * This function will be invoked before the attached item is about to receive
     * a paste event, whether from keyboard shortcut or text editing menu on mobile.
     *
     * If this returns `false` or `undefined`, the item will handle the paste
     * as normal.
     *
     * If this returns `true`, the item will not receive the paste event.
     */
    Q_PROPERTY(QJSValue paste READ paste WRITE setPaste)

public:
    explicit CopyInterceptor(QObject* parent = nullptr);
    ~CopyInterceptor();

    QJSValue copy();
    QJSValue paste();
    void setCopy(QJSValue val);
    void setPaste(QJSValue val);

    bool eventFilter(QObject *object, QEvent *event) override;

    static CopyInterceptor *qmlAttachedProperties(QObject* on);
};

QML_DECLARE_TYPEINFO(CopyInterceptor, QML_HAS_ATTACHED_PROPERTIES)
