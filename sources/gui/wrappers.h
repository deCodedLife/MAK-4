#ifndef WRAPPERS_H
#define WRAPPERS_H

#include <tobject.h>

class Wrappers : public TObject
{
    Q_OBJECT

public:
    explicit Wrappers(QObject *parent = nullptr);

    Q_INVOKABLE QString windowsStringParser( QString );

private:
    QMap<QString, QString> winCodec;
};

#endif // WRAPPERS_H
