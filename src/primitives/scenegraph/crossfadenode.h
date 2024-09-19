
#pragma once

#include <QSGGeometry>
#include <QSGGeometryNode>

#include "crossfadematerial.h"

class CrossFadeNode : public QSGGeometryNode
{
public:
    CrossFadeNode();
    ~CrossFadeNode();

    void setRect(const QRectF &rect);

    void setTextures(std::shared_ptr<QSGTexture> texture1, std::shared_ptr<QSGTexture> texture2);

    void setBlendFactor(float factor);

private:
    QSGGeometry m_geometry;
    CrossFadeMaterial *m_material;
};
