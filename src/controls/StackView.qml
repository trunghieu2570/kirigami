/*
    SPDX-FileCopyrightText: 2022 Noah Davis <noahadvs@gmail.com>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import org.kde.kirigami 2.19 as Kirigami

/**
 * @brief A StackView with convenience properties for customizing animations.
 *
 * This component makes it easier to tweak the animations of a StackView
 * for different situations, including the ability to switch between
 * vertical and horizontal movement animations.
 *
 * The transitions have animations on the x or y properties
 * and animations on the opacity property.
 * The x/y animations go between 0 and horizontalDistance or verticalDistance.
 * The opacity animations go between 0 and 1.
 *
 * The push transitions move items left in horizontal mode when not mirrored by default.
 * The push transitions move items down in vertical mode by default.
 * The pop transitions are the opposite of the push transitions.
 * The replace transitions are identical to the push transitions.
 *
 * See Qt Quick Controls StackView documentation for how to use different transitions with `pop()`, `push()` and `replace()`.
 *
 * @inherit QtQuick.Templates.StackView
 * @since 5.93
 * @since org.kde.kirigami 2.20
 */
T.StackView {
    id: control

    /**
     * This property holds the duration of the animations in milliseconds.
     *
     * The default value is `Kirigami.Units.longDuration`.
     */
    property int duration: Kirigami.Units.longDuration

    /**
     * This property holds the easing type of the animations.
     *
     * The default value is `Easing.OutCubic`.
     */
    property int easingType: Easing.OutCubic

    /**
     * This property holds the orientation of the animations.
     *
     * The default value is `Qt.Horizontal`.
     */
    property int orientation: Qt.Horizontal

    /**
     * This property holds whether or not the orientation is horizontal.
     */
    readonly property bool horizontal: control.orientation === Qt.Horizontal

    /**
     * This property holds whether or not the orientation is vertical.
     */
    readonly property bool vertical: control.orientation === Qt.Vertical

    /**
     * This property holds the distance for horizontal movement animations in logical pixels.
     *
     * The default value reverses the movement when `mirrored` is true.
     * The absolute value is equivalent to `0.5 * width`.
     */
    property real horizontalDistance: (control.mirrored ? -0.5 : 0.5) * control.width

    /**
     * This property holds the distance for vertical movement animations in logical pixels.
     *
     * The default value is equivalent to `0.5 * height`.
     */
    property real verticalDistance: 0.5 * control.height

    // Using NumberAnimation instead of XAnimator/YAnimator because
    // the animators weren't always smooth enough.
    pushEnter: Transition {
        NumberAnimation {
            property: control.vertical ? "y" : "x"
            from: control.vertical ? -control.verticalDistance : control.horizontalDistance
            to: 0
            duration: control.duration
            easing.type: control.easingType
        }
        NumberAnimation {
            property: "opacity"
            from: 0.0; to: 1.0
            duration: control.duration
            easing.type: control.easingType
        }
    }
    pushExit: Transition {
        NumberAnimation {
            property: control.vertical ? "y" : "x"
            from: 0
            to: control.vertical ? control.verticalDistance : -control.horizontalDistance
            duration: control.duration
            easing.type: control.easingType
        }
        NumberAnimation {
            property: "opacity"
            from: 1.0; to: 0.0
            duration: control.duration
            easing.type: control.easingType
        }
    }
    popEnter: Transition {
        NumberAnimation {
            property: control.vertical ? "y" : "x"
            from: control.vertical ? control.verticalDistance : -control.horizontalDistance
            to: 0
            duration: control.duration
            easing.type: control.easingType
        }
        NumberAnimation {
            property: "opacity"
            from: 0.0; to: 1.0
            duration: control.duration
            easing.type: control.easingType
        }
    }
    popExit: Transition {
        NumberAnimation {
            property: control.vertical ? "y" : "x"
            from: 0
            to: control.vertical ? -control.verticalDistance : control.horizontalDistance
            duration: control.duration
            easing.type: control.easingType
        }
        NumberAnimation {
            property: "opacity"
            from: 1.0; to: 0.0
            duration: control.duration
            easing.type: control.easingType
        }
    }
    replaceEnter: Transition {
        NumberAnimation {
            property: control.vertical ? "y" : "x"
            from: control.vertical ? -control.verticalDistance : control.horizontalDistance
            to: 0
            duration: control.duration
            easing.type: control.easingType
        }
        NumberAnimation {
            property: "opacity"
            from: 0.0; to: 1.0
            duration: control.duration
            easing.type: control.easingType
        }
    }
    replaceExit: Transition {
        NumberAnimation {
            property: control.vertical ? "y" : "x"
            from: 0
            to: control.vertical ? control.verticalDistance : -control.horizontalDistance
            duration: control.duration
            easing.type: control.easingType
        }
        NumberAnimation {
            property: "opacity"
            from: 1.0; to: 0.0
            duration: control.duration
            easing.type: control.easingType
        }
    }
}
