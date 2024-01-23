#pragma once

#include <tobject.h>
#include <QRunnable>
//#include <string>

#include <SNMPpp/PDU.hpp>
#include <SNMPpp/Get.hpp>
#include <SNMPpp/Set.hpp>

#include <QJsonArray>
#include <QJsonObject>


/**
 * Simple configuration for providing
 * @brief The RequestConfig class
 */
struct RequestConfig
{
    SNMPpp::SessionHandle *session;
    SNMPpp::PDU pdu;
    SNMPpp::OID bulkObject;

    // Max oid's which device can handle
    int deviceBuffer = 10;
};


/**
 * SNMP Reply template
 */
typedef struct
{
    SNMPpp::OID oid;
    int numValue;
    std::string strValue;
} Reply;



/**
 * SNMP requests functions
 */
void ReplyToJSON( const Reply, QJsonObject* );
void parsePDU( const SNMPpp::PDU, std::vector<Reply> *reply, SNMPpp::OID *eof = nullptr );
void buffered( const RequestConfig request, int buffIndex, SNMPpp::PDU *pdu );
bool AsyncSet( RequestConfig request );
bool AsyncGet( RequestConfig request, std::vector<Reply> *reply );
bool AsyncGetBulk( RequestConfig request, std::vector<Reply> *reply );
bool AsyncRequest( RequestConfig request, std::vector<Reply> *reply );
void ParseCodec( const std::string data, QString *buff );


/**
 * This class should be called in separated thread using
 * QThreadPool::globalInstance()->start( CLASS_NAME );
 * @brief The AsyncSNMP class
 */
class AsyncSNMP : public QObject, public QRunnable
{
    Q_OBJECT
signals:
    void finished( QString uid, QMap<SNMPpp::OID, QJsonObject> rows );
    void gotError( int errorCode );

public:
    explicit AsyncSNMP( QString uid, RequestConfig, QObject *parent = nullptr );
    void run() override;

private:
    QString uniqueRequestID;
    RequestConfig request;

};

