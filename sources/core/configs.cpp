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
    mainSettings[ "snmpVersion" ] = Field::ToJSON( { FieldCombobox, SNMP_VERSION, "Версия SNMP", { {"snmpV2c", 2}, {"snmpV3", 3 } } } );
    mainSettings[ "host" ] = Field::ToJSON( { FieldInput, HOST, "IP адрес" } );
    mainSettings[ "port" ] = Field::ToJSON( { FieldInput, PORT, "Порт" } );
    mainSettings[ "user" ] = Field::ToJSON( { FieldInput, USER, "Имя" } );
    mainSettings[ "authMethod" ] = Field::ToJSON( { FieldCombobox, AUTH_METHOD, "Уровень", { { "authPriv", 0 }, { "authNoPriv", 0 } } } );
    mainSettings[ "authProtocol" ] = Field::ToJSON( { FieldCombobox, AUTH_PROTOCOL, "Протокол аутентификации", { { "SHA1", 0 }, { "MD5", 0 } } } );
    mainSettings[ "privProtocol" ] = Field::ToJSON( { FieldCombobox, PRIV_PROTOCOL, "Протокол приватноси", { {"DES", 0}, {"AES", 0} } } );
    mainSettings[ "authPassword" ] = Field::ToJSON( { FieldPassword, AUTH_PASSWORD, "Пароль аутентификации" } );
    mainSettings[ "privPassword" ] = Field::ToJSON( { FieldPassword, PRIV_PASSWORD, "Пароль приватности" } );

    mainSettings[ "v2_read" ] = Field::ToJSON( { FieldPassword, V2_READ, "Для чтения" } );
    mainSettings[ "v2_write" ] = Field::ToJSON( { FieldPassword, V2_WRITE, "Для записи" } );

    mainSettings[ "updateDelay" ] = Field::ToJSON( { FieldInput, UPDATE_DELAY, "Период опроса" } );

    /**
     * @brief snmpSettings
     */
    QJsonObject snmpSettings;
    snmpSettings[ "stSNMPVersion" ] = Field::ToJSON( { FieldCombobox, ST_SNMP_VERSION, "Версия протокола Snmp", { { "snmpV2c", 2 }, { "snmpV3", 3 } } } );

    snmpSettings[ "stSNMPAdministratorName" ] = Field::ToJSON( { FieldInput, "Admin", "Имя администратора" } );
    snmpSettings[ "stSNMPAdministratorAuthPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Пароль аутентификации администратора" } );
    snmpSettings[ "stSNMPAdministratorPrivPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Приватный пароль администратора" } );

    snmpSettings[ "stSNMPEngineerName" ] = Field::ToJSON( { FieldInput, "Engineer", "Имя инженера" } );
    snmpSettings[ "stSNMPEngineerAuthPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Пароль аутентификации инженера" } );
    snmpSettings[ "stSNMPEngineerPrivPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Приватный пароль инженера" } );

    snmpSettings[ "stSNMPOperatorName" ] = Field::ToJSON( { FieldInput, "Operator", "Имя оператора" } );
    snmpSettings[ "stSNMPOperatorAuthPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Пароль аутентификации оператора" } );
    snmpSettings[ "stSNMPOperatorPrivPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Приватный пароль оператора" } );

    snmpSettings[ "stSNMPSAuthAlgo" ] = Field::ToJSON( { FieldCombobox, ST_SNMP_AUTH_ALGO, "Способ защиты данных", { { "Нет", 0 }, { "MD5", 1 }, { "SHA1", 2 } } } );
    snmpSettings[ "stSNMPSPrivAlgo" ] = Field::ToJSON( { FieldCombobox, ST_SNMP_PRIV_ALGO, "Способ шифрования", { { "Нет", 0 }, { "DES", 1 }, { "AES128", 2 } } } );

    snmpSettings[ "stSNMPReadComunity" ] = Field::ToJSON( { FieldPassword, "*****", "Коммьюнити для чтения" } );
    snmpSettings[ "stSNMPWriteComunity" ] = Field::ToJSON( { FieldPassword, "*****", "Коммьюнити для записи" } );

    for ( int index = 1; index < 4; index++ )
    {
        QString numIndex = QString::number( index );
        snmpSettings[ "stSNMPTrap" + numIndex + "ServerIP" ] = Field::ToJSON( { FieldInput, "", "IP trap-сервера #" + numIndex } );
    }

    for ( int index = 1; index < 4; index++ )
    {
        QString numIndex = QString::number( index );
        snmpSettings[ "stSNMPTrap" + numIndex + "Enable" ] = Field::ToJSON( { FieldCheckbox, 0, "Ip Trap №" + numIndex + " вкл" } );
    }

    /**
     * @brief power
     */
    QJsonObject powerSettings;
    powerSettings[ "stLowMainsVoltageTherehold" ] = Field::ToJSON( { FieldCounter, 170, "Нижний порог напряжения сети, В", {}, 170, 210 } );
    powerSettings[ "stHightMainsVoltageTherehold" ] = Field::ToJSON( { FieldCounter, 230, "Верхний порог напряжения сети, В", {}, 230, 290 } );

    /**
     * @brief overallSettings
     */
    QJsonObject overallSettings;
    overallSettings[ "psTimeZone" ] = Field::ToJSON( { FieldCounter, 12, "Часовой пояс", {}, -48, 52 } );
    overallSettings[ "psBuzzerEnable" ] = Field::ToJSON( { FieldCheckbox, 0, "Звук включен" } );

    /**
     * @brief networkSettings
     */
    QJsonObject networkSettings;
    networkSettings[ "stIPaddress" ] = Field::ToJSON( { FieldInput, "192.168.000.090", "IP адрес контроллера" } );
    networkSettings[ "stNetworkMask" ] = Field::ToJSON( { FieldInput, "255.255.255.000", "Маска сети" } );
    networkSettings[ "stNetworkGateway" ] = Field::ToJSON( { FieldInput, "192.168.000.001", "Шлюз" } );

    /**
     * @brief blvdSettings
     */
    QJsonObject blvdSettings;
    blvdSettings[ "stBLVDDisconnectedVoltage" ] = Field::ToJSON( { FieldCounter, 5100, "Напряжение отключения батарейного контактора, В:", {}, 0 } );
    blvdSettings[ "stLLVD1DisconnectedVoltage" ] = Field::ToJSON( { FieldCounter, 5100, "Напряжение отключения контактора низкоприоритетной нагрузки 1, В", {}, 0 } );
    blvdSettings[ "stLLVD2DisconnectedVoltage" ] = Field::ToJSON( { FieldCounter, 5100, "Напряжение отключения контактора низкоприоритетной нагрузки 2, В", {}, 0 } );
    blvdSettings[ "stLLVD3DisconnectedVoltage" ] = Field::ToJSON( { FieldCounter, 5100, "Напряжение отключения контактора низкоприоритетной нагрузки 3, В", {}, 0 } );
    blvdSettings[ "stBLVDDisconnectedTime" ] = Field::ToJSON( { FieldCounter, 0, "Время отключения батарейного контактора, мин", {}, 0, 720 } );
    blvdSettings[ "stLLVD1DisconnectedTime" ] = Field::ToJSON( { FieldCounter, 0, "Время отключения контактора низкоприоритетной нагрузки 1, мин", {}, 0, 720 } );
    blvdSettings[ "stLLVD2DisconnectedTime" ] = Field::ToJSON( { FieldCounter, 0, "Время отключения контактора низкоприоритетной нагрузки 2, мин", {}, 0, 720 } );
    blvdSettings[ "stLLVD3DisconnectedTime" ] = Field::ToJSON( { FieldCounter, 0, "Время отключения контактора низкоприоритетной нагрузки 3, мин", {}, 0, 720 } );
    blvdSettings[ "stBLVDDisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения батарейного контактора, А⋅ч:", {}, 0, 99 } );
    blvdSettings[ "stLLVD1DisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения контактора низкоприоритетной нагрузки 1, А⋅ч", {}, 0, 99 } );
    blvdSettings[ "stLLVD2DisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения контактора низкоприоритетной нагрузки 2, А⋅ч", {}, 0, 99 } );
    blvdSettings[ "stLLVD3DisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения контактора низкоприоритетной нагрузки 3, А⋅ч", {}, 0, 99 } );
    blvdSettings[ "stContactorControl" ] = Field::ToJSON( { FieldCheckbox, 0, "Ручное управление" } );


    /**
     * @brief batterySettings
     */
    QJsonObject batterySettings;
    batterySettings[ "stFloatVoltage" ] = Field::ToJSON( { FieldCounter, 6660, "Напряжение содержания, В", {}, 0 } );
    batterySettings[ "stBoostVoltage" ] = Field::ToJSON( { FieldCounter, 6690, "Напряжение ускоренного заряда, В", {}, 0 } );
    batterySettings[ "stBoostEnable" ] = Field::ToJSON( { FieldCheckbox, 0, "Ускоренный заряд" } );
    batterySettings[ "stEqualizeVoltage" ] = Field::ToJSON( { FieldCounter, 6900, "Напряжение выравнивающего заряда, В", {}, 0 } );
    batterySettings[ "stEndTestVoltage" ] = Field::ToJSON( { FieldCounter, 5400, "Напряжение окончания теста, В", {}, 0 } );
    batterySettings[ "stCriticalLowVoltage" ] = Field::ToJSON( { FieldCounter, 5100, "Напряжение глубокого разряда, В", {}, 0 } );
    batterySettings[ "stTermocompensationEnable" ] = Field::ToJSON( { FieldCheckbox, 1, "Термокомпенсация" } );
    batterySettings[ "stTermocompensationCoefficient" ] = Field::ToJSON( { FieldCounter, 35, "Коээфициэнт термокомпенсации, мВ/эл/°C", {}, 1 } );
    batterySettings[ "stChargeCurrentLimit" ] = Field::ToJSON( { FieldCounter, 10, "Ограничение тока заряда, C10", {}, 0 } );
    batterySettings[ "stGroupCapacity" ] = Field::ToJSON( { FieldCounter, 100, "Ёмкость группы, Ач", {}, 0 } );
    batterySettings[ "stEqualizeTime" ] = Field::ToJSON( { FieldCounter, 1, "Время выравнивающего заряда", {}, 1, 24 } );

    /**
     * @brief temperatureSettings
     */
    QJsonObject temperatureSettings;
    temperatureSettings[ "stNumberTemperatureSensors" ] = Field::ToJSON( { FieldCounter, 1, "Количество датчиков температуры", {}, 1, 2 } );
    temperatureSettings[ "stLowTemperatureTherehold" ] = Field::ToJSON( { FieldCounter, 0, "Нижний порог температуры, °С:", {}, 0 } );
    temperatureSettings[ "stHightTemperatureTherehold" ] = Field::ToJSON( { FieldCounter, 0, "Верхний порог температуры, °С", {}, 0 } );
    temperatureSettings[ "stTemperatureGisteresis" ] = Field::ToJSON( { FieldCounter, 0, "Гистерезис, °С", {}, 0 } );

    /**
     * @brief securitySettings
     */
    QJsonObject securitySettings;
    securitySettings[ "stMonitoringPassword" ] = Field::ToJSON( { FieldPassword, "********", "Пароль для просмотра данных по Modbus, USB, RS485" } );
    securitySettings[ "stEnableRemouteChangeSetting" ] = Field::ToJSON( { FieldCheckbox, 1, "Разрешить изменения удалённо" } );
    securitySettings[ "stEnableRemouteUpdateFirmware" ] = Field::ToJSON( { FieldCheckbox, 0, "Разрешить прошивку удалённо" } );


    data[ "main" ] = mainSettings;
    data[ "snmp" ] = snmpSettings;
    data[ "power" ] = powerSettings;
    data[ "overall" ] = overallSettings;
    data[ "network" ] = networkSettings;
    data[ "battery" ] = batterySettings;
    data[ "blvd" ] = blvdSettings;
    data[ "temperature" ] = temperatureSettings;
    data[ "security" ] = securitySettings;

    for ( QString settingsLayer : data.keys() )
    {
        QJsonObject layer = data[ settingsLayer ].toObject();

        for ( QString field : layer.keys() )
        {
            QJsonObject fieldObj = layer[ field ].toObject();
            fieldObj[ "field" ] = field;
            layer[ field ] = fieldObj;
        }

        data[ settingsLayer ] = layer;
    }

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
