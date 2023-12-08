#pragma once

#include <QThread>
#include <QFuture>
#include <QPromise>

#include <QThreadPool>
#include <QtConcurrent/QtConcurrent>

#include <tobject.h>
#include <configs.h>

#include <SNMPpp/Session.hpp>
#include <SNMPpp/Get.hpp>
#include <SNMPpp/Set.hpp>
#include <SNMPpp/net-snmppp.hpp>

#include "mibparser.h"
#include "asyncsnmp.h"

enum States {
    Disconnected,
    Connected,
    SyncConfigs
};

class SNMPConnection : public TObject
{
    Q_OBJECT
    Q_ENUM( States )

signals:
    void stateChanged( States );

    void settingsChanged();
    void gotTablesCount( QString, int );
    void gotRowsContent( QString, QJsonObject );

    void launchThreadPool();
    void notify(int status, QString message, int delay_ms);

public:
    explicit SNMPConnection(QObject *parent = nullptr);
    ~SNMPConnection();
    void SetConfig( Configs* );
    MibParser* GetParser();

    Q_INVOKABLE States state();
    Q_INVOKABLE void setState( States );

    Q_INVOKABLE void getOIDs( QString uid, QList<QString> );
    Q_INVOKABLE void getTable( QString oid );
    Q_INVOKABLE void setOID( QString, QVariant );
    Q_INVOKABLE void setMultiple( QJsonObject );
    Q_INVOKABLE void updateConfigs();

    Q_INVOKABLE QString dateToReadable( QString );
    Q_INVOKABLE QJsonArray getGroup( QString );

    QMap< int, QString > errors;

public slots:
    Q_INVOKABLE void updateConnection();
    Q_INVOKABLE void dropConnection();
    void proceed( AsyncSNMP* );
    void handleSNMPRequest( QString, QMap<SNMPpp::OID, QJsonObject> );
    void handleSNMPFinished( int );

private:
    void initFields();
    void parseBulk( variable_list *vars, SNMPpp::OID root, QJsonArray *items );
    QVariant getFieldValue( QString );

private:
    SNMPpp::SessionHandle readSession;
    SNMPpp::SessionHandle writeSession;

    Configs *pConfigs;
    States _state;
    MibParser parser;

    bool isBusy;
    QList<AsyncSNMP*> requests;

};
