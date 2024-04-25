/*
 *  SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include <QUrl>

#include "typeshelper.h"

bool TypesHelper::isUrl(const QVariant &variant)
{
    return variant.metaType() == QMetaType::fromType<QUrl>();
}

#include "moc_typeshelper.cpp"
