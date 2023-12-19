#include "ipaddressvalidator.h"

IPAddressValidator::IPAddressValidator(QObject *parent)
{
    QString ipRange = "(?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])";
    QString expr = "^" + ipRange
                   + "\\." + ipRange
                   + "\\." + ipRange
                   + "\\." + ipRange + "$";
    QRegularExpression ipRegex (expr);

    setRegularExpression( ipRegex );
}
