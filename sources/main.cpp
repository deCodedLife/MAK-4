#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>

#include <configs.h>

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

    QQmlContext *ctx = engine.rootContext();
    ctx->setContextProperty( "Config", cfg );


    engine.load( QUrl( "qrc:/qml/Main.qml" ) );
    return app.exec();
}
