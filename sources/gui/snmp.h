#ifndef SNMP_H
#define SNMP_H

#include <tobject.h>

class SNMP : public TObject
{
public:
    explicit SNMP(QObject *parent = nullptr);
};

#endif // SNMP_H
