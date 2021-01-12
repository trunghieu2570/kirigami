/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "copyinterceptor.h"
#include "copyinterceptor_p.h"

#include <QClipboard>
#include <QGuiApplication>
#include <QKeyEvent>

CopyInterceptor::CopyInterceptor(QObject* parent) : d(new Private(this))
{
    parent->installEventFilter(this);
}
CopyInterceptor::~CopyInterceptor()
{

}

QJSValue CopyInterceptor::Private::generateJSValueFromClipboard()
{
    auto engine = paste.engine();
    auto ret = engine->newObject();

    auto clipboard = QGuiApplication::clipboard();
    auto mimedata = clipboard->mimeData();

    ret.setProperty(QStringLiteral("hasText"), mimedata->hasText());
    if (mimedata->hasText()) {
        ret.setProperty(QStringLiteral("text"), mimedata->text());
    }

    ret.setProperty(QStringLiteral("hasHtml"), mimedata->hasHtml());
    if (mimedata->hasHtml()) {
        ret.setProperty(QStringLiteral("html"), mimedata->html());
    }

    ret.setProperty(QStringLiteral("hasUrls"), mimedata->hasUrls());
    if (mimedata->hasUrls()) {
        ret.setProperty(QStringLiteral("urls"), engine->toScriptValue(QUrl::toStringList(mimedata->urls())));
    }

    ret.setProperty(QStringLiteral("hasImage"), mimedata->hasImage());
    if (mimedata->hasImage()) {
        ret.setProperty(QStringLiteral("imageData"), engine->toScriptValue(mimedata->imageData()));
    }

    ret.setProperty(QStringLiteral("hasColor"), mimedata->hasColor());
    if (mimedata->hasColor()) {
        ret.setProperty(QStringLiteral("colorData"), engine->toScriptValue(mimedata->colorData()));
    }

    return ret;
}

QJSValue CopyInterceptor::copy()
{
    return d->copy;
}
QJSValue CopyInterceptor::paste()
{
    return d->paste;
}

void CopyInterceptor::setCopy(QJSValue val)
{
    d->copy = val;
}
void CopyInterceptor::setPaste(QJSValue val)
{
    d->paste = val;
}

bool CopyInterceptor::eventFilter(QObject *object, QEvent *event)
{
    Q_UNUSED(object)

    if (auto ev = dynamic_cast<QKeyEvent*>(event)) {
        if (ev->isAutoRepeat() || ev->type() != QEvent::ShortcutOverride)
            return false;

        if (ev == QKeySequence::Copy) {
            if (!d->copy.isUndefined() && !d->copy.isNull()) {
                auto ret = d->copy.call();
                if (!ret.isUndefined() && !ret.isNull() && ret.isBool()) {
                    return ret.toBool();
                }
            }
        } else if (ev == QKeySequence::Paste) {
            if (!d->paste.isUndefined() && !d->paste.isNull()) {
                auto ret = d->paste.call({d->generateJSValueFromClipboard()});
                if (!ret.isUndefined() && !ret.isNull() && ret.isBool()) {
                    return ret.toBool();
                }
            }
        }
    }
    return false;
}

CopyInterceptor *CopyInterceptor::qmlAttachedProperties(QObject* on)
{
    return new CopyInterceptor(on);
}
