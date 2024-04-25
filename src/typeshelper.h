/*
 *  SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef TYPESHELPER_H
#define TYPESHELPER_H

#include <QObject>
#include <QVariant>
#include <qqmlregistration.h>

class TypesHelper : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    // Because every other sane option fails in pure QML.
    // See https://bugreports.qt.io/browse/QTBUG-124662
    Q_INVOKABLE static bool isUrl(const QVariant &variant);
};

#endif
