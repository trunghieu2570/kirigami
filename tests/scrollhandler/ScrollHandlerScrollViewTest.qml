/* SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

T.ApplicationWindow {
    id: root
    width: 600 + scrollView.leftPadding + scrollView.rightPadding
    height: 600 + scrollView.topPadding + scrollView.bottomPadding
    color: palette.base
    ScrollView {
        id: scrollView
        anchors.fill: parent
        Grid {
            id: grid
            columns: Math.sqrt(visibleChildren.length)
            Repeater {
                model: 500
                delegate: Rectangle {
                    implicitHeight: 60
                    implicitWidth: 60
                    gradient: Gradient {
                        orientation: index % 2 ? Gradient.Vertical : Gradient.Horizontal
                        GradientStop { position: 0; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                        GradientStop { position: 1; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                    }
                }
            }
            QQC2.Button {
                id: enableSliderButton
                width: 60
                height: 60
                contentItem: QQC2.Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "Enable Slider"
                    wrapMode: Text.Wrap
                }
                checked: true
            }
            QQC2.Slider {
                enabled: enableSliderButton.checked
                wheelEnabled: true
                verticalPadding: (60 - implicitHandleHeight)/2
                width: 60
                height: 60
            }
            Repeater {
                model: 500
                delegate: Rectangle {
                    implicitHeight: 60
                    implicitWidth: 60
                    gradient: Gradient {
                        orientation: index % 2 ? Gradient.Vertical : Gradient.Horizontal
                        GradientStop { position: 0; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                        GradientStop { position: 1; color: Qt.rgba(Math.random(),Math.random(),Math.random(),1) }
                    }
                }
            }
        }
    }
}
