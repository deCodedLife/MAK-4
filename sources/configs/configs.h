#pragma once

#define CONFIG_FILE "cfg.dat"

#define mak_ip ""

#include <QFile>
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

#include <tobject.h>

class Configs : public TObject
{
    Q_OBJECT
public:
    Configs( QString file = CONFIG_FILE, QObject *parent = nullptr );

    void Read( QJsonObject* );
    void Write( QJsonObject );

    static QJsonObject Default();

private:
    bool isValid( QJsonObject );

private slots:
    void closeFile();

private:
    QFile *m_file;
    QString m_fileName;

};
