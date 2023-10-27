#include "snmpconnection.h"


//SNMPpp::PDU pdu( SNMPpp::PDU::kGet );
//pdu.addNullVar( ".1.3.6.1.4.1.36032.1.10.11.1.0" );

//pdu = SNMPpp::get( sessionHandle, pdu );

//qDebug() << pdu.varlist().asString();

//pdu.free();

SNMPConnection::SNMPConnection(QObject *parent)
    : TObject{parent},
    pHandle(NULL)
{
    connect( pConfigs, &Configs::updated, this, &SNMPConnection::UpdateConnection );
}

SNMPConnection::~SNMPConnection()
{
    SNMPpp::closeSession( pHandle );
}

void SNMPConnection::SetConfig( Configs *configs )
{
    pConfigs = configs;
    UpdateConnection();
}

void SNMPConnection::UpdateConnection()
{
    SNMPpp::closeSession( pHandle );

    try
    {
        SNMPpp::openSessionV3(
            pHandle,
            HOST, USER,
            AUTH_PASSWORD, PRIV_PASSWORD,
            "authPriv", "MD5", "AES",
            3, 1000000
            );

        SNMPpp::closeSession( pHandle );
    }
    catch ( const std::exception &e )
    {
        qDebug() << e.what();
        assert( pHandle == NULL );
    }

}
