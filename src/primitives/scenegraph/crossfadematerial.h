
#pragma once

#include <QSGMaterial>
#include <QSGRendererInterface>
#include <QSGTexture>

class CrossFadeMaterial : public QSGMaterial
{
public:
    CrossFadeMaterial();
    ~CrossFadeMaterial();

    QSGMaterialType *type() const override;
    QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override;
    int compare(const QSGMaterial *other) const override;

    std::shared_ptr<QSGTexture> texture1;
    std::shared_ptr<QSGTexture> texture2;
    float blendFactor = 0.0f;
};

class CrossFadeShader : public QSGMaterialShader
{
public:
    CrossFadeShader();
    ~CrossFadeShader();

    bool updateUniformData(RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;
    void updateSampledImage(RenderState &state, int binding, QSGTexture **texture, QSGMaterial *newMaterial, QSGMaterial *) override;
};
