#ifndef QGEOSERVICEPROVIDERAMAP_H
#define QGEOSERVICEPROVIDERAMAP_H

#include <QtCore/QObject>
#include <QtLocation/QGeoServiceProviderFactory>

    //定义继承 QObject 和 接口的插件
class QGeoServiceProviderFactoryAmap: public QObject, public QGeoServiceProviderFactory
{
    Q_OBJECT

    //Q_INTERFACES 声明使用的接口类型
    Q_INTERFACES(QGeoServiceProviderFactory)

    //Q_PLUGIN_METADATA 宏导出元信息
    Q_PLUGIN_METADATA(IID "org.qt-project.qt.geoservice.serviceproviderfactory/5.0"
                      FILE "amap_plugin.json")

public:
    QGeoCodingManagerEngine *createGeocodingManagerEngine(const QVariantMap &parameters,
                                                          QGeoServiceProvider::Error *error,
                                                          QString *errorString) const;
    QGeoRoutingManagerEngine *createRoutingManagerEngine(const QVariantMap &parameters,
                                                         QGeoServiceProvider::Error *error,
                                                         QString *errorString) const;
    QPlaceManagerEngine *createPlaceManagerEngine(const QVariantMap &parameters,
                                                  QGeoServiceProvider::Error *error,
                                                  QString *errorString) const;
    QGeoMappingManagerEngine *createMappingManagerEngine(const QVariantMap &parameters,
                                                         QGeoServiceProvider::Error *error,
                                                         QString *errorString) const;

};

#endif
