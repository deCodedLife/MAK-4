#ifndef ASYNCSNMP_H
#define ASYNCSNMP_H

#include <tobject.h>
#include <QThread>

#include <SNMPpp/PDU.hpp>
#include <SNMPpp/Get.hpp>
//#include <SNMPpp/OID.hpp>

#include <QJsonArray>
#include <QJsonObject>

#include <QRunnable>

struct TableHead
{
    SNMPpp::OID oid;
    int count;
};

class AsyncSNMP : public QObject, public QRunnable
{
    Q_OBJECT

signals:
    void finished( int rowsCount );
    void rows( SNMPpp::OID root, QMap<SNMPpp::OID, QJsonObject> );

public:
    explicit AsyncSNMP( QObject *parent = nullptr );

    void setOIDs( SNMPpp::SessionHandle&, SNMPpp::OID from, SNMPpp::OID to = "" );
    void run() override;

private:
    SNMPpp::SessionHandle session;
    SNMPpp::OID startFrom;
    SNMPpp::OID endAt;

};

#endif // ASYNCSNMP_H
