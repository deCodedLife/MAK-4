#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>


#include <QFontDatabase>

#include <configs.h>
#include <ipaddressvalidator.h>
#include <customdoublevalidator.h>
#include <snmpconnection.h>

#include <mibparser.h>

int main( int argc, char *argv[] )
{
    QGuiApplication app( argc, argv );
    QQmlApplicationEngine engine;

    qint32 fontId = QFontDatabase::addApplicationFont( "://fonts/Roboto.ttf" );
    QStringList fontList = QFontDatabase::applicationFontFamilies( fontId );
    QGuiApplication::setFont( QFont( fontList.first() ) );

    QJsonObject config;
    Configs *cfg = new Configs();
    cfg->Read( &config );

    if ( config.isEmpty() )
    {
        config = Configs::Default();
        cfg->write( config );
    }

    SNMPConnection *snmp = new SNMPConnection();
    snmp->SetConfig( cfg );

    QQmlContext *ctx = engine.rootContext();
    ctx->setContextProperty( "ConfigManager", cfg );
    ctx->setContextProperty( "Config", cfg->get() );
    ctx->setContextProperty( "SNMP", snmp );
    ctx->setContextProperty( "MIB", snmp->GetParser() );

    qmlRegisterType<CustomDoubleValidator>( "CustomDoubleValidator", 0, 1, "CustomDoubleValidator" );
    qmlRegisterType<IPAddressValidator>( "IPAddressValidator", 0, 1, "IPAddressValidator" );

    engine.load( QUrl( "qrc:/qml/Main.qml" ) );
    return app.exec();
}
