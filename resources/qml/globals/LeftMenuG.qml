pragma Singleton

import QtQuick
import QtQuick.Controls.Material

QtObject
{
    property string iconsLocation: "qrc:/images/icons/"

    property list<Item> mainList: [
        MenuItemM { icon: "lan.svg"; title: "Соединение"; page: "Pages/Connection.qml" },
        MenuItemM { icon: "info.svg"; title: "Об устройстве"; page: "Pages/DeviceInfo.qml" },
        MenuItemM { icon: "emergency.svg"; title: "Аварии"; page: "Pages/Emergency.qml" },
        MenuItemM { icon: "switch.svg"; title: "Сигнальные реле"; page: "Pages/SignalRelays.qml" },
        MenuItemM { icon: "contract.svg"; title: "Журнал событий"; page: "Pages/Journal.qml" },
        MenuItemM { icon: "electric_bolt.svg"; title: "Нагрузка"; page: "Pages/Load.qml" },
        MenuItemM { icon: "battery_unknown.svg"; title: "Батарея"; page: "Pages/BatteryInfo.qml" },
        MenuItemM { icon: "lan.svg"; title: "УПКБ"; page: "Pages/UPKV.qml" },
        MenuItemM { icon: "battery_checked.svg"; title: "Тесты батареи"; page: "Pages/BatteryTest.qml" },
        MenuItemM { icon: "battery_checked.svg"; title: "Короткий тест батареи"; page: "Pages/BatteryTestShort.qml" },
        MenuItemM { icon: "battery.svg"; title: "Разряды батареи"; page: "Pages/BatteryCharging.qml" },
        MenuItemM { icon: "contactors.svg"; title: "Контакторы"; page: "Pages/Contactors.qml" },
        MenuItemM { icon: "waves.svg"; title: "Выпрямители"; page: "Pages/Rectifiers.qml" },
        MenuItemM { icon: "power.svg"; title: "Сеть"; page: "Pages/ElectricalNetwork.qml" },
        MenuItemM { icon: "thermostat.svg"; title: "Температура"; page: "Pages/Temprerature.qml" },
        MenuItemM { icon: "dry_connectors.svg"; title: "Сухие контакты"; page: "Pages/DryContacts.qml" },
        MenuItemM { icon: "memory.svg"; title: "BMS"; page: "Pages/BMS" },
        MenuItemM { icon: "settings.svg"; title: "Настройки"; page: "Pages/Settings.qml" }
    ]
}
