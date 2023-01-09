#include <QDebug>
#include <qglobal.h>
void initQmlResourceKirigamiPlugin()
{
    Q_INIT_RESOURCE(KirigamiPlugin);
    qWarning() << Q_FUNC_INFO;
};