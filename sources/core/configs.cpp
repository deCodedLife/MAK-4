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

void Configs::saveFile( QString fileName )
{
    m_file = new QFile( fileName );

    if ( !m_file->open( QIODevice::WriteOnly | QIODevice::Truncate ) )
    {
        // Open file for writing
        emit error_occured( Callback::New( "Не удалось открыть файл: " + m_file->errorString(), Callback::Error ) );
        return;
    }

    if ( !isValid( config ) )
    {
        // Validate configs
        return;
    }

    // Convert json to hexed string
    QByteArray configsHexed = QJsonDocument( config )
                                  .toJson( QJsonDocument::Compact )
                                  .toHex();

    // Write configuration
    m_file->write( configsHexed );
    m_file->close();
}

void Configs::openFile( QString fileName )
{
    m_file = new QFile( fileName );

    if ( !m_file->exists() )
    {
        // Check if file exists
        emit error_occured( Callback::New( "Файл [ " + fileName + " ] Не найден", Callback::Error ) );
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

    QJsonParseError *err = nullptr;
    config = QJsonDocument::fromJson( decodedContent, err ).object();

    if ( err != nullptr ) {
        emit error_occured( Callback::New( "Не удалось прочитать файл: " + err->errorString(), Callback::Error ) );
        return;
    }

    emit updated( config );

    m_file->close();
}

QJsonObject Configs::Default()
{
    QJsonObject data;

    /**
     * @brief mainSettings
     */
    QJsonObject mainSettings;
    mainSettings[ "stSNMPVersion" ] = Field::ToJSON( { FieldCombobox, SNMP_VERSION, "Версия SNMP", { { "1", "snmpV2c" }, { "3", "snmpV3" } } } );
    mainSettings[ "host" ] = Field::ToJSON( { FieldAdress, HOST, "IP адрес" } );
    mainSettings[ "port" ] = Field::ToJSON( { FieldInput, PORT, "Порт" } );
    mainSettings[ "stSNMPAdministratorName" ] = Field::ToJSON( { FieldInput, USER, "Имя" } );
    mainSettings[ "authMethod" ] = Field::ToJSON( { FieldCombobox, AUTH_METHOD, "Уровень", {
        { "0", "no auth, no priv" },
        { "1", "auth, no priv" },
        { "2", "auth and priv" } } } );
    mainSettings[ "stSNMPSAuthAlgo" ] = Field::ToJSON( { FieldCombobox, AUTH_PROTOCOL, "Протокол аутентификации", { { "2", "SHA1" }, { "1", "MD5" } } } );
    mainSettings[ "stSNMPSPrivAlgo" ] = Field::ToJSON( { FieldCombobox, PRIV_PROTOCOL, "Протокол приватноси", { { "1", "DES" }, { "2", "AES" } } } );
    mainSettings[ "stSNMPAdministratorAuthPassword" ] = Field::ToJSON( { FieldPassword, AUTH_PASSWORD, "Пароль аутентификации" } );
    mainSettings[ "stSNMPAdministratorPrivPassword" ] = Field::ToJSON( { FieldPassword, PRIV_PASSWORD, "Пароль приватности" } );

    mainSettings[ "v2_read" ] = Field::ToJSON( { FieldPassword, V2_READ, "Для чтения" } );
    mainSettings[ "v2_write" ] = Field::ToJSON( { FieldPassword, V2_WRITE, "Для записи" } );

    mainSettings[ "updateDelay" ] = Field::ToJSON( { FieldCounter, UPDATE_DELAY, "Период опроса" } );

    /**
     * @brief snmpSettings
     */
    QJsonObject snmpSettings;
    snmpSettings[ "stSNMPVersion" ] = Field::ToJSON( { FieldCombobox, SNMP_VERSION, "Версия протокола Snmp", { { "1", "snmpV2c" }, { "3", "snmpV3" } } } );

    snmpSettings[ "stSNMPAdministratorName" ] = Field::ToJSON( { FieldInput, "Admin", "Имя администратора" } );
    snmpSettings[ "stSNMPAdministratorAuthPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Пароль аутентификации администратора" } );
    snmpSettings[ "stSNMPAdministratorPrivPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Приватный пароль администратора" } );

    snmpSettings[ "stSNMPEngineerName" ] = Field::ToJSON( { FieldInput, "Engineer", "Имя инженера" } );
    snmpSettings[ "stSNMPEngineerAuthPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Пароль аутентификации инженера" } );
    snmpSettings[ "stSNMPEngineerPrivPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Приватный пароль инженера" } );

    snmpSettings[ "stSNMPOperatorName" ] = Field::ToJSON( { FieldInput, "Operator", "Имя оператора" } );
    snmpSettings[ "stSNMPOperatorAuthPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Пароль аутентификации оператора" } );
    snmpSettings[ "stSNMPOperatorPrivPassword" ] = Field::ToJSON( { FieldPassword, "*****", "Приватный пароль оператора" } );

    snmpSettings[ "stSNMPSAuthAlgo" ] = Field::ToJSON( { FieldCombobox, AUTH_PROTOCOL, "Протокол аутентификации", { { "0", "Нет" }, { "1", "MD5" }, { "2", "SHA1" } } } );
    snmpSettings[ "stSNMPSPrivAlgo" ] = Field::ToJSON( { FieldCombobox, PRIV_PROTOCOL, "Протокол приватности", { { "0", "Нет" }, { "1", "DES" }, { "2", "AES128" } } } );

    snmpSettings[ "stSNMPReadComunity" ] = Field::ToJSON( { FieldPassword, "*****", "Коммьюнити для чтения" } );
    snmpSettings[ "stSNMPWriteComunity" ] = Field::ToJSON( { FieldPassword, "*****", "Коммьюнити для записи" } );

    for ( int index = 1; index < 4; index++ )
    {
        QString numIndex = QString::number( index );
        snmpSettings[ "stSNMPTrap" + numIndex + "ServerIP" ] = Field::ToJSON( { FieldAdress, "", "IP trap-сервера #" + numIndex } );
    }

    for ( int index = 1; index < 4; index++ )
    {
        QString numIndex = QString::number( index );
        snmpSettings[ "stSNMPTrap" + numIndex + "Enable" ] = Field::ToJSON( { FieldSwitch, 0, "Ip Trap №" + numIndex + " вкл" } );
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
    overallSettings[ "psTimeZone" ] = Field::ToJSON( { FieldDateTime, 0, "Часовой пояс", {} } );
    overallSettings[ "psBuzzerEnable" ] = Field::ToJSON( { FieldSwitch, 0, "Звук включен" } );

    /**
     * @brief networkSettings
     */
    QJsonObject networkSettings;
    networkSettings[ "stIPaddress" ] = Field::ToJSON( { FieldAdress, "192.168.000.090", "IP адрес контроллера" } );
    networkSettings[ "stNetworkMask" ] = Field::ToJSON( { FieldAdress, "255.255.255.000", "Маска сети" } );
    networkSettings[ "stNetworkGateway" ] = Field::ToJSON( { FieldAdress, "192.168.000.001", "Шлюз" } );

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
    blvdSettings[ "stBLVDDisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения батарейного контактора, %:", {}, 0, 99 } );
    blvdSettings[ "stLLVD1DisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения контактора низкоприоритетной нагрузки 1, %", {}, 0, 99 } );
    blvdSettings[ "stLLVD2DisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения контактора низкоприоритетной нагрузки 2, %", {}, 0, 99 } );
    blvdSettings[ "stLLVD3DisconnectedCapacity" ] = Field::ToJSON( { FieldCounter, 0, "Ёмкость отключения контактора низкоприоритетной нагрузки 3, %", {}, 0, 99 } );
    blvdSettings[ "stContactorControl" ] = Field::ToJSON( { FieldSwitch, 0, "Ручное управление" } );


    /**
     * @brief batterySettings
     */
    QJsonObject batterySettings;
    batterySettings[ "stFloatVoltage" ] = Field::ToJSON( { FieldCounter, 6660, "Напряжение содержания, В", {}, 0 } );
    batterySettings[ "stBoostVoltage" ] = Field::ToJSON( { FieldCounter, 6690, "Напряжение ускоренного заряда, В", {}, 0 } );
    batterySettings[ "stBoostEnable" ] = Field::ToJSON( { FieldSwitch, 0, "Ускоренный заряд" } );
    batterySettings[ "stEqualizeVoltage" ] = Field::ToJSON( { FieldCounter, 6900, "Напряжение выравнивающего заряда, В", {}, 0 } );
    batterySettings[ "stCriticalLowVoltage" ] = Field::ToJSON( { FieldCounter, 5100, "Напряжение глубокого разряда, В", {}, 0 } );
    batterySettings[ "stTermocompensationEnable" ] = Field::ToJSON( { FieldSwitch, 1, "Термокомпенсация" } );
    batterySettings[ "stFastChTime" ] = Field::ToJSON( { FieldCounter, 0, "Длительность ускоренного заряда, ч", {}} );
    batterySettings[ "stTermocompensationCoefficient" ] = Field::ToJSON( { FieldCounter, 35, "Коэффициент термокомпенсации, мВ/эл/°C", {}, 1 } );
    batterySettings[ "stChargeCurrentLimit" ] = Field::ToJSON( { FieldCounter, 10, "Ограничение тока заряда, C10", {}, 0 } );
    batterySettings[ "stGroupCapacity" ] = Field::ToJSON( { FieldCounter, 100, "Ёмкость группы, Ач", {}, 0 } );
    batterySettings[ "stEqualizeTime" ] = Field::ToJSON( { FieldCounter, 1, "Длительность выравнивающего заряда, ч", {}, 1, 24 } );


    /**
     * @brief testsAB
     */
    QJsonObject testsAB;
    testsAB[ "stEndTestVoltage" ] = Field::ToJSON( { FieldCounter, 0, "Напряжение окончания теста, В", {}, 0 } );
    testsAB[ "stFixedLoadCurEnable" ] = Field::ToJSON( { FieldSwitch, 0, "Поддерживать заданный ток разряда", {}, 0 } );
    testsAB[ "stFixedLoadCur" ] = Field::ToJSON( { FieldCounter, 5, "Ток разряда, А", {}, 5, 5000 } );
    testsAB[ "stDischCur" ] = Field::ToJSON( { FieldCounter, 0, "Минимально допустимый ток разряда, %С₁₀", {}, 0, 100 } );

    testsAB[ "stPeriodTestEnable" ] = Field::ToJSON( { FieldSwitch, 0, "Запускать переодично", {}, 0 } );
    testsAB[ "stTestPeriod" ] = Field::ToJSON( { FieldCounter, 0, "Период теста, месяцев", {}, 0 } );
    testsAB[ "stTestStartTime" ] = Field::ToJSON( { FieldDateTime, "01012001000000", "Начать первый тест", {}, 0 } );

    testsAB[ "stShortTestVoltage" ] = Field::ToJSON( { FieldCounter, 0, "Напряжение короткого теста, В", {}, 0 } );
    testsAB[ "stShortTestTimer" ] = Field::ToJSON( { FieldCounter, 0, "Длительность короткого теста, мин", {}, 0 } );

    testsAB[ "stShortTestEnable" ] = Field::ToJSON( { FieldSwitch, 0, "Запускать переодично", {}, 0 } );
    testsAB[ "stShortTestPeriod" ] = Field::ToJSON( { FieldCounter, 0, "Период, дни", {}, 0 } );
    testsAB[ "stShortTestStartTime" ] = Field::ToJSON( { FieldDateTime, "01012001000000", "Начать первый тест", {}, 0 } );



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
    securitySettings[ "stMonitoringPassword" ] = Field::ToJSON( { FieldPassword, "********", "Пароль для записи данных по Modbus, USB, RS485" } );
    securitySettings[ "stEnableRemouteChangeSetting" ] = Field::ToJSON( { FieldSwitch, 1, "Разрешить изменения по Modbus и включить Web-интерфейс" } );
    securitySettings[ "stEnableRemouteUpdateFirmware" ] = Field::ToJSON( { FieldSwitch, 0, "Разрешить прошивку удалённо" } );

    /**
     * @brief configurationSettings
     */
    QJsonObject configurationSettings;
    configurationSettings[ "stBatteryGroupsNumber" ] = Field::ToJSON( { FieldCounter, 0, "Количество групп батареи", {}, 0, 4 } );
    configurationSettings[ "stLoadFusesNumber" ] = Field::ToJSON( { FieldCounter, 1, "Количество аппаратов нагрузки", {}, 1, 52 } );
    configurationSettings[ "stLVDsNumber" ] = Field::ToJSON( { FieldCombobox, "Нет", "Kоличество контакторов", { { "0", "Нет" }, { "1", "Только BLVD" }, { "2", "BLVD и LLVD1" }, { "3", "BLVD, LLVD1 и LLVD2" } } } );
    configurationSettings[ "stVBVNumber" ] = Field::ToJSON( { FieldCounter, 1, "Kоличество ВБВ", {}, 1, 180 } );


    /**
     * @brief errors
     */
    QJsonObject errors;
    errors["0"] = "Внутренняя ошибка";
    errors["32"] = "Напряжение нагрузки понижено";
    errors["33"] = "Напряжение нагрузки повышено";
    errors["34"] = "Включена термокомпенсация";

    for ( int index = 1; index <= 52; index++ )
        errors[ QString::number( index + 34) ] = "Отключен аппарат защиты нагрузки " + QString::number( index );

    errors["87"] = "Авария устройства дискретных вводов (УКДВ-1М)";
    errors["96"] = "Батарея разряжается";
    errors["97"] = "Глубокий разряда батареи";
    errors["98"] = "Батарея в режиме заряда";
    errors["99"] = "Батарея в режиме ускоренного заряды";
    errors["100"] = "Батарея в режиме содержания";
    errors["101"] = "Батарея в режиме выравнивающего заряда";
    errors["102"] = "Идет батарейный тест";

    for ( int index = 1; index <= 4; index++ )
        errors[ QString::number( index + 102) ] = "Отключен аппарат защиты батареи группы " + QString::number( index );

    for ( int index = 1; index <= 4; index++ )
        errors[ QString::number( index + 110) ] = "Авария моноблока группы " + QString::number( index ) + " батареи (с УПКБ)";

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
    errors["481"] = "Нет связи с BMS";

    QJsonObject journal;
    journal = errors;
    journal["512"] = "Контроллер загрузился";
    journal["513"] = "Сохранение настроек";
    journal["514"] = "Установка часов";
    journal["515"] = "Запуск батарейного теста";
    journal["516"] = "Запуск выравнивающего заряда";
    journal["517"] = "Запуск короткого теста";


    data[ "main" ] = mainSettings;
    data[ "snmp" ] = snmpSettings;
    data[ "tests" ] = testsAB;
    data[ "power" ] = powerSettings;
    data[ "overall" ] = overallSettings;
    data[ "network" ] = networkSettings;
    data[ "battery" ] = batterySettings;
    data[ "blvd" ] = blvdSettings;
    data[ "temperature" ] = temperatureSettings;
    data[ "security" ] = securitySettings;
    data[ "configuration" ] = configurationSettings;


    /**
     * @brief masks
     */
    QJsonObject masks;

    QJsonArray masksList;
    QStringList preffixes = { "a1", "a2", "r1", "r2", "r3", "r4" };

    for ( QString preffix: preffixes )
    {
        masksList.append( {{ preffix + "InternallError",  Field::ToJSON( { FieldCheckbox, 0, "Внутренняя ошибка" } ) }} );

        masksList.append( {{ preffix + "LoadUnderVoltageAlarm", Field::ToJSON( { FieldCheckbox, 0, "Напряжение нагрузки понижено" } ) }} );
        masksList.append( {{ preffix + "LoadOverVoltageAlarm", Field::ToJSON( { FieldCheckbox, 0, "Напряжение нагрузки повышено" } ) }} );
        masksList.append( {{ preffix + "Termocompensation", Field::ToJSON( { FieldCheckbox, 0, "Включена термокомпенсация" } ) }} );

        for ( int fuseIndex = 1; fuseIndex <= 52; fuseIndex++ )
        {
            masksList.append( {{ preffix + "LoadFuses" + QString::number( fuseIndex ),
                Field::ToJSON( { FieldCheckbox, 0, "Отключен аппарат защиты нагрузки " + QString::number( fuseIndex ) } ) }} );
        }

        masksList.append( {{ preffix + "UKDVAlarm", Field::ToJSON( { FieldCheckbox, 0, "Авария устройства дискретных вводов (УКДВ-1М)" } ) }} );
        masksList.append( {{ preffix + "BatteryDischarge", Field::ToJSON( { FieldCheckbox, 0, "Батарея разряжается" } ) }} );
        masksList.append( {{ preffix + "LowBatteryVoltage", Field::ToJSON( { FieldCheckbox, 0, "Глубокий разряда батареи" } ) }} );
        masksList.append( {{ preffix + "BatteryCharge", Field::ToJSON( { FieldCheckbox, 0, "Батарея в режиме заряда" } ) }} );
        masksList.append( {{ preffix + "BatteryBoost", Field::ToJSON( { FieldCheckbox, 0, "Батарея в режиме ускоренного заряды" } ) }} );
        masksList.append( {{ preffix + "BatteryFloat", Field::ToJSON( { FieldCheckbox, 0, "Батарея в режиме содержания" } ) }} );
        masksList.append( {{ preffix + "BatteryEqualize", Field::ToJSON( { FieldCheckbox, 0, "Батарея в режиме выравнивающего заряда" } ) }} );
        masksList.append( {{ preffix + "BatteryTest", Field::ToJSON( { FieldCheckbox, 0, "Идет батарейный тест" } ) }} );
        masksList.append( {{ preffix + "BatteryFuse1Off", Field::ToJSON( { FieldCheckbox, 0, "Отключен аппарат защиты батареи группы 1" } ) }} );
        masksList.append( {{ preffix + "BatteryFuse2Off", Field::ToJSON( { FieldCheckbox, 0, "Отключен аппарат защиты батареи группы 2" } ) }} );
        masksList.append( {{ preffix + "BatteryFuse3Off", Field::ToJSON( { FieldCheckbox, 0, "Отключен аппарат защиты батареи группы 3" } ) }} );
        masksList.append( {{ preffix + "BatteryFuse4Off", Field::ToJSON( { FieldCheckbox, 0, "Отключен аппарат защиты батареи группы 4" } ) }} );
        masksList.append( {{ preffix + "BatteryBlockElGr1Alarm", Field::ToJSON( { FieldCheckbox, 0, "Авария моноблока группы 1 батареи (с УПКБ)" } ) }} );
        masksList.append( {{ preffix + "BatteryBlockElGr2Alarm", Field::ToJSON( { FieldCheckbox, 0, "Авария моноблока группы 2 батареи (с УПКБ)" } ) }} );
        masksList.append( {{ preffix + "BatteryBlockElGr3Alarm", Field::ToJSON( { FieldCheckbox, 0, "Авария моноблока группы 3 батареи (с УПКБ)" } ) }} );
        masksList.append( {{ preffix + "BatteryBlockElGr4Alarm", Field::ToJSON( { FieldCheckbox, 0, "Авария моноблока группы 4 батареи (с УПКБ)" } ) }} );
        masksList.append( {{ preffix + "UPKBAlarm", Field::ToJSON( { FieldCheckbox, 0, "Ошибка связи с УПКБ (устройство поэлементного контроля батареи)" } ) }} );
        masksList.append( {{ preffix + "ChargeCurrentLess1A", Field::ToJSON( { FieldCheckbox, 0, "Ток заряда меньше 1А" } ) }} );
        masksList.append( {{ preffix + "ChargeCurrentLess2A", Field::ToJSON( { FieldCheckbox, 0, "Ток заряда меньше 2А" } ) }} );
        masksList.append( {{ preffix + "ChargeCurrentLess3A", Field::ToJSON( { FieldCheckbox, 0, "Ток заряда меньше 3А" } ) }} );
        masksList.append( {{ preffix + "ChargeCurrentLess4A", Field::ToJSON( { FieldCheckbox, 0, "Ток заряда меньше 4А" } ) }} );
        masksList.append( {{ preffix + "ChargeCurrentLess5A", Field::ToJSON( { FieldCheckbox, 0, "Ток заряда меньше 5А" } ) }} );
        masksList.append( {{ preffix + "BatteryOverheat", Field::ToJSON( { FieldCheckbox, 0, "Перегрев батареи" } ) }} );
        masksList.append( {{ preffix + "BatteryShortTest", Field::ToJSON( { FieldCheckbox, 0, "Идет короткий тест батареи" } ) }} );
        masksList.append( {{ preffix + "BatteryShortTestFail", Field::ToJSON( { FieldCheckbox, 0, "Ошибка короткого теста батареи" } ) }} );
        masksList.append( {{ preffix + "BLVDoff", Field::ToJSON( { FieldCheckbox, 0, "Батарейный контактор отключен" } ) }} );
        masksList.append( {{ preffix + "LLVD1off", Field::ToJSON( { FieldCheckbox, 0, "Контактор 1 отключен" } ) }} );
        masksList.append( {{ preffix + "LLVD2off", Field::ToJSON( { FieldCheckbox, 0, "LLVD1off" } ) }} );

        for ( int vbvIndex = 1; vbvIndex <= 180; vbvIndex++ )
        {
            masksList.append( {{ preffix + "VBV" + QString::number( vbvIndex ) + "Alarm",
                Field::ToJSON( { FieldCheckbox, 0, "Авария ВБВ  " + QString::number( vbvIndex ) } ) }} );
        }

        masksList.append( {{ preffix + "VBVNoReserve", Field::ToJSON( { FieldCheckbox, 0, "Нет резерва ВБВ" } ) }} );
        masksList.append( {{ preffix + "VBVHighEfficiency", Field::ToJSON( { FieldCheckbox, 0, "Активен режим энергосбережения" } ) }} );
        masksList.append( {{ preffix + "Phase1Alarm", Field::ToJSON( { FieldCheckbox, 0, "Авария фазы 1" } ) }} );
        masksList.append( {{ preffix + "Phase2Alarm", Field::ToJSON( { FieldCheckbox, 0, "Авария фазы 2" } ) }} );
        masksList.append( {{ preffix + "Phase3Alarm", Field::ToJSON( { FieldCheckbox, 0, "Авария фазы 3" } ) }} );
        masksList.append( {{ preffix + "MainsSensorError", Field::ToJSON( { FieldCheckbox, 0, "Ошибка контроля сети" } ) }} );
        masksList.append( {{ preffix + "LightProtectionAlarm", Field::ToJSON( { FieldCheckbox, 0, "Авария секции грозозащиты" } ) }} );
        masksList.append( {{ preffix + "LowTemperature", Field::ToJSON( { FieldCheckbox, 0, "Температура понижена (с датчика 2)" } ) }} );
        masksList.append( {{ preffix + "HighTemperature", Field::ToJSON( { FieldCheckbox, 0, "Температура повышена (с датчика 2)" } ) }} );
        masksList.append( {{ preffix + "TemperatureSensorError", Field::ToJSON( { FieldCheckbox, 0, "Ошибка контроля температуры" } ) }} );

        for ( int contactIndex = 1; contactIndex <= 16; contactIndex++ )
        {
            masksList.append( {{ preffix + "DryContact" + QString::number( contactIndex ),
                Field::ToJSON( { FieldCheckbox, 0, "Авария сухого контакта " + QString::number( contactIndex ) } ) }} );
        }


        masksList.append( {{ preffix + "BatteryLiIonAlarm", Field::ToJSON( { FieldCheckbox, 0, "Авария Li-Ion АБ" } ) }} );
        masksList.append( {{ preffix + "BatteryBMSComFail", Field::ToJSON( { FieldCheckbox, 0, "Нет связи с BMS" } ) }} );

    }



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

    data[ "errors" ] = errors;
    data[ "journal" ] = journal;
    data[ "masks" ] = masksList;

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
