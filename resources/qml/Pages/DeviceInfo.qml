import QtQuick

import "../Components"
import "../Globals"

Page
{
    property var configuration: Config[ "fields" ]
    property list<var> rows: [
        configuration[ "deviceInfo0" ],
        configuration[ "psSerial" ],
        configuration[ "deviceInfo1" ],
        configuration[ "psDescription" ],
        configuration[ "deviceInfo2" ],
        configuration[ "psFWRevision" ],
        configuration[ "deviceInfo3" ],
        configuration[ "psTime" ],
    ]
}
