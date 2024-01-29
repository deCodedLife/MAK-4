#include "mibparser.h"

std::string MibParser::get_parent_id( const tree *parent, std::string oid )
{
    if ( parent == nullptr ) return oid;
    if ( oid == "" ) oid = std::to_string( parent->subid );
    else oid = std::to_string( parent->subid ) + "." + oid;
    return get_parent_id( parent->parent, oid );
}

void getEnums( enum_list *e, QMap<QString, int> *map ) {
    if ( e == nullptr ) return;
    map->insert( QString::fromStdString( e->label ), e->value );
    getEnums( e->next, map );
}

void MibParser::parseTree( const tree *node, SNMPpp::OID o )
{
    if ( node == nullptr ) return;
    o += node->subid;

    if ( root.isParentOf( o ) )
    {
        QString label = QString::fromStdString( node->label != nullptr ? node->label : "" );
        QMap<QString, int> enums;
        getEnums( node->enums, &enums );

        MIB_OBJECTS[ label ] = oid_object {
            QVariant::fromValue( node->defaultValue != nullptr ? node->defaultValue : "" ),
            label,
            QString::fromStdString( o.to_str() ),
            QString::fromStdString( node->description == nullptr ? "" : node->description ),
            (size_t) node->type,
            enums
        };

        OID_TOSTR[ o ] = label;
    }

    parseTree( node->child_list, o );
    parseTree( node->next_peer, o.parent() );
}

tree *MibParser::findModule( tree *mib, char *module )
{
    if ( mib->label != nullptr  )
    {
        if ( mib->label == module )
            return mib;
        if ( mib->child_list != nullptr ) return findModule( mib->child_list, module );
        if ( mib->next_peer != nullptr ) return findModule( mib->next_peer, module );
    }
}


MibParser::MibParser(QString file_path, QObject *parent)
    : TObject{parent}
{
    root = SNMPpp::OID( "1.3.6.1.4.1.36032" );
    std::string mib_path = QDir::currentPath().toStdString() + "/mibs";

    // add_mibdir( mib_path.c_str() );
    // snmp_set_save_descriptions(1);
    // netsnmp_set_mib_directory( mib_path.c_str() );

    netsnmp_init_mib();
    netsnmp_init_mib_internals();

    mib_path += "/";
    mib_path += MIB_PATH;

    const struct tree *nodes = read_mib( mib_path.c_str() );

    if ( nodes == nullptr ) {
        emit error_occured( Callback::New( "Can't read default mib file", Callback::Error ) );
        exit(-1);
        return;
    }

    parseTree( nodes, SNMPpp::OID() );
}

MibParser::~MibParser()
{
    shutdown_mib();
}

QJsonObject MibParser::getObject( QString field )
{
    return oid_object::ToJSON( MIB_OBJECTS[ field ] );
}

SNMPpp::OID MibParser::ToOID( QString object )
{
    SNMPpp::OID oidObject;
    QStringList pathItems = object.split( "." );

    for( QString item : pathItems )
    {
        bool isNumber = true;
        uint itemNum = item.toUInt( &isNumber );

        if ( isNumber )
        {
            oidObject += itemNum;
            continue;
        }

        oidObject = SNMPpp::OID( MIB_OBJECTS[ item ].oid.toStdString() );
    }

    return oidObject;
}

QString MibParser::FromOID( SNMPpp::OID oid )
{
    QStringList objectName;


    if ( OID_TOSTR.contains( oid ) )
    {
        return OID_TOSTR[ oid ];
    }

    SNMPpp::OID currentOID = oid;
    while ( !currentOID.empty() )
    {
        QString currentName = QString::fromStdString( currentOID.to_str() );
        objectName.push_front( "." + currentName.split( "." ).last() );
        currentOID = currentOID.parent();

        if ( OID_TOSTR.contains( currentOID ) )
        {
            objectName.push_front( OID_TOSTR[ currentOID ] );
            return objectName.join("");
        }
    }

    return objectName.join("");
}
