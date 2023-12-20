#include "mibparser.h"

std::string MibParser::get_parent_id( tree *parent, std::string oid )
{
    if ( parent == nullptr ) return oid;
    if ( oid == "" ) oid = std::to_string( parent->subid );
    else oid = std::to_string( parent->subid ) + "." + oid;
    return get_parent_id( parent->parent, oid );
}

void MibParser::parse_tree( tree *node, bool is_child = false )
{
    if ( node == nullptr ) return;
    MIB_OBJECTS[ node->label ] = oid_object {
        QVariant::fromValue( node->defaultValue ),
        node->label,
        get_parent_id( node ),
        node->description != nullptr ? node->description : "",
        (size_t) node->type
    };
    if ( !is_child ) parse_tree( node->next );
    parse_tree( node->child_list, true );
    parse_tree( node->next_peer, true );
}


MibParser::MibParser(QString file_path, QObject *parent)
    : TObject{parent}
{
    std::string mib_path = QDir::currentPath().toStdString() + "/mibs";

    netsnmp_set_mib_directory( mib_path.c_str() );
    netsnmp_init_mib();
    netsnmp_init_mib_internals();

    struct tree *nodes = nullptr;
    nodes = read_all_mibs();

    if ( nodes == nullptr ) {
        emit error_occured( Callback::New( "Can't read default mib file", Callback::Error ) );
        exit(-1);
        return;
    }

    size_t maxLength = MAX_OID_LEN;
    oid snmpVersion[ maxLength];

    parse_tree( nodes );
}

MibParser::~MibParser()
{
    shutdown_mib();
}
