// SPDX-FileCopyrightText: 2022 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

QQC2.ApplicationWindow {
    width: Kirigami.Units.gridUnit * 40
    height: Kirigami.Units.gridUnit * 25
    Kirigami.FlexColumn {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing * 2
        Kirigami.InlineMessage {
            Layout.topMargin: Kirigami.Units.largeSpacing * 2
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Error
            text: "Error: This operation failed"
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Warning
            text: "This is dangerous"
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Positive
            text: "You got it"
        }

        Kirigami.InlineMessage {
            id: indexingDisabledWarning
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            text: "Do you want to delete the saved index data? %1 of space will be freed, but if indexing is re-enabled later, the entire index will have to be re-created from scratch. This may take some time, depending on how many files you have."
            actions: Kirigami.Action {
                text: "Delete Index Data"
                icon.name: "edit-delete"
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            text: "This will disable file searching in KRunner and launcher menus, and remove extended metadata display from all KDE applications.";
        }
    }
}