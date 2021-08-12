/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Controls 2.4 as QQC2
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.19

/**
 * An about page that is ready to integrate in a kirigami app
 *
 * Allows to have a page that will show the copyright notice of the application
 * together with the contributors and some information of which platform it's
 * running on.
 *
 * @since 5.52
 * @since org.kde.kirigami 2.6
 */
ScrollablePage
{
    id: page
    /**
     * This property holds an object with the same shape as KAboutData.
     *
     * @see AboutComponent
     */
    property alias aboutData: aboutItem.aboutData
    property alias getInvolvedUrl: aboutItem.getInvolvedUrl
    default property alias _content: aboutItem._content

    title: qsTr("About %1").arg(page.aboutData.displayName)

    actions.main: Action {
        text: qsTr("Report Bug…")
        icon.name: "tools-report-bug"
        onTriggered: {
            var component = page.aboutData.productName ? page.aboutData.productName.replace(`${page.aboutData.componentName}/`, '') : page.aboutData.componentName

            if (page.aboutData.bugAddress === "submit@bugs.kde.org") {
                Qt.openUrlExternally("https://bugs.kde.org/enter_bug.cgi")
            } else {
                Qt.openUrlExternally(`${page.aboutData.bugAddress}&component=${component}&version=${page.aboutData.version}`)
            }
        }
    }

    AboutItem {
        id: aboutItem

        _usePageStack: applicationWindow().pageStack ? true : false

        anchors.fill: parnet
    }
}
