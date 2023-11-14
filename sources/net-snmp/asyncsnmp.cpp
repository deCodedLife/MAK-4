#include "asyncsnmp.h"

AsyncSNMP::AsyncSNMP(QObject *parent) {}

void AsyncSNMP::setOIDs( SNMPpp::SessionHandle& s, SNMPpp::OID from, SNMPpp::OID to )
{
    session = s;
    startFrom = from;
    endAt = to.empty() ? from : to;
}

void AsyncSNMP::run()
{
    int rowsCount = 0;

    SNMPpp::PDU pdu( SNMPpp::PDU::kGetBulk );
    SNMPpp::OID currentOID = startFrom;

    QMap<SNMPpp::OID, QJsonObject> fields;

    try
    {
        while ( true )
        {
            pdu = SNMPpp::getBulk( session, currentOID );

            if ( pdu.empty() ) break;
            bool shouldBreak {false};

            SNMPpp::MapOidVarList::iterator iter;
            SNMPpp::MapOidVarList list = pdu.varlist().getMap();

            for ( iter = list.begin(); iter != list.end(); iter++ )
            {
                currentOID = iter->first;

                if ( !endAt.isParentOf( currentOID ) )
                {
                    shouldBreak = true;
                    break;
                }

                rowsCount++;

                QJsonObject field;
                field[ "oid" ] = QString::fromStdString( currentOID.to_str() );
                field[ "num" ] = (qint64) *iter->second->val.integer;
                field[ "str" ] = QString::fromStdString( pdu.varlist().asString( currentOID ) );

                fields[ currentOID ] = field;
            }

            if ( list.size() < 2 ) break;
            if ( shouldBreak ) break;
        }
    }
    catch( std::exception &e )
    {
        qDebug() << e.what();
    }

    emit rows( startFrom, fields );
    emit finished( rowsCount );
}
