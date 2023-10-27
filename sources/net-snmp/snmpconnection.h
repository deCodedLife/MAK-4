#ifndef SNMPCONNECTION_H
#define SNMPCONNECTION_H

#include <tobject.h>
#include <configs.h>

#include <SNMPpp/Session.hpp>

class SNMPConnection : public TObject
{
public:
    explicit SNMPConnection(QObject *parent = nullptr);
    ~SNMPConnection();
    void SetConfig( Configs* );

public slots:
    void UpdateConnection();

private:
    SNMPpp::SessionHandle pHandle;
    Configs *pConfigs;
};

#endif // SNMPCONNECTION_H
