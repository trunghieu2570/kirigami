// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

#pragma once

#include <QObject>

class QQuickWindow;

class App : public QObject
{
    Q_OBJECT

public:
    /// Save current window geometry
    Q_INVOKABLE void saveWindowGeometry(QQuickWindow *window, const QString &group = QStringLiteral("main")) const;
};
