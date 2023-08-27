/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef COPYHELPER_H
#define COPYHELPER_H

#include <QObject>

class CopyHelperPrivate : public QObject
{
    Q_OBJECT
public:
    static void copyTextToClipboard(const QString &text);
};

#endif
