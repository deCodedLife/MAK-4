#include "snmpconnection.h"
#include <iosfwd>

SNMPConnection::SNMPConnection(QObject *parent)
    : TObject{parent},
    readSession(NULL),
    _state( Disconnected ),
    isBusy(false),
    requests({})
{
    m_sender = "SNMP Agent";
}

SNMPConnection::~SNMPConnection()
{
    SNMPpp::closeSession( readSession );
}

void SNMPConnection::SetConfig( Configs *configs )
{
    pConfigs = configs;
    initFields();
}

MibParser *SNMPConnection::GetParser()
{
    return &parser;
}

States SNMPConnection::state()
{
    return _state;
}

void SNMPConnection::setState( States state )
{
    _state = state;
    emit stateChanged( state );
}

void SNMPConnection::proceed( AsyncSNMP* request )
{
    if ( request == nullptr ) return;
    if ( isBusy ) {
        requests.append( request );
        return;
    }
    else isBusy = true;

    if ( requests.empty() )
    {
        requests.append( request );
    }

    QThreadPool::globalInstance()->start( request );
}

void SNMPConnection::getOIDs( QString uid, QList<QString> objects )
{
    if ( readSession == NULL ) return;

    QList< SNMPpp::OID > oids;
    SNMPpp::PDU pdu( SNMPpp::PDU::kGet );

    for ( QString objectName : objects )
    {
        pdu.addNullVar( parser.ToOID( objectName ) );
    }

    RequestConfig config = {
        &readSession,
        pdu
    };

    AsyncSNMP *request = new AsyncSNMP( uid, config );

    connect( request, &AsyncSNMP::finished, this, &SNMPConnection::validateConnection);
    connect( request, &AsyncSNMP::finished, this, &SNMPConnection::handleSNMPRequest);
    connect( request, &AsyncSNMP::finished, this, &SNMPConnection::pushNextRequest);
    connect( request, &AsyncSNMP::gotError, this, &SNMPConnection::snmpError );

    proceed( request );
}

void SNMPConnection::handleSNMPRequest( QString root, QMap<SNMPpp::OID, QJsonObject> rows )
{
    if ( rows.empty() ) return;
    if ( readSession == NULL ) return;

    QJsonObject fields;

    for ( SNMPpp::OID oid : rows.keys() )
    {
        QString oidName = parser.FromOID( oid.parent() );

        QJsonArray data;
        QJsonObject row = rows[ oid ];

        row[ "field" ] = oidName;

        if ( fields.contains( oidName ) )
        {
            if ( fields[ oidName ].isArray() )
            {
                data = fields[ oidName ].toArray();
            }
            else
            {
                data.append( fields[ oidName ].toObject() );
            }

            data.append( row );

            fields[ oidName ] = data;
            continue;
        }

        fields[ oidName ] = row;
    }

    emit gotRowsContent( root, fields );
}

void SNMPConnection::pushNextRequest()
{
    isBusy = false;

    if ( requests.empty() ) return;
    requests.removeFirst();

    if ( requests.empty() ) return;
    proceed( requests.first() );
}


void SNMPConnection::snmpError( int code )
{
    if ( code == 0 ) return;
    readSession = NULL;
    writeSession = NULL;
    dropConnection();
}

void SNMPConnection::validateConnection( QString root, QMap<SNMPpp::OID, QJsonObject> rows )
{
    if ( root == "initSession" )
    {
        SNMPpp::OID snmpVersionOID = parser.ToOID( "stSNMPVersion.0" );
        int snmpVersion = rows[ snmpVersionOID ][ "num" ].toInt();
        if ( snmpVersion != 1 && snmpVersion != 3 ) return;
    }

    if ( _state != Disconnected ) return;

    emit notify( 0, "Подключено", 3000 );
    _state = Connected;
    emit stateChanged( _state );
}

void SNMPConnection::getTable( QString objectName )
{
    if ( readSession == NULL ) return;


    SNMPpp::PDU pdu( SNMPpp::PDU::kGetBulk );
    RequestConfig config {
        &readSession,
        pdu,
        parser.ToOID( objectName )
    };

    AsyncSNMP *request = new AsyncSNMP( objectName, config );

    connect( request, &AsyncSNMP::finished, this, &SNMPConnection::handleSNMPRequest );
    connect( request, &AsyncSNMP::finished, this, &SNMPConnection::pushNextRequest);
    connect( request, &AsyncSNMP::gotError, this, &SNMPConnection::snmpError );

    proceed( request );
}

void SNMPConnection::setOID( QString objectName, QVariant data )
{
    QJsonObject request;
    QJsonObject value;
    value[ "value" ] = QJsonValue::fromVariant( data );
    request[ objectName ] = value;
    setMultiple( request );
}

