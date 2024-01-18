#include "wrappers.h"

Wrappers::Wrappers(QObject *parent)
    : TObject{parent}
{
    winCodec[ "80" ] = "Ђ";
    winCodec[ "81" ] = "Ѓ";
    winCodec[ "82" ] = "‚";
    winCodec[ "83" ] = "ѓ";
    winCodec[ "84" ] = "„";
    winCodec[ "85" ] = "…";
    winCodec[ "86" ] = "†";
    winCodec[ "87" ] = "‡";
    winCodec[ "88" ] = "€";
    winCodec[ "89" ] = "‰";
    winCodec[ "8A" ] = "Љ";
    winCodec[ "8B" ] = "‹";
    winCodec[ "8C" ] = "Њ";
    winCodec[ "8D" ] = "Ќ";
    winCodec[ "8E" ] = "Ћ";
    winCodec[ "8F" ] = "Џ";
    winCodec[ "90" ] = "ђ";
    winCodec[ "91" ] = "‘";
    winCodec[ "92" ] = "’";
    winCodec[ "93" ] = "“";
    winCodec[ "94" ] = "”";
    winCodec[ "95" ] = "•";
    winCodec[ "96" ] = "–";
    winCodec[ "97" ] = "—";
    winCodec[ "98" ] = " ";
    winCodec[ "99" ] = "™";
    winCodec[ "9A" ] = "љ";
    winCodec[ "9B" ] = "›";
    winCodec[ "9C" ] = "њ";
    winCodec[ "9D" ] = "ќ";
    winCodec[ "9E" ] = "ћ";
    winCodec[ "9F" ] = "џ";
    winCodec[ "A0" ] = " ";
    winCodec[ "A1" ] = "Ў";
    winCodec[ "A2" ] = "ў";
    winCodec[ "A3" ] = "Ћ";
    winCodec[ "A4" ] = "¤";
    winCodec[ "A5" ] = "Ґ";
    winCodec[ "A6" ] = "¦";
    winCodec[ "A7" ] = "§";
    winCodec[ "A8" ] = "Ё";
    winCodec[ "A9" ] = "©";
    winCodec[ "AA" ] = "Є";
    winCodec[ "AB" ] = "«";
    winCodec[ "AC" ] = "¬";
    winCodec[ "AD" ] = " ";
    winCodec[ "AE" ] = "®";
    winCodec[ "AF" ] = "Ї";
    winCodec[ "B0" ] = "°";
    winCodec[ "B1" ] = "±";
    winCodec[ "B2" ] = "І";
    winCodec[ "B3" ] = "і";
    winCodec[ "B4" ] = "ґ";
    winCodec[ "B5" ] = "µ";
    winCodec[ "B6" ] = "¶";
    winCodec[ "B7" ] = "·";
    winCodec[ "B8" ] = "ё";
    winCodec[ "B9" ] = "№";
    winCodec[ "BA" ] = "є";
    winCodec[ "BB" ] = "»";
    winCodec[ "BC" ] = "ј";
    winCodec[ "BD" ] = "Ѕ";
    winCodec[ "BE" ] = "ѕ";
    winCodec[ "BF" ] = "ї";
    winCodec[ "C0" ] = "А";
    winCodec[ "C1" ] = "Б";
    winCodec[ "C2" ] = "В";
    winCodec[ "C3" ] = "Г";
    winCodec[ "C4" ] = "Д";
    winCodec[ "C5" ] = "Е";
    winCodec[ "C6" ] = "Ж";
    winCodec[ "C7" ] = "З";
    winCodec[ "C8" ] = "И";
    winCodec[ "C9" ] = "Й";
    winCodec[ "CA" ] = "К";
    winCodec[ "CB" ] = "Л";
    winCodec[ "CC" ] = "М";
    winCodec[ "CD" ] = "Н";
    winCodec[ "CE" ] = "О";
    winCodec[ "CF" ] = "П";
    winCodec[ "D0" ] = "Р";
    winCodec[ "D1" ] = "С";
    winCodec[ "D2" ] = "Т";
    winCodec[ "D3" ] = "У";
    winCodec[ "D4" ] = "Ф";
    winCodec[ "D5" ] = "Х";
    winCodec[ "D6" ] = "Ц";
    winCodec[ "D7" ] = "Ч";
    winCodec[ "D8" ] = "Ш";
    winCodec[ "D9" ] = "Щ";
    winCodec[ "DA" ] = "Ъ";
    winCodec[ "DB" ] = "Ы";
    winCodec[ "DC" ] = "Ь";
    winCodec[ "DD" ] = "Э";
    winCodec[ "DE" ] = "Ю";
    winCodec[ "DF" ] = "Я";
    winCodec[ "E0" ] = "а";
    winCodec[ "E1" ] = "б";
    winCodec[ "E2" ] = "в";
    winCodec[ "E3" ] = "г";
    winCodec[ "E4" ] = "д";
    winCodec[ "E5" ] = "е";
    winCodec[ "E6" ] = "ж";
    winCodec[ "E7" ] = "з";
    winCodec[ "E8" ] = "и";
    winCodec[ "E9" ] = "й";
    winCodec[ "EA" ] = "к";
    winCodec[ "EB" ] = "л";
    winCodec[ "EC" ] = "м";
    winCodec[ "ED" ] = "н";
    winCodec[ "EE" ] = "о";
    winCodec[ "EF" ] = "п";
    winCodec[ "F0" ] = "р";
    winCodec[ "F1" ] = "с";
    winCodec[ "F2" ] = "т";
    winCodec[ "F3" ] = "у";
    winCodec[ "F4" ] = "ф";
    winCodec[ "F5" ] = "х";
    winCodec[ "F6" ] = "ц";
    winCodec[ "F7" ] = "ч";
    winCodec[ "F8" ] = "ш";
    winCodec[ "F9" ] = "щ";
    winCodec[ "FA" ] = "ъ";
    winCodec[ "FB" ] = "ы";
    winCodec[ "FC" ] = "ь";
    winCodec[ "FD" ] = "э";
    winCodec[ "FE" ] = "ю";
    winCodec[ "FF" ] = "я";
    winCodec[ "20" ] = " ";
    winCodec[ "21" ] = "!";
    winCodec[ "22" ] = "'";
    winCodec[ "23" ] = "#";
    winCodec[ "24" ] = "$";
    winCodec[ "25" ] = "%";
    winCodec[ "26" ] = "&";
    winCodec[ "27" ] = "'";
    winCodec[ "28" ] = "(";
    winCodec[ "29" ] = ")";
    winCodec[ "2A" ] = "*";
    winCodec[ "2B" ] = "+";
    winCodec[ "2C" ] = ",";
    winCodec[ "2D" ] = "-";
    winCodec[ "2E" ] = ".";
    winCodec[ "2F" ] = "/";
    winCodec[ "30" ] = "0";
    winCodec[ "31" ] = "1";
    winCodec[ "32" ] = "2";
    winCodec[ "33" ] = "3";
    winCodec[ "34" ] = "4";
    winCodec[ "35" ] = "5";
    winCodec[ "36" ] = "6";
    winCodec[ "37" ] = "7";
    winCodec[ "38" ] = "8";
    winCodec[ "39" ] = "9";
    winCodec[ "3A" ] = ":";
    winCodec[ "3B" ] = ";";
    winCodec[ "3C" ] = "<";
    winCodec[ "3D" ] = "=";
    winCodec[ "3E" ] = ">";
    winCodec[ "3F" ] = "?";
    winCodec[ "0A" ] = "\n";
    winCodec[ "09" ] = "\t";


}

QString Wrappers::windowsStringParser( QString input )
{
    // Get HEX values
    QList<QString> keys = input.split( " " );

    QString outputText = "";
    QTextStream stream( &outputText );

    // Map search through keys
    for ( QString key : keys )
    {
        if ( !winCodec.contains( key ) ) continue;
        stream << winCodec[ key ];
    }

    return outputText;
}
