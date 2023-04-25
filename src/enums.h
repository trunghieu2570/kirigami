/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef ENUMS_H
#define ENUMS_H

#include <QObject>

/**
 * @brief Types used in kirigami::PageRow and kirigami::Page that indicate how
 * top bar controls should be represented to the user.
 */
class ApplicationHeaderStyle : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief Types that indicate how the global toolbar should be shown to the
     * user.
     */
    enum Status {
        /**
         * @brief Automatically choose other values depending on the device's
         * form factor.
         */
        Auto = 0,

        /**
         * @brief Display the main, left, and right actions horizontally
         * centered at the bottom of the page in a mobile-friendly way.
         */
        Breadcrumb,

        /**
         * @brief Each page will only have its title at the top alongside breadcrumb
         * page actions controls.
         */
        Titles,

        /**
         * @brief Each page will be shown as a tab button inside the tab bar.
         * @deprecated This implementation in Kirigami.PageRow will be removed in
         * KF6 (this enum value might be removed too).
         */
        TabBar,

        /**
         * @brief Each page will show its title at the top together with action buttons and menus
         * that represent global and current pages actions.
         *
         * Kirigami.PageRow does not implement this mode for mobile formfactor devices.
         */
        ToolBar,

        /**
         * @brief Do not display the global toolbar.
         *
         * The global drawer handle will be shown at the bottom left corner of the application
         * alongside breadcrumb controls.
         */
        None,
    };
    Q_ENUM(Status)

    /**
     * @brief Flags for implementations using navigation buttons indicating
     * which buttons to display.
     */
    enum NavigationButton {
        /**
         * @brief Display no navigation buttons.
         */
        NoNavigationButtons = 0,

        /**
         * @brief Display the back navigation button.
         */
        ShowBackButton = 0x1,

        /**
         * @brief Display the forward navigation button.
         */
        ShowForwardButton = 0x2,
    };
    Q_ENUM(NavigationButton)
    Q_DECLARE_FLAGS(NavigationButtons, NavigationButton)
};

/**
 * @brief Types for implementations using messages indicating preference
 * about how to display the message (e.g. color).
 */
class MessageType : public QObject
{
    Q_OBJECT

public:
    enum Type {
        /**
         * @brief Display an informative message to the user.
         *
         * Use this to announce a result or provide commentary.
         */
        Information = 0,

        /**
         * @brief Display a positive message to the user.
         *
         * Use this to announce a successful result
         * or the successful completion of a procedure.
         */
        Positive,

        /**
         * @brief Display a warning message to the user.
         *
         * Use this to provide critical guidance or
         * a warning about something that is not going to work.
         */
        Warning,

        /**
         * @brief Display an error message to the user.
         *
         * Use this to announce something has gone wrong
         * or that input will not be accepted.
         */
        Error,
    };
    Q_ENUM(Type)
};

/**
 * @brief This enum contains hints on how a @link Kirigami.Action Kirigami.Action @endlink should be displayed.
 * @note Implementations may choose to disregard the set hint.
 */
class DisplayHint : public QObject
{
    Q_OBJECT

public:
    enum Hint : uint {
        /**
         * @brief No specific preference on how to display this Action.
         */
        NoPreference = 0,

        /**
         * @brief Only display an icon for this Action.
         */
        IconOnly = 1,

        /**
         * @brief Try to keep the Action visible even with constrained space.
         *
         * Mutually exclusive with AlwaysHide, KeepVisible has priority.
         */
        KeepVisible = 2,

        /**
         * @brief If possible, hide the action in an overflow menu or similar
         * location.
         *
         * Mutually exclusive with KeepVisible, KeepVisible has priority.
         */
        AlwaysHide = 4,

        /**
         * @brief When this action has children, do not display any indicator
         * (like a menu arrow) for this action.
         */
        HideChildIndicator = 8,
    };
    Q_DECLARE_FLAGS(DisplayHints, Hint)
    Q_ENUM(Hint)
    Q_FLAG(DisplayHints)

    // Note: These functions are instance methods because they need to be
    // exposed to QML. Unfortunately static methods are not supported.

    /**
     * @brief A helper function to check if a certain display hint has been set.
     *
     * This function is mostly convenience to enforce certain behaviour of the
     * various display hints, primarily the mutual exclusivity of KeepVisible
     * and AlwaysHide.
     *
     * @param values The display hints to check.
     * @param hint The display hint to check if it is set.
     *
     * @return @c true if the hint was set for this action, @c false if not.
     *
     * @since org.kde.kirigami 2.14
     */
    Q_INVOKABLE bool displayHintSet(DisplayHints values, Hint hint);

    /**
     * @brief Check if a certain display hint has been set on an object.
     *
     * This overloads displayHintSet(DisplayHints, Hint) to accept a QObject
     * instance. This object is checked to see if it has a displayHint property
     * and if so, if that property has a @p hint set.
     *
     * @param object The object to check.
     * @param hint The hint to check for.
     *
     * @return @c false if object is null, object has no displayHint property or
     * the hint was not set. @c true if it has the property and the hint
     * is set.
     */
    Q_INVOKABLE bool displayHintSet(QObject *object, Hint hint);

    /**
     * Static version of \f displayHintSet(DisplayHints, Hint) that can be
     * called from C++ code.
     */
    static bool isDisplayHintSet(DisplayHints values, Hint hint);
};

Q_DECLARE_OPERATORS_FOR_FLAGS(DisplayHint::DisplayHints)

#endif // ENUMS_H
