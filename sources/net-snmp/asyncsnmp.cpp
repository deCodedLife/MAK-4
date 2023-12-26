#include "asyncsnmp.h"


/**
 * Proceed async request to device
 * Supports only kSet, kGet and kGetBulk requests
 * @brief AsyncRequest
 * @param request
 * @param reply
 * @return
 */
bool AsyncRequest( RequestConfig request, std::vector<Reply> *reply )
{
    /**
     * It's "walk" like implementation. We sending
     * messages until catch last oid
     */
    if ( request.pdu.getType() == SNMPpp::PDU::kGetBulk )
    {
        if ( request.bulkObject.empty() )
        {
            // std::runtime_error( "No configuration provided for GET BULK method" );
            return false;
        }
        request.pdu.addNullVar( request.bulkObject );
        SNMPpp::OID lastOID;

        while ( true )
        {
            /**
             * Sends request and track status
             */
            if ( !AsyncGetBulk( request, reply ) )
            {
                // std::runtime_error( "GET BULK request was ended with errors" );
                return false;
            }

            /**
             * Stops at end object of MIB EOF
             */
            if ( !request.bulkObject.isParentOf( reply->back().oid ) || lastOID == reply->back().oid )
            {
                reply->pop_back();
                break;
            }

            /**
             * Continue GET BULK request if we still not reached
             * the end object
             */
            request.pdu = SNMPpp::PDU( SNMPpp::PDU::kGetBulk );
            request.pdu.addNullVar( reply->back().oid );
            lastOID = reply->back().oid;
        }

        return true;
    }


    /**
     *  Iterating for pdu variables and send packages
     *  with buffered size
     */
    SNMPpp::PDU pdu( request.pdu.getType() );
    int iteration = 0;
    SNMPpp::VecOID varlist;

    /**
     * Here we pack objects to request by device buffer
     * size.
     *
     * PS: If we put while condition to begining then it
     * will quit instanly, because pdu varlist empty by
     * default
     */
    do
    {
        /**
         * Writing N objects. Where N is device buffer
         * @brief buffered
         */
        buffered( request, iteration, &pdu );
        pdu.varlist().getOids( varlist );

        iteration++;

        /**
         * Send GET or SET request
         */
        switch( request.pdu.getType() )
        {
        case SNMPpp::PDU::kSet:

            if ( !AsyncSet( { request.session, pdu } ) )
            {
                return false;
                // std::runtime_error( "Request was ended with errors" );
            }
            break;

        default:

            if ( !AsyncGet( { request.session, pdu }, reply ) )
            {
                return false;
                std::runtime_error( "Request was ended with errors" );
            }
            break;

        } // switch( request.pdu.getType() )

    } while ( varlist.size() >= request.deviceBuffer );


    /**
     * Free memory
     */
    if ( !pdu.empty() ) pdu.free();
    if ( !request.pdu.empty() ) request.pdu.free();

    return true;

} // bool AsyncRequest( RequestConfig request, std::vector<Reply> *reply )

/**
 * Parsing pdu reply to a vector of struct Reply
 * @brief parsePDU
 * @param request
 * @param reply
 * @param eof
 */
void parsePDU( const SNMPpp::PDU request, std::vector<Reply> *reply, SNMPpp::OID *eof )
{
    SNMPpp::OID currentOID;
    SNMPpp::MapOidVarList::iterator iter;
    SNMPpp::MapOidVarList list = request.varlist().getMap();

    for ( iter = list.begin(); iter != list.end(); iter++ )
    {
        currentOID = iter->first;

        if ( eof != nullptr && !eof->isParentOf( currentOID ) ) {
            reply->push_back( { currentOID } );
            return;
        }

        Reply field;
        QString strData = QString::fromStdString( request.varlist().asString( currentOID ) );

        field.oid = currentOID;
        field.numValue = (int) (iter->second->val.integer ? *iter->second->val.integer : 0);
        field.strValue = strData.toStdString();

        if (
            iter->second->type == TYPE_NETADDR ||
            iter->second->type == TYPE_IPADDR ||
            iter->second->type == TYPE_NSAPADDRESS
        ) {
            QStringList rawData = strData.split( "STRING: \"" );

            if ( rawData.length() != 0 && rawData.length() != 1 )
            {
                QString data = rawData.last();
                data.truncate( data.lastIndexOf( QChar('"') ) );
                field.strValue = data.toStdString();
            }
        }

        reply->push_back( field );
    } // for ( iter = list.begin(); iter != list.end(); iter++ )
} // void parsePDU( const SNMPpp::PDU request, std::vector<Reply> *reply, SNMPpp::OID *eof )