void SNMPConnection::PDUAddString( SNMPpp::PDU *pdu, QString key, QJsonObject fields )
{
    if ( !fields.contains( key ) ) return;
    QString _authPassw = fields[ key ].toObject()[ "value" ].toString();
    pdu->addOctetStringVar(
        parser.ToOID( key + ".0" ),
        (unsigned char *) _authPassw.toStdString().c_str(),
        _authPassw.toStdString().size() );
}

void SNMPConnection::setMultiple( QJsonObject fields )
{
    QJsonObject settings = pConfigs->get();
    QJsonObject connectionsSettings = settings[ "main" ].toObject();


    for( QString key : fields.keys() )
    {
        SNMPpp::PDU pdu( SNMPpp::PDU::kSet );

        QJsonObject field = fields[ key ].toObject();
        QVariant value = field[ "value" ].toVariant();
        bool hasAuthData = false;

        oid_object obj = parser.MIB_OBJECTS[ key ];
        SNMPpp::OID oid( parser.ToOID( key + ".0" ) );


        if ( key == "stSNMPAdministratorName" || key == "stSNMPAdministratorAuthPassword" || key == "stSNMPAdministratorPrivPassword" )
        {
            PDUAddString( &pdu, "stSNMPAdministratorAuthPassword", fields );
            PDUAddString( &pdu, "stSNMPAdministratorPrivPassword", fields );
            hasAuthData = true;
        }

        if ( key == "stSNMPEngineerName" || key == "stSNMPEngineerAuthPassword" || key == "stSNMPEngineerPrivPassword" )
        {
            PDUAddString( &pdu, "stSNMPEngineerAuthPassword", fields );
            PDUAddString( &pdu, "stSNMPEngineerPrivPassword", fields );
            hasAuthData = true;
        }

        if ( key == "stSNMPOperatorName" || key == "stSNMPOperatorAuthPassword" || key == "stSNMPOperatorPrivPassword" )
        {
            PDUAddString( &pdu, "stSNMPOperatorAuthPassword", fields );
            PDUAddString( &pdu, "stSNMPOperatorPrivPassword", fields );
            hasAuthData = true;
        }

        if ( hasAuthData )
        {
            PDUAddString( &pdu, "stSNMPSAuthAlgo", fields );
            PDUAddString( &pdu, "stSNMPSPrivAlgo", fields );
        }

        switch ( obj.type ) {
        case TYPE_INTEGER:
            pdu.addIntegerVar( oid, value.toInt() );
            break;
        case TYPE_GAUGE:
            pdu.addGaugeVar( oid, value.toUInt() );
            break;
        case TYPE_NULL:
            pdu.addNullVar( oid );
            break;
        case TYPE_OCTETSTR: case TYPE_NETADDR: case TYPE_IPADDR: case TYPE_NSAPADDRESS:
            pdu.addOctetStringVar(
                oid,
                (unsigned char *) value.toString().toStdString().c_str(),
                value.toString().toStdString().size() );
            break;
        default:
            if ( value.isNull() ) pdu.addNullVar( oid );
            else pdu.addIntegerVar( oid, value.toInt() );
            break;
        }

        try
        {
            pdu = SNMPpp::set( writeSession, pdu );
        }
        catch( const std::exception &e )
        {
            emit error_occured( Callback::New( e.what(), Callback::Warning ) );
            QString objectName = parser.OID_TOSTR[ oid ];

            if ( field.contains( "description" ) ) {
                objectName = field[ "description" ].toString();
                if ( objectName.trimmed().isEmpty() )
                {
                    objectName = parser.OID_TOSTR[ oid ];
                }
            }

            emit notify(-1, "Не удалось записать объект " + objectName, 3000 );
            return;
        }

        pdu.free();
    }

    emit notify( 0, "Все настройки успешно записаны", 3000 );
    emit settingsChanged();

    getOIDs( "initSession", { "stSNMPVersion.0" } );
}

