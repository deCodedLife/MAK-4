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

States SNMPConnection::state()
{
    return _state;
}

void SNMPConnection::setState( States state )
{
    _state = state;
    emit stateChanged( state );
}

QVariant SNMPConnection::getOID( QString oid )
{
    QString recivedData = "";

    SNMPpp::PDU pdu( SNMPpp::PDU::kGet );
    oid_object obj = parser.MIB_OBJECTS[ oid ];

    try
    {
        pdu.addNullVar( SNMPpp::OID( obj.oid + ".0" ) );
        pdu = SNMPpp::get( pHandle, pdu );

        switch ( pdu.varlist().asnType() )
        {
        case ASN_BOOLEAN:
            return (bool) pdu.varlist().at( obj.oid + ".0" )->data;

        case ASN_INTEGER:
            return QVariant::fromValue( *pdu.varlist().at( obj.oid + ".0" )->val.integer );

        case ASN_BIT_STR:
            return QVariant::fromValue( pdu.varlist().at( obj.oid + ".0" )->val.string );

        case ASN_NULL:
            return QVariant::fromValue( nullptr );

        case ASN_OBJECT_ID:
            return QVariant::fromValue( *pdu.varlist().at( obj.oid + ".0" )->val.objid );

        case ASN_COUNTER:
            counter64 *counter = pdu.varlist().at( obj.oid + ".0" )->val.counter64;
            QList<u_long> array = { counter->low, counter->high };
            return QVariant::fromValue( array );
        }

        return QVariant::fromValue( pdu.varlist().asString() );
    }
    catch( const std::exception &e )
    {
        emit error_occured( Callback::New( e.what(), Callback::Warning ) );
    }

    pdu.free();
    return QVariant::fromValue( nullptr );
}

void SNMPConnection::setOID( QString oid, QVariant data )
{
    SNMPpp::PDU pdu( SNMPpp::PDU::kGet );
    oid_object obj = parser.MIB_OBJECTS[ oid ];

    switch ( obj.type ) {
    case TYPE_INTEGER:
        pdu.addIntegerVar( SNMPpp::OID( obj.oid ), data.toInt() );
        break;
    case TYPE_GAUGE:
        pdu.addGaugeVar( SNMPpp::OID( obj.oid ), data.toUInt() );
        break;
    case TYPE_NULL:
        pdu.addNullVar( SNMPpp::OID( obj.oid ) );
        break;
    case TYPE_OCTETSTR:
        pdu.addOctetStringVar(
            SNMPpp::OID( obj.oid),
            (unsigned char *) data.toString().toStdString().c_str(),
            data.toString().toStdString().size() );
        break;
    default:
        pdu.addNullVar( SNMPpp::OID( obj.oid ) );
        break;
    }

    try
    {
        pdu.addNullVar( SNMPpp::OID( obj.oid + ".0" ) );
        pdu = SNMPpp::set( pHandle, pdu );
    }
    catch( const std::exception &e )
    {
        emit error_occured( Callback::New( e.what(), Callback::Warning ) );
    }

    pdu.free();

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

        QVariant reply = getOID( "stSNMPVersion" );

        if ( reply.isNull() ) {
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
    fields[ "deviceInfo0" ] = Field::ToJSON( { FieldText, "Серийный номер источника питания", "" } );
    fields[ "psSerial" ] = Field::ToJSON( { FieldText, getFieldValue( "psSerial" ), "Серийный номер источника питания" } );

    fields[ "deviceInfo1" ] = Field::ToJSON( { FieldText, "Описание источника питания", "" } );
    fields[ "psDescription" ] = Field::ToJSON( { FieldText, getFieldValue( "psDescription" ), "Описание источника питания" } );

    fields[ "deviceInfo2" ] = Field::ToJSON( { FieldText, "Версия ПО контроллера", "" } );
    fields[ "psFWRevision" ] = Field::ToJSON( { FieldText, getFieldValue( "psFWRevision" ), "Версия ПО контроллера" } );

    fields[ "deviceInfo3" ] = Field::ToJSON( { FieldText, "Текущее время MAK-4 UTC", "" } );
    fields[ "psTime" ] = Field::ToJSON( { FieldText, getFieldValue( "psTime" ), "Текущее время MAK-4 UTC" } );

    QJsonObject newConfig;
    newConfig[ "main" ] = pConfigs->get()[ "main" ].toObject();
    newConfig[ "fields" ] = fields;

    pConfigs->write( newConfig );
}
