#include "asyncsnmp.h"

AsyncSNMP::AsyncSNMP( SNMPpp::SessionHandle& s, SNMPpp::PDU::EType t, QObject *parent )
    : QObject( parent ),
    session(s),
    type(t)
{}

void AsyncSNMP::setOIDs( QList<SNMPpp::OID> r )
{
    request = r;
}

void AsyncSNMP::setUID( QString u )
{
    uid = u;
}

void AsyncSNMP::setBounds( SNMPpp::OID from, SNMPpp::OID to )
{
    startFrom = from;
    endAt = to.empty() ? from : to;
}

void AsyncSNMP::run()
{
    SNMPpp::PDU pdu( type );

    QMap<SNMPpp::OID, QJsonObject> fields;
    SNMPpp::OID currentOID = startFrom;

    for ( SNMPpp::OID oid : request )
    {
        pdu.addNullVar( oid );
        endAt = oid;
    }

    try
    {
        while ( true )
        {
            if ( type == SNMPpp::PDU::kGetBulk )
            {
                pdu = SNMPpp::getBulk( session, currentOID );
            }
            else
            {
                pdu = SNMPpp::get( session, pdu );
            }


            if ( pdu.empty() ) break;
            bool shouldBreak {false};

            SNMPpp::MapOidVarList::iterator iter;
            SNMPpp::MapOidVarList list = pdu.varlist().getMap();

            for ( iter = list.begin(); iter != list.end(); iter++ )
            {
                currentOID = iter->first;

                if ( !endAt.isParentOf( currentOID ) && type == SNMPpp::PDU::kGetBulk )
                {
                    shouldBreak = true;
                    break;
                }

                QJsonObject field;
                field[ "oid" ] = QString::fromStdString( currentOID.to_str() );
                field[ "num" ] = (qint64) (iter->second->val.integer ? *iter->second->val.integer : 0);
                field[ "str" ] = QString::fromStdString( pdu.varlist().asString( currentOID ) );

                fields[ currentOID ] = field;
            }

            if ( list.size() < 2 ) break;
            if ( shouldBreak ) break;
            if ( endAt == currentOID ) break;
        }

        pdu.free();
    }
    catch( std::exception &e )
    {
        int errorCode {0};

        qDebug() << e.what();
        QStringList paresedError = QString::fromStdString( e.what() ).split( QRegularExpression( "\[.*\]" ) );

        if ( paresedError.length() != 2 )
        {
            emit finished( errorCode );
            return;
        }

        paresedError = paresedError.last().split( "," );

        for ( QString error : paresedError )
        {

            QStringList errorDetails = error.split( "snmperrno=" );
            QString strCode = errorDetails.last();

            if ( errorDetails.length() != 2 ) continue;
            errorCode = std::stoi( strCode.toStdString() );
        }

        emit finished( errorCode );
        return;
    }

    emit rows( uid, fields );
    emit finished( 0 );
}
