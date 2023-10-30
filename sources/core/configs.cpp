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

    QJsonObject mainSettings;
    mainSettings[ "snmpVersion" ] = Field::ToJSON( { FieldCombobox, SNMP_VERSION, "Версия SNMP", { "snmpV2c", "snmpV3" } } );
    mainSettings[ "host" ] = Field::ToJSON( { FieldInput, HOST, "IP адрес" } );
    mainSettings[ "port" ] = Field::ToJSON( { FieldInput, PORT, "Порт" } );
    mainSettings[ "user" ] = Field::ToJSON( { FieldInput, USER, "Имя" } );
    mainSettings[ "authMethod" ] = Field::ToJSON( { FieldCombobox, AUTH_METHOD, "Уровень", { "authPriv", "authNoPriv" } } );
    mainSettings[ "authProtocol" ] = Field::ToJSON( { FieldCombobox, AUTH_PROTOCOL, "Протокол аутентификации", { "SHA1", "MD5" } } );
    mainSettings[ "privProtocol" ] = Field::ToJSON( { FieldCombobox, PRIV_PROTOCOL, "Протокол приватноси", { "DES", "AES" } } );
    mainSettings[ "authPassword" ] = Field::ToJSON( { FieldPassword, AUTH_PASSWORD, "Пароль аутентификации" } );
    mainSettings[ "privPassword" ] = Field::ToJSON( { FieldPassword, PRIV_PASSWORD, "Пароль приватности" } );

    mainSettings[ "v2_read" ] = Field::ToJSON( { FieldPassword, V2_READ, "Для чтения" } );
    mainSettings[ "v2_write" ] = Field::ToJSON( { FieldPassword, V2_WRITE, "Для записи" } );

    mainSettings[ "updateDelay" ] = Field::ToJSON( { FieldInput, UPDATE_DELAY, "Период опроса" } );

    for ( QString field : mainSettings.keys() ) {
        QJsonObject fieldObj = mainSettings[ field ].toObject();
        fieldObj[ "field" ] = field;
        mainSettings[ field ] = fieldObj;
    }
    data[ "main" ] = mainSettings;

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
