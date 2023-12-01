#ifndef ASYNCSNMP_H
#define ASYNCSNMP_H

#include <tobject.h>
#include <QRunnable>

#include <SNMPpp/PDU.hpp>
#include <SNMPpp/Get.hpp>

#include <QJsonArray>
#include <QJsonObject>

class AsyncSNMP : public QObject, public QRunnable
{
    Q_OBJECT

signals:
    void finished( int rowsCount );
    void rows( QString, QMap<SNMPpp::OID, QJsonObject> );

public:
    explicit AsyncSNMP( SNMPpp::SessionHandle&, SNMPpp::PDU::EType = SNMPpp::PDU::kGet, QObject *parent = nullptr );
    void setBounds( SNMPpp::OID from, SNMPpp::OID to = "" );
    void setOIDs( QList<SNMPpp::OID> );
    void setUID( QString );
    void worker( SNMPpp::PDU );

    void run() override;

private:
    SNMPpp::SessionHandle session;
    SNMPpp::PDU::EType type;

    SNMPpp::OID startFrom;
    SNMPpp::OID endAt;

    int limit {10};
    QString uid;
    QList<SNMPpp::OID> request {};
    QMap<SNMPpp::OID, QJsonObject> fields;

};

#endif // ASYNCSNMP_H
