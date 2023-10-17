#pragma once

#include <QFile>
#include <QDateTime>
#include <QObject>

#include "callback.h"

#define LOG_FILE "_log.txt"

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
