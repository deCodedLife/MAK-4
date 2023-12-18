#ifndef CUSTOMDOUBLEVALIDATOR_H
#define CUSTOMDOUBLEVALIDATOR_H

#include <QObject>
#include <QDoubleValidator>

class CustomDoubleValidator : public QDoubleValidator
{
    Q_OBJECT
public:
     explicit CustomDoubleValidator(QObject * parent = nullptr);

signals:
};

#endif // CUSTOMDOUBLEVALIDATOR_H
