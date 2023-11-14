#include "snmpconnection.h"

SNMPConnection::SNMPConnection(QObject *parent)
    : TObject{parent},
    pHandle(NULL),
    _state( Disconnected )
{
    m_sender = "SNMP Agent";


}

SNMPConnection::~SNMPConnection()
{
    SNMPpp::closeSession( pHandle );
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

QList<QString> SNMPConnection::getOIDs( QList<QString> objects )
{
    SNMPpp::PDU pdu( SNMPpp::PDU::kGet );
    QList<QString> reply;

    if ( objects.length() == 0 )
    {
        return reply;
    }

    try
    {
        for ( QString objectName : objects )
        {
            if ( !parser.MIB_OBJECTS.contains( objectName ) ) continue;
            oid_object object = parser.MIB_OBJECTS[ objectName ];
            SNMPpp::OID o( object.oid.toStdString() );
            o += 0;
            pdu.addNullVar( o );
        }

        pdu = SNMPpp::get( pHandle, pdu );

        for ( QString objectName : objects )
        {
            if ( !parser.MIB_OBJECTS.contains( objectName ) ) {
                reply.append( "" );
                continue;
            }
            oid_object object = parser.MIB_OBJECTS[ objectName ];
            SNMPpp::OID o( object.oid.toStdString() );
            o += 0;
            QString value;

            if ( pdu.varlist().asnType( o ) == ASN_INTEGER ) value = QString::number( *pdu.varlist().valueAt( o ).integer );
            else value = QString::fromStdString( pdu.varlist().asString( o ) );
            reply.append( value );
        }
    }
    catch( const std::exception &e )
    {
        emit error_occured( Callback::New( e.what(), Callback::Warning ) );
    }

    pdu.free();
    return reply;
}

void SNMPConnection::getRows( QString objectName )
{
    oid_object object = parser.MIB_OBJECTS[ objectName ];
    SNMPpp::OID start( object.oid.toStdString() );

    AsyncSNMP *request = new AsyncSNMP();
    request->setOIDs( pHandle, start );

    connect( request, &AsyncSNMP::rows, this, [&]( SNMPpp::OID root, QMap<SNMPpp::OID, QJsonObject> rows ) {
        QJsonObject fields;
        for ( SNMPpp::OID oid : rows.keys() )
        {
            QJsonArray data;
            QString oidName = parser.OID_TOSTR[ oid.parent() ];

            if ( fields.contains( oidName ) ) data = fields[ oidName ].toArray();
            rows[ oid ][ "field" ] = oidName;

            data.append( rows[ oid ] );
            fields[ oidName ] = data;
        }
        emit gotRowsContent( parser.OID_TOSTR[ root ], fields  );
    } );

    QThreadPool::globalInstance()->start( request );
}

void SNMPConnection::getTable( QString objectName )
{
    oid_object object = parser.MIB_OBJECTS[ objectName ];
    SNMPpp::OID start( object.oid.toStdString() );
    QJsonObject fields;

    try
    {
        SNMPpp::OID currentOID = start;

        while( true )
        {
            SNMPpp::PDU pdu = SNMPpp::getBulk( pHandle, currentOID );

            if ( pdu.empty() ) break;
            bool shouldBreak {false};

            SNMPpp::MapOidVarList list = pdu.varlist().getMap();
            SNMPpp::MapOidVarList::iterator iter;

            for ( iter = list.begin(); iter != list.end(); iter++ )
            {
                currentOID = iter->first;

                if ( !start.isParentOf( currentOID ) )
                {
                    shouldBreak = true;
                    break;
                }

                QJsonArray data;
                QJsonObject field;

                if ( fields.contains( parser.OID_TOSTR[ currentOID.parent() ] ) )
                {
                    data = fields[ parser.OID_TOSTR[ currentOID.parent() ] ].toArray();
                }

                field[ "str" ] = QString::fromStdString( pdu.varlist().asString( currentOID ) );
                field[ "num" ] = (qint64) *iter->second->val.integer;

                data.append( field );
                fields[ parser.OID_TOSTR[ currentOID.parent() ] ] = data;
            }

            if ( shouldBreak ) break;
            if ( list.size() < 2 ) break;
        }
    }
    catch( std::exception &e )
    {
        error_occured( Callback::New( e.what(), Callback::Warning ) );
    }

    emit gotRowsContent( objectName, fields );
}

void SNMPConnection::setOID( QString objectName, QVariant data )
{
    SNMPpp::PDU pdu( SNMPpp::PDU::kSet );
    oid_object obj = parser.MIB_OBJECTS[ objectName ];
    SNMPpp::OID oid( obj.oid.toStdString() + ".0" );

    switch ( obj.type ) {
    case TYPE_INTEGER:
        pdu.addIntegerVar( oid, data.toInt() );
        qDebug() << pdu.varlist().asString();
        break;
    case TYPE_GAUGE:
        pdu.addGaugeVar( oid, data.toUInt() );
        break;
    case TYPE_NULL:
        pdu.addNullVar( oid );
        break;
    case TYPE_OCTETSTR:
        pdu.addOctetStringVar(
            oid,
            (unsigned char *) data.toString().toStdString().c_str(),
            data.toString().toStdString().size() );
        break;
    default:
        pdu.addNullVar( oid );
        break;
    }

    try
    {
        pdu = SNMPpp::set( pHandle, pdu );
    }
    catch( const std::exception &e )
    {
        emit error_occured( Callback::New( e.what(), Callback::Warning ) );
    }

    pdu.free();

}

QString SNMPConnection::dateToReadable( QString date )
{
    return QDateTime::fromString( date, "ddMMyyyyhhmmss" ).toString( "dd-MM-yyyy hh:mm:ss" );
}

void SNMPConnection::updateConnection()
{
    QJsonObject configs = pConfigs->get()[ "main" ].toObject();
    SNMPpp::closeSession( pHandle );

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
                pHandle,
                address.toStdString(),
                v2_read.value.toString().toStdString() );
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
                pHandle,
                address.toStdString(),
                user.value.toString().toStdString(),
                authPassword.value.toString().toStdString(),
                privPassword.value.toString().toStdString(),
                authMethod.value.toString().toStdString(),
                authProtocol.value.toString().toStdString(),
                privProtocol.value.toString().toStdString()
            );
        }

        if ( pHandle == NULL ) {
            _state = Disconnected;
            emit stateChanged( _state );
            return;
        }

        QList<QString> reply = getOIDs( { "stSNMPVersion" } );

        if ( reply.empty() ) {
            _state = Disconnected;
            emit stateChanged( _state );
            emit error_occured( Callback::New( "Не удалось получить данные с устройства", Callback::Warning ) );
            return;
        }

        _state = Connected;
        emit stateChanged( _state );
    }
    catch ( const std::exception &e )
    {
        _state = Disconnected;
        emit stateChanged( _state );
        emit error_occured( Callback::New( e.what(), Callback::Error ) );
    }
}

void SNMPConnection::dropConnection()
{
    _state = Disconnected;
    emit stateChanged( _state );
    SNMPpp::closeSession( pHandle );
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
