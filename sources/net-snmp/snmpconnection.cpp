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
    AsyncSNMP *request = new AsyncSNMP( readSession, SNMPpp::PDU::kGet );

    for ( QString objectName : objects )
    {
        oid_object object = parser.MIB_OBJECTS[ objectName ];
        SNMPpp::OID oid( object.oid.toStdString() );
        oid += 0;

        oids.append( oid );
    }

    request->setUID( uid );
    request->setOIDs( oids );

    connect( request, &AsyncSNMP::rows, this, &SNMPConnection::handleSNMPRequest);
    connect( request, &AsyncSNMP::finished, this, &SNMPConnection::handleSNMPFinished );

    proceed( request );
}

void SNMPConnection::handleSNMPRequest( QString root, QMap<SNMPpp::OID, QJsonObject> rows )
{
    if ( rows.empty() ) return;

    if ( _state == Disconnected ) {
        emit notify( 0, "Подключено", 3000 );
    }

    _state = Connected;
    emit stateChanged( _state );

    QJsonObject fields;

    for ( SNMPpp::OID oid : rows.keys() )
    {
        QString oidName = parser.OID_TOSTR[ oid.parent() ];

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

void SNMPConnection::handleSNMPFinished( int code )
{
    if ( code != 0 ) {
        readSession = NULL;
        writeSession = NULL;
        dropConnection();
    }
    isBusy = false;

    if ( requests.empty() ) return;
    requests.removeFirst();

    if ( requests.empty() ) return;
    proceed( requests.first() );
}

void SNMPConnection::getTable( QString objectName )
{
    if ( readSession == NULL ) return;

    QList<QString> combinedName = objectName.split( "." );
    QList<QString> combined = objectName.split( combinedName.first() );
    if ( combined.length() != 1 ) combined.removeFirst();

    oid_object object = parser.MIB_OBJECTS[ combinedName.first() ];
    SNMPpp::OID start(
        object.oid.toStdString() +
        combined.first().toStdString()
    );
    AsyncSNMP *request = new AsyncSNMP( readSession, SNMPpp::PDU::kGetBulk );
    request->setBounds( start );
    request->setUID( objectName );

    connect( request, &AsyncSNMP::rows, this, &SNMPConnection::handleSNMPRequest );
    connect( request, &AsyncSNMP::finished, this, &SNMPConnection::handleSNMPFinished );

    proceed( request );
}

void SNMPConnection::setOID( QString objectName, QVariant data )
{
    setMultiple( { { objectName, { { "value", data.toJsonValue() } } } } );
}

void SNMPConnection::setMultiple( QJsonObject fields )
{
    int limit {10};
    int counter {0};

    for( QString key : fields.keys() )
    {
        SNMPpp::PDU pdu( SNMPpp::PDU::kSet );

        QJsonObject field = fields[ key ].toObject();
        QVariant value = fields[ key ].toObject()[ "value" ].toVariant();

        if ( field[ "type" ] == FieldCombobox )
        {
            value = field[ "model" ].toObject()[ field[ "value" ].toString() ].toInt();
        }

        oid_object obj = parser.MIB_OBJECTS[ key ];
        SNMPpp::OID oid( obj.oid.toStdString() + ".0" );

        switch ( obj.type ) {
        case TYPE_INTEGER:
            pdu.addIntegerVar( oid, value.toInt() );
            qDebug() << pdu.varlist().asString();
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
            // pdu.addNullVar( oid );
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
        }

        pdu.free();
    }
    emit settingsChanged();
}

void SNMPConnection::updateConfigs()
{
    QJsonObject configs = pConfigs->get();

    for ( QString key : configs.keys() )
    {
        QJsonObject config = configs[ key ].toObject();
        QList<SNMPpp::OID> oids;

        for ( QString field : config.keys() )
        {
            oid_object object = parser.MIB_OBJECTS[ field ];
            oids.append( SNMPpp::OID( object.oid.toStdString() + ".0" ) );
        }

        if ( oids.empty() ) continue;

        AsyncSNMP *request = new AsyncSNMP( readSession, SNMPpp::PDU::kGet );
        request->setUID( key );
        request->setOIDs( oids );

        connect( request, &AsyncSNMP::rows, this, [&]( QString root, QMap<SNMPpp::OID, QJsonObject> rows )
        {
            QJsonObject fullConfig = pConfigs->get();
            QJsonObject config = fullConfig[ root ].toObject();

            for ( SNMPpp::OID oid : rows.keys() )
            {
                QString fieldName = parser.OID_TOSTR[ oid.parent() ];
                QJsonObject field = config[ fieldName ].toObject();
                int fieldValue = rows[ oid ][ "num" ].toInt();

                switch ( field[ "type" ].toInt() )
                {
                    case FieldCombobox:

                        for ( QString modelKey : field[ "model" ].toObject().keys() ) {

                            int modelValue = field[ "model" ].toObject()[ modelKey ].toInt();
                            if ( modelValue == fieldValue )
                            {
                                field[ "value" ] = modelKey;
                                config[ fieldName ] = field;
                                break;
                            }
                        }

                        break;

                    case FieldCounter:
                        field[ "value" ] = fieldValue;
                        config[ fieldName ] = field;
                        break;

                    case FieldCheckbox:
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
        connect( request, &AsyncSNMP::finished, this, &SNMPConnection::handleSNMPFinished );
        proceed( request );

    }
}

QString SNMPConnection::dateToReadable( QString date )
{
    return QDateTime::fromString( date, "ddMMyyyyhhmmss" ).toString( "dd-MM-yyyy hh:mm:ss" );
}

void SNMPConnection::updateConnection()
{
    SOCK_CLEANUP;
    SOCK_STARTUP;

    _state = Disconnected;
    emit stateChanged( _state );

    QJsonObject configs = pConfigs->get()[ "main" ].toObject();
    SNMPpp::closeSession( readSession );

    Field host = Field::FromJSON( configs[ "host" ].toObject() );
    Field port = Field::FromJSON( configs[ "port" ].toObject() );

    QString address = "udp:" + host.value.toString() + ":" + port.value.toString();

    Field snmpVer = Field::FromJSON( configs[ "snmpVersion" ].toObject() );

    try
    {
        if ( snmpVer.value.toString() == "snmpV2c" )
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
        }
        else
        {
            Field user = Field::FromJSON( configs[ "user" ].toObject() );
            Field authPassword = Field::FromJSON( configs[ "authPassword" ].toObject() );
            Field privPassword = Field::FromJSON( configs[ "privPassword" ].toObject() );
            Field authMethod = Field::FromJSON( configs[ "authMethod" ].toObject() );

            Field authProtocol = Field::FromJSON( configs[ "authProtocol" ].toObject() );
            Field privProtocol = Field::FromJSON( configs[ "privProtocol" ].toObject() );

            SNMPpp::openSessionV3(
                readSession,
                address.toStdString(),
                user.value.toString().toStdString(),
                authPassword.value.toString().toStdString(),
                privPassword.value.toString().toStdString(),
                authMethod.value.toString().toStdString(),
                authProtocol.value.toString().toStdString(),
                privProtocol.value.toString().toStdString()
            );

            writeSession = readSession;
        }

        if ( readSession == NULL ) {
            _state = Disconnected;
            emit stateChanged( _state );
            return;
        }

        getOIDs( "", { "stSNMPVersion" } );
    }
    catch ( const std::exception &e )
    {
        SOCK_CLEANUP;
        SNMPpp::closeSession( readSession );

        QString error = QString::fromStdString( e.what() );

        _state = Disconnected;
        emit stateChanged( _state );
        emit error_occured( Callback::New( error, Callback::Error ) );

        emit notify( -1, "Ошибка SNMP: " + error, 3000 );
    }
}

void SNMPConnection::dropConnection()
{
    SOCK_CLEANUP;
    _state = Disconnected;
    emit stateChanged( _state );
    SNMPpp::closeSession( readSession );
    emit notify( -1, "Соединение сброшено", 3000 );
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