void buffered( const RequestConfig request, int buffIndex, SNMPpp::PDU *pdu )
{
    /**
     * Getting variables
     * @brief pduVariables
     */
    SNMPpp::Varlist pduVariables = request.pdu.varlist();
    SNMPpp::VecOID pduElements;
    pduVariables.getOids( pduElements );
    *pdu = SNMPpp::PDU( request.pdu.getType() );

    int indexStart = buffIndex * request.deviceBuffer;
    int indexEnd = std::min( ( buffIndex + 1 ) * request.deviceBuffer, (int) pduElements.size() );

    /**
     * Stop condition. If start >= end that means
     * we already iterated threw all elements
     */
    if ( indexStart >= indexEnd ) return;

    /**
     * Iterating threw elements and send requests
     */
    int pduElementIndex = 0;
    SNMPpp::VecOID::iterator element;


    /**
     * Writing objects to request
     */
    for (
        element = pduElements.begin() + indexStart;
        element < pduElements.begin() + indexEnd;
        element++, pduElementIndex++
    ) {

        /**
         * Type accurate adding variables to request
         */
        switch ( pduVariables.asnType( *element ) )
        {
        case ASN_BOOLEAN:
            pdu->addBooleanVar( *element, pduVariables.getBool( *element ) );
            break;

        case ASN_INTEGER:
            pdu->addIntegerVar( *element, pduVariables.getLong( *element ) );
            break;

        case ASN_BIT_STR: case ASN_OCTET_STR: case ASN_IPADDRESS:
            pdu->addOctetStringVar(
                *element,
                (u_char *) pduVariables.getString( *element ).c_str(),
                sizeof( (u_char *) pduVariables.getString( *element ).c_str() ) );
            break;

        case TYPE_GAUGE:
            pdu->addGaugeVar( *element, pduVariables.getLong( *element ) );
            break;

        case ASN_NULL:
            pdu->addNullVar( *element );
            break;

        default:
            pdu->addIntegerVar( *element, pduVariables.getLong( *element ) );
            break;
        } // switch ( pduVariables.asnType( *element ) )

        /**
         * If there are more 10 buffres in request
         * GET request will be sent
         */
        if ( pduElementIndex >= request.deviceBuffer ) return;
    }
} // void buffered( const RequestConfig request, int buffIndex, SNMPpp::PDU *pdu )

/**
 * Function sends GET request and parses reply
 * @brief AsyncGet
 * @param request
 * @param reply
 * @return
 */
bool AsyncGet( RequestConfig request, std::vector<Reply> *reply )
{
    /**
     * Checking if session is correct and pdu
     * have variables to get
     */
    if ( request.pdu.varlist().empty() ) return true;
    if ( request.session == NULL ) return false;

    /**
     * Actialy send a request
     */
    request.pdu = SNMPpp::get( *request.session, request.pdu );

    /**
     * Checking and parsing reply
     */
    if ( request.pdu.empty() ) return true;
    parsePDU( request.pdu, reply );

    return true;
} // bool AsyncGet( RequestConfig request, std::vector<Reply> *reply )


/**
 * Function sends GET BULK request and parses reply
 * @brief AsyncGet
 * @param request
 * @param reply
 * @return
 */
bool AsyncGetBulk( RequestConfig request, std::vector<Reply> *reply )
{
    /**
     * Checking if session is correct and pdu
     * have variables to get
     */
    if ( request.session == NULL ) return false;
    request.pdu = SNMPpp::getBulk( *request.session, request.pdu );

    /**
     * Checking and parsing reply
     */
    if ( request.pdu.empty() ) return true;
    parsePDU( request.pdu, reply, &request.bulkObject );

    return true;
} // bool AsyncGetBulk( RequestConfig request, std::vector<Reply> *reply )


/**
 * Converts struct Reply to QJSonObject
 */
void ReplyToJSON( const Reply reply, QJsonObject *object )
{
    QJsonObject replyObj;
    replyObj[ "oid" ] = QString::fromStdString( reply.oid );
    replyObj[ "num" ] = reply.numValue;
    replyObj[ "str" ] = QString::fromStdString( reply.strValue );
    *object = replyObj;
} // void ReplyToJSON( const Reply reply, QJsonObject *object )


/**
 * Function send SER request
 */
bool AsyncSet( RequestConfig request )
{
    /**
     * Checking if session is correct and pdu
     * have variables to get
     */
    if ( request.session == NULL ) return false;
    request.pdu = SNMPpp::set( *request.session, request.pdu );

    return true;
} // bool AsyncSet( RequestConfig request )


/**
 * AsyncSNMP class constructor
 * @brief AsyncSNMP::AsyncSNMP
 * @param _request
 * @param parent
 */
AsyncSNMP::AsyncSNMP( QString uid, RequestConfig _request,  QObject *parent )
    : QObject( parent ),
    request( _request ),
    uniqueRequestID( uid )
{}


void AsyncSNMP::run()
{
    QMap<SNMPpp::OID, QJsonObject> reply;
    std::vector<Reply> buffer;

    try
    {
        if ( !AsyncRequest( request, &buffer ) ) {
            emit gotError( -1 );
        }
    }
    catch ( std::exception &e )
    {
        QString errorString = QString::fromStdString( e.what() );
        QStringList paresedError = errorString.split( QRegularExpression( "\[.*\]" ) );
        qDebug() << errorString;

        int errorCode = 0;

        if ( paresedError.length() != 2 )
        {
            emit gotError( errorCode );
            return;
        }

        /**
         * Search for actual error name
         */
        for ( QString error : paresedError.last().split( "," ) )
        {

            QStringList errorDetails = error.split( "snmperrno=" );
            QString strCode = errorDetails.last();

            if ( errorDetails.length() != 2 ) continue;
            errorCode = std::stoi( strCode.toStdString() );
        }

        emit gotError( errorCode );
    } // catch ( std::exception &e )


    /**
     * Convert vector to map
     */
    std::vector<Reply>::iterator field;

    for ( field = buffer.begin(); field < buffer.end(); field++ )
    {
        QJsonObject fieldJSON;
        ReplyToJSON( *field, &fieldJSON );
        reply[ field->oid ] = fieldJSON;
    }

    buffer.clear();
    emit finished( uniqueRequestID, reply );
} // void AsyncSNMP::run()
