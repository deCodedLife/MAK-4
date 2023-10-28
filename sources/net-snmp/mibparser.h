#pragma once

#include <QObject>
#include <tobject.h>
#include <configs.h>

#include <QDir>
#include <QFile>
#include <SNMPpp/Varlist.hpp>

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/mib_api.h>
#include <net-snmp/library/mib.h>

#define MIB_PATH "default.mib"

class MibParser : public TObject
{
    Q_OBJECT
public:
    explicit MibParser(QString file_path = MIB_PATH, QObject *parent = nullptr);
    ~MibParser();

    QMap<QString, oid_object> MIB_OBJECTS;

private:
    void parse_tree( tree *mib, bool isChild);
    std::string get_parent_id( tree *parent, std::string oid = "");


};
