// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

/**
 * A placeholder for loading pages.
 *
 * @code{.qml}
 *     Kirigami.Page {
 *         Kirigami.LoadingPlaceholder {
 *             anchors.centerIn: parent
 *         }
 *     }
 * @endcode
 * @code{.qml}
 *     Kirigami.Page {
 *         Kirigami.LoadingPlaceholder {
 *             anchors.centerIn: parent
 *             determinate: true
 *             progressBar.value: loadingValue
 *         }
 *     }
 * @endcode
 *
 * @inherit org::kde::kirigami::PlaceholderMessage
 */
Kirigami.PlaceholderMessage {
    id: loadingPlaceholder

    /**
     * @brief This property holds whether the loading message shows a
     * determinate progress bar or not.
     *
     * This should be true if you want to display the actual
     * percentage when it's loading.
     *
     * The default value is `false`.
     *
     */
    property bool determinate: false

    /**
     * @brief This property holds an progress bar.
     *
     * This should be used to access the progress bar
     * to change it's value.
     *
     */
    property alias progressBar: _progressBar

    text: qsTr("Loading…")
    explanation: qsTr("Still loading, please wait.")

    QQC2.ProgressBar {
        id: _progressBar
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        indeterminate: !determinate
        from: 0
        to: 100
    }
}
