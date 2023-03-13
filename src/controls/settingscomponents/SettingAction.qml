/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.kirigami 2.11 as Kirigami

/**
 * @brief SettingAction defines a settings page, and is typically used by a CategorizedSettings object.
 * @since 5.86
 * @since org.kde.kirigami 2.18
 * @inherit org::kde::kirigami::PagePoolAction
 */
Kirigami.PagePoolAction {

    /**
     * @brief The name of the action for when it needs to be referenced.
     *
     * Primary use case if for setting a default page in CategorizedSettings.
     */
    required property string actionName

    pageStack: stack
    pagePool: pool
    basePage: stack.initialPage

    checkable: false
}
