#pragma once

#include <QObject>
#include <tobject.h>

#define MIB_PATH "default.mib"

class MibParser : public TObject
{
    Q_OBJECT
public:
    explicit MibParser(QString file_path = MIB_PATH, QObject *parent = nullptr);
    ~MibParser();

signals:

};
