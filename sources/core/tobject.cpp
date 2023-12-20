#include "tobject.h"

TObject::TObject(QObject *parent)
    : QObject{parent}
{
    connect( this, &TObject::error_occured, this, &TObject::handleError );
    if ( !QDir( LOG_DIR ).exists() ) QDir().mkdir( LOG_DIR );
    QList<QString> filePath = { LOG_DIR, QDate::currentDate().toString("yyyy.MM.dd"), LOG_FILE };
    m_file = new QFile( filePath.join( "/" ) );
}

TObject::~TObject()
{
    m_file->close();
}

void TObject::handleError( Callback cb )
{
    writeLog( cb.GetEvent(), cb.GetType() );
}

void TObject::writeLog( QString data, int type )
{
    QStringList log;

    if ( type == Callback::Error ) log << "[!]";
    if ( type == Callback::Warning ) log << "[-]";
    if ( type == Callback::Info ) log << "[ ]";
    if ( type == Callback::None ) return;

    log << QTime::currentTime().toString( "HH:mm:ss" ) << "[" << m_sender << "]" << data;
    qDebug() << log.join(" ");

    if ( !m_file->open( QIODevice::Append ) )
    {
        return;
    }

    log << "\n";
    m_file->write( log.join(" ").toUtf8() );
    m_file->close();

}
