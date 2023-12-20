#include "mibparser.h"

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/mib_api.h>
#include <net-snmp/library/mib.h>

#include <QDir>
#include <QFile>
#include <iostream>

std::string get_parent_id( tree *parent, std::string oid = "" )
{
    if ( parent == nullptr ) return oid;
    if ( oid == "" ) oid = std::to_string( parent->subid );
    else oid = std::to_string( parent->subid ) + "." + oid;
    return get_parent_id( parent->parent, oid );
}

void print_tree( tree *node, bool is_child = false ) {

    if ( node == nullptr ) return;
    qDebug() << node->label << " " << QString::fromStdString( get_parent_id( node ) );
    if ( !is_child ) print_tree( node->next );
    print_tree( node->child_list, true );
}


MibParser::MibParser(QString file_path, QObject *parent)
    : TObject{parent}
{
    std::string mib_path = QDir::currentPath().toStdString() + "/mibs";

    netsnmp_set_mib_directory( mib_path.c_str() );
    netsnmp_init_mib();
    netsnmp_init_mib_internals();

    read_all_mibs();

    oid anOID[MAX_OID_LEN];
    size_t requestOidLength = MAX_OID_LEN;

    read_objid( "psSNMPSettings", anOID, &requestOidLength );
    print_objid( anOID, requestOidLength );

    qDebug() << *anOID;
}

MibParser::~MibParser()
{
    shutdown_mib();
}
