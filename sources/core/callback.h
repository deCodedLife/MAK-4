#pragma once

#include <QObject>

class Callback
{
public:
    Callback();

    static int None;
    static int Error;
    static int Warning;
    static int Info;

    static Callback& New( QString event = "", int type = Callback::None );

public:
    int     GetType();
    QString GetEvent();

protected:
    QString m_event;
    int m_type;
};
