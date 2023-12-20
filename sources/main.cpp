#include <QApplication>
#include <QQmlApplicationEngine>

#include <configs.h>

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/net-snmp-features.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QJsonObject config;

    Configs cfg = Configs();
    cfg.Read( &config );

    if ( config.isEmpty() )
    {
        config = Configs::Default();
        cfg.Write( config );
    }

    qDebug() << config;

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    return app.exec();
}
