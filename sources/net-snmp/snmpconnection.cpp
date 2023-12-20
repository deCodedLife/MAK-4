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

    try
    {
        for ( QString objectName : objects )
        {
            if ( !parser.MIB_OBJECTS.contains( objectName ) ) continue;
            oid_object object = parser.MIB_OBJECTS[ objectName ];
            pdu.addNullVar( SNMPpp::OID( object.oid.toStdString() + ".0" ) );
        }

        pdu = SNMPpp::get( pHandle, pdu );

        QList<QString> reply;

        for ( QString objectName : objects )
        {
            if ( !parser.MIB_OBJECTS.contains( objectName ) ) {
                reply.append( "" );
                continue;
            }
            oid_object object = parser.MIB_OBJECTS[ objectName ];
            reply.append( QString::fromStdString( pdu.varlist().asString( object.oid.toStdString() + ".0" ) ) );
        }

        return reply;
    }
    catch( const std::exception &e )
    {
        emit error_occured( Callback::New( e.what(), Callback::Warning ) );
    }

    pdu.free();
    return QList<QString>{};
}

void SNMPConnection::setOID( QString oid, QVariant data )
{
    SNMPpp::PDU pdu( SNMPpp::PDU::kGet );
    oid_object obj = parser.MIB_OBJECTS[ oid ];

    switch ( obj.type ) {
    case TYPE_INTEGER:
        pdu.addIntegerVar( SNMPpp::OID( obj.oid.toStdString() ), data.toInt() );
        break;
    case TYPE_GAUGE:
        pdu.addGaugeVar( SNMPpp::OID( obj.oid.toStdString() ), data.toUInt() );
        break;
    case TYPE_NULL:
        pdu.addNullVar( SNMPpp::OID( obj.oid.toStdString() ) );
        break;
    case TYPE_OCTETSTR:
        pdu.addOctetStringVar(
            SNMPpp::OID( obj.oid.toStdString() ),
            (unsigned char *) data.toString().toStdString().c_str(),
            data.toString().toStdString().size() );
        break;
    default:
        pdu.addNullVar( SNMPpp::OID( obj.oid.toStdString() ) );
        break;
    }

    try
    {
        pdu.addNullVar( SNMPpp::OID( obj.oid.toStdString() + ".0" ) );
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
    fields[ "deviceInfo0" ] = Field::ToJSON( { FieldDescription, "Серийный номер источника питания", "" } );
    fields[ "psSerial" ] = Field::ToJSON( { FieldText, getFieldValue( "psSerial" ), "Серийный номер источника питания" } );

    fields[ "deviceInfo1" ] = Field::ToJSON( { FieldDescription, "Описание источника питания", "" } );
    fields[ "psDescription" ] = Field::ToJSON( { FieldText, getFieldValue( "psDescription" ), "Описание источника питания" } );

    fields[ "deviceInfo2" ] = Field::ToJSON( { FieldDescription, "Версия ПО контроллера", "" } );
    fields[ "psFWRevision" ] = Field::ToJSON( { FieldText, getFieldValue( "psFWRevision" ), "Версия ПО контроллера" } );

    fields[ "deviceInfo3" ] = Field::ToJSON( { FieldDescription, "Текущее время MAK-4 UTC", "" } );
    fields[ "psTime" ] = Field::ToJSON( { FieldText, getFieldValue( "psTime" ), "Текущее время MAK-4 UTC" } );

    fields[ "psAlarm1Event" ] = Field::ToJSON( { FieldText, getFieldValue( "psAlarm1Event" ), "" } );


    for ( QString field : fields.keys() ) {
        QJsonObject fieldObj = fields[ field ].toObject();
        fieldObj[ "field" ] = field;
        fields[ field ] = fieldObj;
    }

    QJsonObject newConfig;
    newConfig[ "main" ] = pConfigs->get()[ "main" ].toObject();
    newConfig[ "fields" ] = fields;

    pConfigs->write( newConfig );
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
