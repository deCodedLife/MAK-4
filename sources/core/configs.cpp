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

    /**
     * @brief mainSettings
     */
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

    /**
     * @brief errors
     */
    QJsonObject errors;
    errors["0"] = "Внутренняя ошибка";
    errors["32"] = "Напряжение нагрузки понижено";
    errors["33"] = "Напряжение нагрузки повышено";
    errors["34"] = "Включена термокомпенсация";

    for ( int index = 1; index <= 52; index++ )
        errors[ QString::number( index + 34) ] = "Отключен автомат защиты нагрузки " + QString::number( index );

    errors["87"] = "Авария устройства дискретных вводов (УКДВ-1М)";
    errors["96"] = "Батарея разряжается";
    errors["97"] = "Глубокий разряда батареи";
    errors["98"] = "Батарея в режиме заряда";
    errors["99"] = "Батарея в режиме ускоренного заряды";
    errors["100"] = "Батарея в режиме содержания";
    errors["101"] = "Батарея в режиме выравнивающего заряда";
    errors["102"] = "Идет батарейный тест";

    for ( int index = 1; index <= 4; index++ )
        errors[ QString::number( index + 102) ] = "Отключен аппарат защиты батереи группы " + QString::number( index );

    for ( int index = 1; index <= 4; index++ )
        errors[ QString::number( index + 110) ] = "Авария моноблока группы " + QString::number( index ) + " батареи (с УПКБ-М)";

    errors["119"] = "Ошибка связи с УПКБ (устройство поэлементного контроля батареи)";
    errors["120"] = "Ток заряда меньше 1А";
    errors["121"] = "Ток заряда меньше 2А";
    errors["122"] = "Ток заряда меньше 3А";
    errors["123"] = "Ток заряда меньше 4А";
    errors["124"] = "Ток заряда меньше 5А";
    errors["125"] = "Перегрев батареи";
    errors["126"] = "Идет короткий тест батареи";
    errors["127"] = "Ошибка короткого теста батареи";
    errors["128"] = "Батарейный контактор отключен";
    errors["129"] = "Контактор 1 отключен";
    errors["130"] = "Контактор 2 отключен";

    for ( int index = 1; index <= 180; index++ )
        errors[ QString::number( index + 159) ] = "Авария ВБВ " + QString::number( index );

    errors["340"] = "Нет резерва ВБВ";
    errors["341"] = "Активен режим энергосбережения";
    errors["352"] = "Авария фазы 1";
    errors["353"] = "Авария фазы 2";
    errors["354"] = "Авария фазы 3";
    errors["355"] = "Ошибка контроля сети";
    errors["356"] = "Авария секции грозозащиты";
    errors["384"] = "Температура понижена (с датчика 2)";
    errors["385"] = "Температура повышена (с датчика 2)";
    errors["386"] = "Ошибка контроля температуры";

    for ( int index = 1; index <= 16; index++ )
        errors[ QString::number( index + 415) ] = "Авария сухого контакта " + QString::number( index );

    errors["480"] = "Авария Li-Ion АБ";
    errors["481"] = "Нет связи с БМС";
    errors["512"] = "Контроллер загрузился";
    errors["513"] = "Сохранение настроек";
    errors["514"] = "Установка часов";
    errors["515"] = "Запуск батарейного теста";
    errors["516"] = "Запуск выравнивающего заряда";

    data[ "errors" ] = errors;
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