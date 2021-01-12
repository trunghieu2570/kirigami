/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include "copyinterceptor.h"

class CopyInterceptor::Private
{
public:
    Private(CopyInterceptor* q) : q(q) {}

    CopyInterceptor* q;

    QJSValue copy;
    QJSValue paste;

    QJSValue generateJSValueFromClipboard();
};
