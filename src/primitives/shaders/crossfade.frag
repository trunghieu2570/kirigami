
#version 440

layout(location = 0) in vec2 fragTexCoord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float blendFactor;
} ubuf;

layout(binding = 1) uniform sampler2D texture1;
layout(binding = 2) uniform sampler2D texture2;

void main()
{
    vec4 color1 = texture(texture1, fragTexCoord);
    vec4 color2 = texture(texture2, fragTexCoord);
    fragColor = mix(color1, color2, ubuf.blendFactor) * ubuf.qt_Opacity;
}
