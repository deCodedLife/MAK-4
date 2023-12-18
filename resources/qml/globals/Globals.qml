pragma Singleton

import QtQuick
import QtQuick.Controls.Material

QtObject
{
    property string windowSuffix: ""

    property string accentColor: "#116FCF"
    property string secondaryColor: "#2386EB"
    property string backgroundColor: "#F5F8FA"
    property string errorColor: "#ED1921"
    property string succsessColor: "#45CC52"
    property string yellow: "#F1DD23"

    property string grayAccent: "#8D8D8D"
    property string textColor: "#505050"
    property string grayScale: "#D9D9D9"

    property int dpi: Screen.PixelDensity * 25.4

    function dp(x)
    {
        if ( dpi < 120 ) return x;
        return x * (dpi / 160)
    }

    function fontDp(x)
    {
        var platform = Qt.platform.os

        if (  platform === "android" || platform === "ios" ) return dp(x) * 1.2
        if ( platform === "windows" ) return( dp(x) * 0.8 )
        else return dp(x)
    }

    property int h1: fontDp(24)
    property int h2: fontDp(20)
    property int h3: fontDp(18)
    property int h4: fontDp(16)
    property int h5: fontDp(14)
    property int h6: fontDp(12)
}
