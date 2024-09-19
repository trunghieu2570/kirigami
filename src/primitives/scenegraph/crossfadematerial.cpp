
#include "crossfadematerial.h"

CrossFadeMaterial::CrossFadeMaterial()
    : QSGMaterial()
{
}

CrossFadeMaterial::~CrossFadeMaterial()
{
}

QSGMaterialType *CrossFadeMaterial::type() const
{
    static QSGMaterialType type;
    return &type;
}

QSGMaterialShader *CrossFadeMaterial::createShader(QSGRendererInterface::RenderMode) const
{
    return new CrossFadeShader();
}

int CrossFadeMaterial::compare(const QSGMaterial *other) const
{
    const CrossFadeMaterial *o = static_cast<const CrossFadeMaterial *>(other);
    if (o == this) {
        return 0;
    }
    return QSGMaterial::compare(other);
}

CrossFadeShader::CrossFadeShader()
{
    const auto shaderRoot = QStringLiteral(":/qt/qml/org/kde/kirigami/primitives/shaders/");

    setShaderFileName(VertexStage, shaderRoot + QStringLiteral("crossfade.vert.qsb"));
    setShaderFileName(FragmentStage, shaderRoot + QStringLiteral("crossfade.frag.qsb"));
}

CrossFadeShader::~CrossFadeShader()
{
}

bool CrossFadeShader::updateUniformData(RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial)
{
    bool changed = false;
    QByteArray *buf = state.uniformData();
    Q_ASSERT(buf->size() >= 72);

    if (state.isMatrixDirty()) {
        const QMatrix4x4 m = state.combinedMatrix();
        memcpy(buf->data(), m.constData(), 64);
        changed = true;
    }

    CrossFadeMaterial *mat = static_cast<CrossFadeMaterial *>(newMaterial);
    CrossFadeMaterial *oldMat = static_cast<CrossFadeMaterial *>(oldMaterial);

    if (!oldMat || mat->blendFactor != oldMat->blendFactor) {
        float blend = mat->blendFactor;
        memcpy(buf->data() + 64, &blend, 4);
        changed = true;
    }

    return changed;
}

void CrossFadeShader::updateSampledImage(RenderState &state, int binding, QSGTexture **texture, QSGMaterial *newMaterial, QSGMaterial *)
{
    CrossFadeMaterial *mat = static_cast<CrossFadeMaterial *>(newMaterial);
    if (binding == 1) {
        *texture = mat->texture1.get();
    } else if (binding == 2) {
        *texture = mat->texture2.get();
    }
}
