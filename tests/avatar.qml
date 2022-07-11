/*
 *  SPDX-FileCopyrightText: 2022 Kai Uwe Broulik <kde@broulik.de>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.13 as Kirigami

RowLayout {
    Kirigami.Avatar {
        name: textField.text
    }

    QQC2.TextField {
        id: textField
        placeholderText: "Name"
    }
}
