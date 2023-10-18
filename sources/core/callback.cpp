#include "callback.h"

int Callback::None = 0;
int Callback::Error = 1;
int Callback::Warning = 2;
int Callback::Info = 3;

Callback::Callback() {}

Callback& Callback::New( QString event, int type )
{
    Callback *cb = new Callback();
    cb->m_type = type;
    cb->m_event = event;
    return *cb;
}

int Callback::GetType()
{
    return m_type;
}

QString Callback::GetEvent()
{
    return m_event;
}

