
#include "crossfadenode.h"
#include "crossfadematerial.h"

CrossFadeNode::CrossFadeNode()
    : m_geometry(QSGGeometry::defaultAttributes_TexturedPoint2D(), 4)
{
    setGeometry(&m_geometry);
    m_material = new CrossFadeMaterial();
    setMaterial(m_material);
    setFlag(OwnsMaterial);
}

CrossFadeNode::~CrossFadeNode()
{
    delete m_material;
}

void CrossFadeNode::setRect(const QRectF &rect)
{
    QSGGeometry::updateTexturedRectGeometry(&m_geometry, rect, QRectF(0, 0, 1, 1));
    markDirty(QSGNode::DirtyGeometry);
}

void CrossFadeNode::setTextures(std::shared_ptr<QSGTexture> texture1, std::shared_ptr<QSGTexture> texture2)
{
    m_material->texture1 = texture1;
    m_material->texture2 = texture2;
    markDirty(QSGNode::DirtyMaterial);
}

void CrossFadeNode::setBlendFactor(float factor)
{
    m_material->blendFactor = factor;
    markDirty(QSGNode::DirtyMaterial);
}
