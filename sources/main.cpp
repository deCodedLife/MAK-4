#include <QString>
#include <QApplication>
#include <QQmlApplicationEngine>

#include <configs.h>

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <string.h>

#define HOST "udp:185.51.21.124:16190"
#define USER "user000001"
#define AUTH_PASSWORD "0000000001"
#define PRIV_PASSWORD "0000000011"

#include <mibparser.h>

#include <SNMPpp/SNMPpp.hpp>
#include <SNMPpp/Session.hpp>
#include <SNMPpp/Get.hpp>
#include <iomanip>

typedef void * SessionHandle;

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

    MibParser parser;
    SNMPpp::SessionHandle sessionHandle = NULL;

    try
    {
        SNMPpp::openSessionV3( sessionHandle, "udp:185.51.21.124:16190", "user000001", "0000000001", "0000000011", "authPriv", "MD5", "AES", 3, 1000000 );

        SNMPpp::PDU pdu( SNMPpp::PDU::kGet );
        pdu.addNullVar( ".1.3.6.1.4.1.36032.1.10.11.1.0" );

        pdu = SNMPpp::get( sessionHandle, pdu );

        qDebug() << pdu.varlist().asString();

        pdu.free();

        SNMPpp::closeSession( sessionHandle );
    }
    catch ( const std::exception &e )
    {
        qDebug() << e.what();
        assert( sessionHandle == NULL );
    }

    SNMPpp::closeSession( sessionHandle );
    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    return app.exec();
}
