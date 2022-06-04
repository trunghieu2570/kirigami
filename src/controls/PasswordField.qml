/*
 *  SPDX-FileCopyrightText: 2019 Carl-Lucien Schwan <carl@carlschwan.eu>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami

/**
 * This is a standard password text field.
 *
 * Example usage for the password field component:
 *
 * @code{.qml}
 * import org.kde.kirigami 2.20 as Kirigami
 *
 * Kirigami.PasswordField {
 *     id: passwordField
 *     onAccepted: {
 *         // check if passwordField.text is valid
 *     }
 * }
 * @endcode
 *
 * @since 5.57
 * @inherit org::kde::kirgami::ActionTextField
 * @author Carl Schwan <carl@carlschwan.eu>
 */
Kirigami.ActionTextField
{
    id: root

    /**
     * This property holds whether we show the clear text password.
     *
     * By default, it's false.
     * @since 5.57
     */
    property bool showPassword: false

    echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
    placeholderText: qsTr("Password")
    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
    rightActions: Kirigami.Action {
        icon.name: root.showPassword ? "password-show-off" : "password-show-on"
        onTriggered: root.showPassword = !root.showPassword
    }

    Keys.onPressed: {
        if (event.matches(StandardKey.Undo)) {
            // Disable undo action for security reasons
            // See QTBUG-103934
            event.accepted = true
        }
    }
}
