pragma Singleton

import QtQuick
import QtQuick.Controls.Material

QtObject
{
    property string currentPage: pages[0]
    property var pages: [ "Pages/Connection.qml" ]
}
