/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#version 440

layout(location = 0) in vec4 vertexPosition;
layout(location = 1) in vec2 vertexTexCoord;

layout(location = 0) out vec2 fragTexCoord;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float blendFactor;
} ubuf;

out gl_PerVertex { vec4 gl_Position; };

void main() {
    fragTexCoord = vertexTexCoord;
    gl_Position = ubuf.qt_Matrix * vertexPosition;
}