void SNMPConnection::updateConfigs()
{
    QJsonObject configs = pConfigs->get();

    for ( QString key : configs.keys() )
    {
        if ( key == "main" || key == "errors" || key == "masks" || key == "journal" || key == "fields" ) continue;

        QJsonObject config = configs[ key ].toObject();
        QList<SNMPpp::OID> oids;

        SNMPpp::PDU pdu( SNMPpp::PDU::kGet );

        for ( QString field : config.keys() )
        {
            pdu.addNullVar( parser.ToOID( field + ".0" ) );
        }

        RequestConfig requestConfig = {
            &readSession,
            pdu
        };

        AsyncSNMP *request = new AsyncSNMP( key, requestConfig );

        connect( request, &AsyncSNMP::finished, this, [&]( QString root, QMap<SNMPpp::OID, QJsonObject> rows )
        {
            QJsonObject fullConfig = pConfigs->get();
            QJsonObject config = fullConfig[ root ].toObject();

            for ( SNMPpp::OID oid : rows.keys() )
            {
                QString fieldName = parser.FromOID( oid.parent() );
                QJsonObject field = config[ fieldName ].toObject();
                int fieldValue = rows[ oid ][ "num" ].toInt();

                switch ( field[ "type" ].toInt() )
                {
                    case FieldCombobox:
                        field[ "value" ] = fieldValue;
                        config[ fieldName ] = field;

                        break;

                    case FieldCounter:
                        field[ "value" ] = fieldValue;
                        config[ fieldName ] = field;
                        break;

                    case FieldSwitch:
                        field[ "value" ] = fieldValue;
                        config[ fieldName ] = field;
                        break;

                    default:
                        field[ "value" ] = rows[ oid ][ "str" ].toString();
                        config[ fieldName ] = field;
                        break;
                }
            }

            fullConfig[ root ] = config;
            pConfigs->write( fullConfig );

            emit settingsChanged();
        } );

        connect( request, &AsyncSNMP::finished, this, &SNMPConnection::pushNextRequest);
        connect( request, &AsyncSNMP::gotError, this, &SNMPConnection::snmpError );

        proceed( request );

    }
}

void SNMPConnection::sendConfigs()
{
    QJsonObject configs = pConfigs->get();

    for ( QString key : configs.keys() )
    {
        if ( key == "main" || key == "errors" || key == "masks" || key == "journal" ) continue;
        setMultiple( configs[ key ].toObject() );
    }
}

void SNMPConnection::sendConfigsChangedEvent()
{
    emit settingsChanged();
}

void SNMPConnection::exportTable( QString file, QList<QString> headers, QList<QString> rows, QString separator )
{
    QStringList buffer;

    if ( rows.count() % headers.count() != 0 ) return;
    int columns = headers.count();
    int rowsCount = rows.count() / headers.count();

    for ( int index = 0; index < headers.count(); index++ )
    {
        buffer << headers[ index ] << (index == (headers.count() - 1) ? "\n" : separator);
    }

    for ( int index = 0; index < rows.count(); index++ )
    {
        buffer << rows[ index ];

        if ( (index + 1) % columns ) buffer << separator;
        else buffer << "\n";
    }

    QFile tableFile( file );

    if ( !tableFile.open( QIODevice::WriteOnly | QIODevice::Truncate ) )
    {
        emit error_occured( Callback::New( tableFile.errorString(), Callback::Warning ) );
        return;
    }

    tableFile.write( buffer.join("").toUtf8() );
    tableFile.close();
}

QString SNMPConnection::dateToReadable( QString date )
{
    return QDateTime::fromString( date, "ddMMyyyyhhmmss" ).toString( "dd-MM-yyyy hh:mm:ss" );
}

