#include "configs.h"

Configs::Configs( QString fileName, QObject *parent )
    : TObject(parent),
    m_fileName( fileName )
{
    m_sender = "CONFIGS";
    connect( this, &Configs::error_occured, this, &Configs::closeFile );
}

Configs::~Configs()
{
    closeFile();
}

QJsonObject Configs::get()
{
    return config;
}

void Configs::Read( QJsonObject *configs )
{
    m_file = new QFile( m_fileName );

    if ( !m_file->exists() )
    {
        // Check if file exists
        emit error_occured( Callback::New( "Файл [ " + m_fileName + " ] Не найден", Callback::Error ) );
        return;
    }

    if ( !m_file->open( QIODevice::ReadOnly ) )
    {
        // Open file for reading
        emit error_occured( Callback::New( "Не удалось открыть файл: " + m_file->errorString(), Callback::Error ) );
        return;
    }

    // Reading file
    QByteArray contentHexed = m_file->readAll();
    QByteArray decodedContent = QByteArray::fromHex( contentHexed );

    if ( !isValid( QJsonDocument::fromJson( decodedContent ).object() ) )
    {
        return;
    }

    *configs = QJsonDocument::fromJson( decodedContent ).object();
    config = *configs;

    m_file->close();
}

void Configs::write( QJsonObject configs )
{
    m_file = new QFile( m_fileName );

    if ( !m_file->open( QIODevice::WriteOnly ) )
    {
        // Open file for writing
        emit error_occured( Callback::New( "Не удалось открыть файл: " + m_file->errorString(), Callback::Error ) );
        return;
    }

    if ( !isValid( configs ) )
    {
        // Validate configs
        return;
    }

    // Convert json to hexed string
    QByteArray configsHexed = QJsonDocument( configs )
                                  .toJson( QJsonDocument::Compact )
                                  .toHex();

    config = configs;
    emit updated( configs );

    // Write configuration
    m_file->write( configsHexed );
    m_file->close();
}

QJsonObject Configs::Default()
{
    QJsonObject data;
    data[ "snmpVersion" ] = SNMP_VERSION;
    data[ "host" ] = HOST;
    data[ "user" ] = USER;
    data[ "authMethod" ] = AUTH_METHOD;
    data[ "authProtocol" ] = AUTH_PROTOCOL;
    data[ "privProtocol" ] = PRIV_PROTOCOL;
    data[ "authPassword" ] = AUTH_PASSWORD;
    data[ "privPassword" ] = PRIV_PASSWORD;

    data[ "v2_read" ] = V2_READ;
    data[ "v2_write" ] = V2_WRITE;

    data[ "updateDelay" ] = UPDATE_DELAY;
    return data;
}


bool Configs::isValid( QJsonObject configs )
{
    return true;
}


void Configs::closeFile()
{
    m_file->close();
}
