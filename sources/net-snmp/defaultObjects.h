#pragma once

#include <QMap>
#include <QStringList>

#define ENTERENCE "1.3.6.1.4.1.36032"

std::string concat( const std::string reference, uint value ) {
    return reference + '.' + std::to_string(value);
}

QMap<std::string, std::string> GetAllOIDs()
{
    QMap<std::string, std::string> OIDs;
    OIDs[ "promSD" ] = ENTERENCE;
    OIDs[ "psMAK4" ] = concat( OIDs[ "promSD" ], 1 );
    OIDs[ "psCommon" ] = concat( OIDs[ "psMAK4" ], 1 );
    OIDs[ "psEvents" ] = concat( OIDs[ "psMAK4" ], 2 );
    OIDs[ "psLoad" ] = concat( OIDs[ "psMAK4" ], 3 );
    OIDs[ "psBattery" ] = concat( OIDs[ "psMAK4" ], 4 );
    OIDs[ "psContactors" ] = concat( OIDs[ "psMAK4" ], 5 );
    OIDs[ "psVbvs" ] = concat( OIDs[ "psMAK4" ], 6 );
    OIDs[ "psMains" ] = concat( OIDs[ "psMAK4" ], 7 );
    OIDs[ "psTemperature" ] = concat( OIDs[ "psMAK4" ], 8 );
    OIDs[ "psSwitches" ] = concat( OIDs[ "psMAK4" ], 9 );
    OIDs[ "psSettings" ] = concat( OIDs[ "psMAK4" ], 10 );

    OIDs[ "psCommonSetting" ] = concat( OIDs[ "psSettings" ], 1 );
    OIDs[ "psAlarmsMasks" ] = concat( OIDs[ "psSettings" ], 2 );
    OIDs[ "psAlarms1Masks" ] = concat( OIDs[ "psAlarmsMasks" ], 1 );
    OIDs[ "psAlarms2Masks" ] = concat( OIDs[ "psAlarmsMasks" ], 2 );

    OIDs[ "psRelay1Masks" ] = concat( OIDs[ "psAlarmsMasks" ], 3 );
    OIDs[ "psRelay2Masks" ] = concat( OIDs[ "psAlarmsMasks" ], 4 );
    OIDs[ "psRelay3Masks" ] = concat( OIDs[ "psAlarmsMasks" ], 5 );
    OIDs[ "psRelay4Masks" ] = concat( OIDs[ "psAlarmsMasks" ], 6 );

    OIDs[ "psBatterySettings" ] = concat( OIDs[ "psSettings" ], 3 );
    OIDs[ "psBatteryShortTestSettings" ] = concat( OIDs[ "psSettings" ], 4 );
    OIDs[ "psContactorSettings" ] = concat( OIDs[ "psSettings" ], 5 );
    OIDs[ "psMainsSettings" ] = concat( OIDs[ "psSettings" ], 6 );
    OIDs[ "psTemperatureSettings" ] = concat( OIDs[ "psSettings" ], 7 );
    OIDs[ "psConfiguration" ] = concat( OIDs[ "psSettings" ], 8 );
    OIDs[ "psNetworkSettings" ] = concat( OIDs[ "psSettings" ], 9 );
    OIDs[ "psSecuritySettings" ] = concat( OIDs[ "psSettings" ], 10 );
    OIDs[ "psSNMPSettings" ] = concat( OIDs[ "psSettings" ], 11 );
    OIDs[ "psBMS" ] = concat( OIDs[ "psMAK4" ], 11 );

    return OIDs;
}