void SNMPConnection::updateConnection( bool sync )
{
    requests.clear();
    _state = Disconnected;
    emit stateChanged( _state );

    QJsonObject configs = pConfigs->get()[ "main" ].toObject();

    Field host = Field::FromJSON( configs[ "host" ].toObject() );
    Field port = Field::FromJSON( configs[ "port" ].toObject() );

    QString address = "udp:" + host.value.toString() + ":" + port.value.toString();
    Field snmpVer = Field::FromJSON( configs[ "stSNMPVersion" ].toObject() );

    try
    {
        dropConnection( false );

        SOCK_CLEANUP;
        SOCK_STARTUP;

        if ( snmpVer.value.toInt() != SNMP_VERSION )
        {
            Field v2_write = Field::FromJSON( configs[ "v2_write" ].toObject() );
            Field v2_read = Field::FromJSON(configs[ "v2_read" ].toObject());

            SNMPpp::openSession(
                readSession,
                address.toStdString(),
                v2_read.value.toString().toStdString(),
                SNMP_VERSION_2c);

            SNMPpp::openSession(
                writeSession,
                address.toStdString(),
                v2_write.value.toString().toStdString(),
                SNMP_VERSION_2c);

            _currentVersion = 1;
        }
        else
        {
            Field user = Field::FromJSON( configs[ "stSNMPAdministratorName" ].toObject() );
            Field authPassword = Field::FromJSON( configs[ "stSNMPAdministratorAuthPassword" ].toObject() );
            Field privPassword = Field::FromJSON( configs[ "stSNMPAdministratorPrivPassword" ].toObject() );
            Field authMethod = Field::FromJSON( configs[ "authMethod" ].toObject() );

            Field authProtocol = Field::FromJSON( configs[ "stSNMPSAuthAlgo" ].toObject() );
            Field privProtocol = Field::FromJSON( configs[ "stSNMPSPrivAlgo" ].toObject() );

            int methodIndex = authMethod.value.toInt();
            int authIndex = authProtocol.value.toInt();
            int privIndex = privProtocol.value.toInt();

            std::string _authMethod =
                  methodIndex == 0 ? "noAuthNoPriv"
                : methodIndex == 1 ? "authNoPriv" : "authPriv";

            std::string _authProtocol = authIndex == 1 ? "MD5" : "SHA1";
            std::string _privProtocol = privIndex == 2 ? "AES" : "DES";

            /**
             * Fix bug with auth and priv password
             * By cleaning usm users
             */
            usmUser* actUser = usm_get_userList();
            while ( actUser != NULL ) {
                usmUser* dummy = actUser->next;
                // usm_remove_user( actUser );
                // usm_free_user( actUser );
                //
                usm_set_user_password(
                    actUser,
                    "userSetAuthPass",
                    (char *) authPassword.value.toString().toStdString().c_str() );

                usm_set_user_password(
                    actUser,
                    "userSetPrivPass",
                    (char *) privPassword.value.toString().toStdString().c_str() );

                actUser = dummy;
            }
            // usm_create_user_from_session( readSession );
            usm_create_user();

            SNMPpp::openSessionV3(
                readSession,
                address.toStdString(),
                user.value.toString().toStdString(),
                authPassword.value.toString().toStdString().c_str(),
                privPassword.value.toString().toStdString().c_str(),
                _authMethod,
                _authProtocol,
                _privProtocol
            );

            writeSession = readSession;
            _currentVersion = SNMP_VERSION;
        }

        if ( readSession == NULL ) {
            _state = Disconnected;
            emit stateChanged( _state );
            return;
        }

        if ( sync )
        {
            QEventLoop loop;
            SNMPpp::PDU pdu( SNMPpp::PDU::kGet );
            pdu.addNullVar( parser.ToOID( "stSNMPVersion.0" ) );

            RequestConfig config = {
                &readSession,
                pdu
            };
            AsyncSNMP *request = new AsyncSNMP( "initSession", config);

            connect( request, &AsyncSNMP::finished, this, &SNMPConnection::handleSNMPRequest );
            connect( request, &AsyncSNMP::finished, this, &SNMPConnection::validateConnection);
            connect( request, &AsyncSNMP::finished, &loop, &QEventLoop::quit );

            QThread::currentThread()->msleep(3000);
            QThreadPool::globalInstance()->start( request );

            loop.exec();
            return;
        }

        getOIDs( "initSession", { "stSNMPVersion.0" } );
    }
    catch ( const std::exception &e )
    {
        QString error = QString::fromStdString( e.what() );

        _state = Disconnected;
        emit stateChanged( _state );
        emit error_occured( Callback::New( error, Callback::Error ) );

        emit notify( -1, "Ошибка SNMP: " + error, 3000 );
        dropConnection();
    }
}

void SNMPConnection::dropConnection( bool sendNotify )
{
    if ( _state == Disconnected ) return;

    try {
        _state = Disconnected;
        emit stateChanged( _state );
        if ( sendNotify ) emit notify( -1, "Соединение сброшено", 3000 );
        SOCK_CLEANUP;

        if ( readSession == NULL ) return;
        if ( _currentVersion == SNMP_VERSION )
        {
            SNMPpp::closeSession( readSession );
            readSession = NULL;
            writeSession = NULL;
            return;
        }

        SNMPpp::closeSession( readSession );
        SNMPpp::closeSession( writeSession );
    } catch( std::exception &e )
    {
        emit error_occured( Callback::New( e.what(), Callback::Error ) );
    }
}

QVariant SNMPConnection::getFieldValue( QString object ) {
    QJsonObject fields = pConfigs->get()[ "fields" ].toObject();
    if ( !fields.contains( object ) ) return QVariant::fromValue( nullptr );
    QJsonObject field = fields[ object ].toObject();
    if ( !field.contains( "value" ) ) return QVariant::fromValue( nullptr );
    return field[ "value" ].toVariant();
}

void SNMPConnection::initFields()
{
    QJsonObject fields;

    for ( QString field : fields.keys() ) {
        QJsonObject fieldObj = fields[ field ].toObject();
        fieldObj[ "field" ] = field;
        fields[ field ] = fieldObj;
    }

    QJsonObject mainConfig = pConfigs->get();
    mainConfig[ "fields" ] = fields;
    pConfigs->write( mainConfig );
}

QJsonArray SNMPConnection::getGroup( QString group_name )
{
    QJsonArray outObjects;

    oid_object targetObject = parser.MIB_OBJECTS[ group_name ];
    SNMPpp::OID targetOID( targetObject.oid.toStdString().c_str() );

    for ( oid_object obj : parser.MIB_OBJECTS.values() )
    {
        if ( !targetOID.isParentOf( SNMPpp::OID( obj.oid.toStdString() ) ) ) continue;
        QJsonObject field = oid_object::ToJSON( obj );
        field[ "field" ] = obj.label;
        outObjects.append( field );
    }

    return outObjects;
}
