/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QColor>
#include <QJSValue>
#include <QObject>
#include <QQuickItem>

/**
 * Utilities for processing items to obtain colors and information useful for
 * UIs that need to adjust to variable elements.
 */
class ColorUtils : public QObject
{
    Q_OBJECT
public:
    /**
     * @brief Describes the contrast of an item.
     */
    enum Brightness {
        /**
         * @brief The item is dark and requires a light foreground color to achieve readable contrast.
         */
        Dark,

        /**
         * @brief The item is light and requires a dark foreground color to achieve readable contrast.
         */
        Light,
    };
    Q_ENUM(Brightness)

    explicit ColorUtils(QObject *parent = nullptr);

    /**
     * @brief This method returns whether a color is light or dark.
     *
     * Example usage:
     * @code{.qml}
     * import QtQuick 2.0
     * import org.kde.kirigami 2.12 as Kirigami
     *
     * Kirigami.Heading {
     *     text: {
     *         if (Kirigami.ColorUtils.brightnessForColor("pink") == Kirigami.ColorUtils.Light) {
     *             return "The color is light"
     *         } else {
     *             return "The color is dark"
     *         }
     *     }
     * }
     * @endcode
     *
     * @since KDE Frameworks 5.69
     * @since org.kde.kirigami 2.12
     */
    Q_INVOKABLE ColorUtils::Brightness brightnessForColor(const QColor &color);

    /**
     * @brief This method returns the color's estimated brightness.
     *
     * Similar to brightnessForColor but returns a 0 to 1 value for an
     * estimate of the equivalent gray light value (luma).
     * 0 as full black, 1 as full white and 0.5 equivalent to a 50% gray.
     *
     * @since KDE Frameworks 5.81
     * @since org.kde.kirigami 2.16
     */
    Q_INVOKABLE qreal grayForColor(const QColor &color);

    /**
     * @brief This method returns the result of overlaying the foreground color
     * on the background color.
     *
     * @param foreground The color to overlay on the background.
     * @param background The color to overlay the foreground on.
     *
     * Example usage:
     * @code{.qml}
     * import QtQuick 2.0
     * import org.kde.kirigami 2.12 as Kirigami
     *
     * Rectangle {
     *     color: Kirigami.ColorUtils.alphaBlend(Qt.rgba(0, 0, 0, 0.5), Qt.rgba(1, 1, 1, 1))
     * }
     * @endcode
     *
     * @since KDE Frameworks 5.69
     * @since org.kde.kirigami 2.12
     */
    Q_INVOKABLE QColor alphaBlend(const QColor &foreground, const QColor &background);

    /**
     * @brief This method returns a linearly interpolated color between color
     * one and color two.
     *
     * @param one The color to linearly interpolate from.
     * @param two The color to linearly interpolate to.
     * @param balance The balance between the two colors. 0.0 will return the
     * first color, 1.0 will return the second color. Values beyond these bounds
     * are valid, and will result in extrapolation.
     *
     * Example usage:
     * @code{.qml}
     * import QtQuick 2.0
     * import org.kde.kirigami 2.12 as Kirigami
     *
     * Rectangle {
     *     color: Kirigami.ColorUtils.linearInterpolation("black", "white", 0.5)
     * }
     * @endcode
     *
     * @since KDE Frameworks 5.69
     * @since org.kde.kirigami 2.12
     */
    Q_INVOKABLE QColor linearInterpolation(const QColor &one, const QColor &two, double balance);

    /**
     * @brief Increases or decreases either RGB or HSL properties of the color
     * by fixed amounts.
     *
     * @param color The color to adjust.
     * @param adjustments The adjustments to apply to the color.
     *
     * @note `value` and `lightness` are aliases for the same value.
     *
     * @code{.js}
     * {
     *     red: real, // Range: -255 to 255
     *     green: real, // Range: -255 to 255
     *     blue: real, // Range: -255 to 255
     *     hue: real, // Range: -360 to 360
     *     saturation: real, // Range: -255 to 255
     *     value: real, // Range: -255 to 255
     *     lightness: real, // Range: -255 to 255
     *     alpha: real // Range: -255 to 255
     * }
     * @endcode
     *
     * @since KDE Frameworks 5.69
     * @since org.kde.kirigami 2.12
     */
    Q_INVOKABLE QColor adjustColor(const QColor &color, const QJSValue &adjustments);

    /**
     * @brief Smoothly scales colors by changing either RGB or HSL properties of
     * the color.
     *
     * @param color The color to adjust.
     * @param adjustments The adjustments to apply to the color. Each value must
     * be between `-100.0` and `100.0`. This indicates how far the property
     * should be scaled from its original to the maximum if positive or to the
     * minimum if negative.
     *
     * @note `value` and `lightness` are aliases for the same value.
     *
     * @code{.js}
     * {
     *     red: real,
     *     green: real,
     *     blue: real,
     *     saturation: real,
     *     lightness: real,
     *     value: real,
     *     alpha: real
     * }
     * @endcode
     *
     * @since KDE Frameworks 5.69
     * @since org.kde.kirigami 2.12
     */
    Q_INVOKABLE QColor scaleColor(const QColor &color, const QJSValue &adjustments);

    /**
     * @brief Tint a color using a separate alpha value.
     *
     * This does the same as Qt.tint() except that rather than using the tint
     * color's alpha value, it uses a separate value that gets multiplied with
     * the tint color's alpha. This avoids needing to create a new color just to
     * adjust an alpha value.
     *
     * @param targetColor The color to tint.
     * @param tintColor The color to tint with.
     * @param alpha The amount of tinting to apply.
     *
     * @returns The tinted color.
     *
     * @see <a href="https://doc.qt.io/qt-5/qml-qtqml-qt.html#tint-method">Qt.tint()</a>
     */
    Q_INVOKABLE QColor tintWithAlpha(const QColor &targetColor, const QColor &tintColor, double alpha);

    /**
     * @brief Returns the CIELAB chroma of the given color.
     *
     * CIELAB chroma may give a better quantification of how vibrant a color is compared to HSV saturation.
     *
     * @see https://en.wikipedia.org/wiki/Colorfulness
     * @see https://en.wikipedia.org/wiki/CIELAB_color_space
     */
    Q_INVOKABLE static qreal chroma(const QColor &color);

    struct XYZColor {
        qreal x = 0;
        qreal y = 0;
        qreal z = 0;
    };

    struct LabColor {
        qreal l = 0;
        qreal a = 0;
        qreal b = 0;
    };

    // Not for QML, returns the comvertion from srgb of a QColor and XYZ colorspace
    static ColorUtils::XYZColor colorToXYZ(const QColor &color);

    // Not for QML, returns the comvertion from srgb of a QColor and Lab colorspace
    static ColorUtils::LabColor colorToLab(const QColor &color);

    static qreal luminance(const QColor &color);
};
