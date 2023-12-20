#pragma once

#include <tobject.h>
#include <configs.h>

#include <SNMPpp/Session.hpp>
#include <SNMPpp/Get.hpp>
#include <SNMPpp/Set.hpp>

#include "mibparser.h"

enum States {
    Disconnected,
    Connected
};

class SNMPConnection : public TObject
{
    Q_OBJECT
    Q_ENUM( States )

signals:
    void stateChanged( States );

public:
    explicit SNMPConnection(QObject *parent = nullptr);
    ~SNMPConnection();
    void SetConfig( Configs* );

    Q_INVOKABLE States state();
    Q_INVOKABLE void setState( States );

    Q_INVOKABLE QVariant getOID( QString );
    Q_INVOKABLE void setOID( QString, QVariant );

public slots:
    Q_INVOKABLE void updateConnection();
    Q_INVOKABLE void dropConnection();

private:
    void initFields();
    QVariant getFieldValue( QString );

private:
    SNMPpp::SessionHandle pHandle;
    Configs *pConfigs;
    States _state;
    MibParser parser;

};
