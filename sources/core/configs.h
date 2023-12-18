#pragma once

#define CONFIG_FILE "config.m4ss"

// 0 - SNMP 2, 1 - SNMP3
#define SNMP_VERSION "snmpV3"
#define HOST "185.51.21.124"//185.51.21.124
#define PORT "16190"
#define USER "user000001"
#define AUTH_METHOD "authPriv"
#define AUTH_PROTOCOL "MD5"
#define PRIV_PROTOCOL "AES"
#define AUTH_PASSWORD "0000000001"
#define PRIV_PASSWORD "0000000011"
#define UPDATE_DELAY 3

// SNMP SETTINGS
#define ST_SNMP_VERSION "snmpV3"
#define ST_SNMP_AUTH_ALGO "MD5"
#define ST_SNMP_PRIV_ALGO "AES128"

#define V2_READ  "public"
#define V2_WRITE "changeit"


#include <QFile>
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QStringList>

#include "tobject.h"

enum FieldTypes
{
    FieldText,        //0
    FieldDescription, //1
    FieldInput,       //2
    FieldPassword,    //3
    FieldCombobox,    //4
    FieldSwitch,      //5
    FieldCounter,     //6
    FieldCheckbox     //7
};

struct Field
{
    FieldTypes type;
    QVariant value;
    QString description;
    QJsonObject model;

    int min {-1};
    int max {-1};

    QString field;

    static QJsonObject ToJSON( Field f )
    {
        QJsonObject field;
        field[ "type" ] = f.type;
        field[ "value" ] = QJsonValue::fromVariant( f.value );
        field[ "description" ] = f.description;
        field[ "model" ] = f.model;
        field[ "filed" ] = f.field;
        if ( f.min != -1 ) field[ "min" ] = f.min;
        if ( f.max != -1 ) field[ "max" ] = f.max;
        return field;
    };
    static Field FromJSON( QJsonObject obj )
    {
        Field f;
        f.type = (FieldTypes) obj[ "type" ].toInt();
        f.value = obj[ "value" ].toVariant();
        f.description = obj[ "description" ].toString();
        f.model = obj[ "model" ].toObject();
        f.field = obj[ "field" ].toString();
        if ( obj.contains( "min" ) ) f.min = obj[ "min" ].toInt();
        if ( obj.contains( "max" ) ) f.min = obj[ "max" ].toInt();
        return f;
    }
};

struct oid_object
{
    QVariant value;
    QString label;
    QString oid;
    QString description;
    size_t type;
    QMap<QString, int> enums;

    static QJsonObject ToJSON( oid_object f )
    {
        QJsonObject field;
        field[ "value" ] = f.value.toJsonValue();
        field[ "label" ] = f.label;
        field[ "oid" ] = f.oid;
        field[ "description" ] = f.description;
        field[ "type" ] = (int) f.type;
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
