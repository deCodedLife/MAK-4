#pragma once

#include <QFile>
#include <QDateTime>
#include <QObject>
#include <QDir>

#include "callback.h"

#define LOG_FILE "_log.txt"
#define LOG_DIR  "logs"

class TObject : public QObject
{
    Q_OBJECT

signals:
    void error_occured( Callback );

public:
    explicit TObject( QObject *parent = nullptr );
    ~TObject();

private slots:
    void handleError( Callback );

protected:
    void writeLog( QString data, int type );

protected:
    QString m_sender;
    QFile *m_file;

};
