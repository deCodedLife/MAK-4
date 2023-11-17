#include "snmpconnection.h"

SNMPConnection::SNMPConnection(QObject *parent)
    : TObject{parent},
    pHandle(NULL),
    _state( Disconnected ),
    isBusy(false),
    requests({})
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

void SNMPConnection::proceed( AsyncSNMP* request )
{
    if ( request == nullptr ) return;
    if ( isBusy )
    {
        requests.append( request );
        return;
    }
    else isBusy = true;

    QThreadPool::globalInstance()->start( request );
}

void SNMPConnection::getOIDs( QString uid, QList<QString> objects )
{
    QList< SNMPpp::OID > oids;
    AsyncSNMP *request = new AsyncSNMP( pHandle, SNMPpp::PDU::kGet );

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
    proceed( request );
}

void SNMPConnection::handleSNMPRequest( QString root, QMap<SNMPpp::OID, QJsonObject> rows )
{
    isBusy = false;

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

    if ( requests.empty() ) return;
    proceed( requests.first() );
    requests.removeFirst();
}

void SNMPConnection::getTable( QString objectName )
{
    QList<QString> combinedName = objectName.split( "." );
    QList<QString> combined = objectName.split( combinedName.first() );
    if ( combined.length() != 1 ) combined.removeFirst();

    oid_object object = parser.MIB_OBJECTS[ combinedName.first() ];
    SNMPpp::OID start(
        object.oid.toStdString() +
        combined.first().toStdString()
    );
    AsyncSNMP *request = new AsyncSNMP( pHandle, SNMPpp::PDU::kGetBulk );
    request->setBounds( start );
    request->setUID( objectName );

    connect( request, &AsyncSNMP::rows, this, &SNMPConnection::handleSNMPRequest );
    proceed( request );
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

        getOIDs( "", { "stSNMPVersion" } );
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
