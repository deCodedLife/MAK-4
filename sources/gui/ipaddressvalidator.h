#ifndef IPADDRESSVALIDATOR_H
#define IPADDRESSVALIDATOR_H

#include <QObject>
#include <QRegularExpressionValidator>

class IPAddressValidator : public QRegularExpressionValidator
{
    Q_OBJECT
public:
    explicit IPAddressValidator(QObject *parent = nullptr);

signals:
};

#endif // IPADDRESSVALIDATOR_H
