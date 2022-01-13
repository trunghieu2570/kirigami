/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *  SPDX-FileCopyrightText: 2022 Carl Schwan <carl@carlschwan.eu>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.12

/**
 * An image with a shadow.
 *
 * This item will render a image, with a shadow below it. The rendering is done
 * using distance fields, which provide greatly improved performance. The shadow is
 * rendered outside of the item's bounds, so the item's width and height are the
 * don't include the shadow.
 *
 * @code
 * import org.kde.kirigami 2.19
 *
 * ShadowedImage {
 *     source: 'qrc:/myKoolGearPicture.png'
 *
 *     radius: 20
 *
 *     shadow.size: 20
 *     shadow.xOffset: 5
 *     shadow.yOffset: 5
 *
 *     border.width: 2
 *     border.color: Kirigami.Theme.textColor
 *
 *     corners.topLeftRadius: 4
 *     corners.topRightRadius: 5
 *     corners.bottomLeftRadius: 2
 *     corners.bottomRightRadius: 10
 * }
 * @endcode
 *
 * @since 5.69 / 2.12
 * @inherit ShadowedTexture
 */
Item {
    /**
     * This property holds the color that will be underneath the image.
     *
     * This will be visible if the image has transparancy.
     *
     * \sa ShadowedRectangle::radius
     */
    property alias color: shadowRectangle.color

    /**
     * This propery holds the corner radius of the image.
     *
     * \sa ShadowedRectangle::radius
     */
    property alias radius: shadowRectangle.radius

    /**
     * This propery holds the shadow's properties of the image.
     *
     * \sa ShadowedRectangle::shadow
     * \sa CornerGroup
     */
    property alias shadow: shadowRectangle.shadow

    /**
     * This propery holds the border's properties of the image.
     *
     * \sa ShadowedRectangle::border
     */
    property alias border: shadowRectangle.border

    /**
     * This propery holds the corner radius properties of the image.
     *
     * \sa ShadowedRectangle::corners
     * \sa CornersGroup
     */
    property alias corners: shadowRectangle.corners

    /**
     * This propery holds the source of the image.
     *
     * \sa QtQuick.Image::source
     */
    property alias source: image.source

    /**
     * This property specifies that images on the local filesystem should be loaded
     * asynchronously in a separate thread. The default value is false,
     * causing the user interface thread to block while the image is
     * loaded. Setting asynchronous to true is useful where maintaining
     * a responsive user interface is more desirable than having images
     * immediately visible.
     *
     * \sa QtQuick.Image::asynchronous
     */
    property alias asynchronous: image.asynchronous

    /**
     * This property defines what happens when the source image has a different
     * size than the item.
     *
     * \sa QtQuick.Image::fillMode
     */
    property alias fillMode: image.fillMode

    /**
     * This property holds the scaled width and height of the full-frame image.
     *
     * \sa QtQuick.Image::sourceSize
     */
    property alias sourceSize: image.sourceSize

    Image {
        id: image
        anchors.fill: parent
        visible: shadowRectangle.softwareRendering
    }

    ShadowedTexture {
        id: shadowRectangle
        anchors.fill: parent

        source: image.status == Image.Ready ? image : null
    }
}
