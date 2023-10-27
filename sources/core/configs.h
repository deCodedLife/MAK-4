#pragma once

#define CONFIG_FILE "config.m4ss"

// 0 - SNMP 2, 1 - SNMP3
#define SNMP_VERSION 1
//#define HOST "udp:185.51.21.124:16190"
#define HOST "185.51.21.124"
#define PORT "16190"
#define USER "user000001"
#define AUTH_METHOD "authPriv"
#define AUTH_PROTOCOL "MD5"
#define PRIV_PROTOCOL "AES"
#define AUTH_PASSWORD "0000000001"
#define PRIV_PASSWORD "0000000011"
#define UPDATE_DELAY 3

#define V2_READ  "public"
#define V2_WRITE "changeit"


#include <QFile>
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QStringList>

#include "tobject.h"

enum FieldTypes {
    FieldInput,
    FieldCombobox,
    FieldCheckbox
};

struct Field {
    int type;
    QVariant value;
    QString description;
    QStringList model;

    static QJsonObject ToJSON( Field f ) {
        QJsonObject field;
        field[ "type" ] = f.type;
        field[ "value" ] = QJsonValue::fromVariant( f.value );
        field[ "description" ] = f.description;
        field[ "model" ] = QJsonValue::fromVariant( f.model );
        return field;
    };
};


class Configs : public TObject
{
    Q_OBJECT
    Q_PROPERTY( QJsonObject current READ get WRITE write NOTIFY updated )
signals:
    void updated( QJsonObject );

public:
    Configs( QString file = CONFIG_FILE, QObject *parent = nullptr );
    ~Configs();

    Q_INVOKABLE QJsonObject get();
    Q_INVOKABLE void write( QJsonObject );

    void Read( QJsonObject* );
    static QJsonObject Default();

private:
    bool isValid( QJsonObject );

private slots:
    void closeFile();

private:
    QFile *m_file;
    QString m_fileName;
    QJsonObject config;

};
