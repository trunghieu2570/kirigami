/*
 *  SPDX-FileCopyrightText: 2021 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2 as Kirigami

Kirigami.ApplicationWindow {
    GridLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit

        rows: 3
        rowSpacing: Kirigami.Units.gridUnit
        columns: 3
        columnSpacing: Kirigami.Units.gridUnit

        // Icon + Label
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            Kirigami.Heading {
                text: "Icon + Label"
                level: 3
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            QQC2.ItemDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle { }
            }
            QQC2.CheckDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle { }
            }
            QQC2.RadioDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle { }
            }
            QQC2.SwitchDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle { }
            }
        }

        // Label + space reserved for icon
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            Kirigami.Heading {
                text: "Icon + Label + space reserved for icon"
                level: 3
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            QQC2.ItemDelegate {
                Layout.fillWidth: true

                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle { }
            }
            QQC2.CheckDelegate {
                Layout.fillWidth: true

                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle { }
            }
            QQC2.RadioDelegate {
                Layout.fillWidth: true

                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle { }
            }
            QQC2.SwitchDelegate {
                Layout.fillWidth: true

                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle { }
            }
        }

        // Icon + Label + leading and trailing items
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            Kirigami.Heading {
                text: "Icon + Label + leading and trailing items"
                level: 3
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            QQC2.ItemDelegate {
                id: plainDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: plainDelegate
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
            QQC2.CheckDelegate {
                id: checkDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: checkDelegate
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
            QQC2.RadioDelegate {
                id: radioDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: radioDelegate
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
            QQC2.SwitchDelegate {
                id: switchDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: switchDelegate
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
        }

        // Icon + Label + subtitle
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            Kirigami.Heading {
                text: "Icon + Label + subtitle"
                level: 3
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            QQC2.ItemDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle {
                    subtitle: "smaller boom"
                }
            }
            QQC2.CheckDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle {
                    subtitle: "smaller boom"
                }
            }
            QQC2.RadioDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle {
                    subtitle: "smaller boom"
                }
            }
            QQC2.SwitchDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"
                checkable: true

                contentItem: Kirigami.IconTitleSubtitle {
                    subtitle: "smaller boom"
                }
            }
        }

        // Icon + Label + space reserved for subtitle
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            Kirigami.Heading {
                text: "Icon + Label + space reserved for subtitle"
                level: 3
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            QQC2.ItemDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle {
                    reserveSpaceForSubtitle: true
                }
            }
            QQC2.CheckDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle {
                    reserveSpaceForSubtitle: true
                }
            }
            QQC2.RadioDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle {
                    reserveSpaceForSubtitle: true
                }
            }
            QQC2.SwitchDelegate {
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: Kirigami.IconTitleSubtitle {
                    reserveSpaceForSubtitle: true
                }
            }
        }

        // Icon + Label + subtitle + leading and trailing items
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            Kirigami.Heading {
                text: "Icon + Label + subtitle + leading/trailing"
                level: 3
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            QQC2.ItemDelegate {
                id: subtitleDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: subtitleDelegate
                        subtitle: "smaller boom"
                    }

                    QQC2.Button {
                        Layout.rightMargin: Kirigami.Units.gridUnit
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
            QQC2.CheckDelegate {
                id: subtitleCheckDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: subtitleCheckDelegate
                        subtitle: "smaller boom"
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
            QQC2.RadioDelegate {
                id: subtitleRadioDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: subtitleRadioDelegate
                        subtitle: "smaller boom"
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
            QQC2.SwitchDelegate {
                id: subtitleSwitchDelegate
                Layout.fillWidth: true

                icon.name: "edit-bomb"
                text: "Boom!"

                contentItem: RowLayout {
                    Rectangle {
                        radius: height
                        Layout.preferredWidth: Kirigami.Units.largeSpacing
                        Layout.preferredHeight: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.neutralTextColor
                    }

                    Kirigami.IconTitleSubtitle {
                        Layout.fillWidth: true
                        control: subtitleSwitchDelegate
                        subtitle: "smaller boom"
                    }

                    QQC2.Button {
                        icon.name: "edit-delete"
                        text: "Defuse the bomb!"
                    }
                }
            }
        }
    }
}

