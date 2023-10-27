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

void SNMPConnection::getOID( QString oid, QString** reply )
{
    SNMPpp::PDU pdu( SNMPpp::PDU::kGet );

    try
    {
        pdu.addNullVar( SNMPpp::OID( oid.toStdString() ) );
        pdu = SNMPpp::get( pHandle, pdu );
        *reply = new QString();
        **reply = QString::fromStdString( pdu.varlist().asString() );
    }
    catch( const std::exception &e )
    {
        emit error_occured( Callback::New( e.what(), Callback::Warning ) );
    }

    pdu.free();
}

void SNMPConnection::setOID( QString oid, QVariant data )
{

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

        QString *reply = nullptr;
        getOID( ".1.3.6.1", &reply );

        if ( reply == nullptr ) {
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
