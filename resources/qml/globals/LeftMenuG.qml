pragma Singleton

import QtQuick
import QtQuick.Controls.Material

import "../Models"

QtObject
{
    property string iconsLocation: "qrc:/images/icons/"

    property list<Item> mainMenu: [
        MenuItemM { icon: "lan.svg"; title: "Соединение"; page: "Pages/Connection.qml" },
        MenuItemM { icon: "info.svg"; title: "Об устройстве"; page: "Pages/DeviceInfo.qml" },
        MenuItemM { icon: "emergency.svg"; title: "Аварии"; page: "Pages/Emergency.qml" },
        MenuItemM { icon: "switch.svg"; title: "Сигнальные реле"; page: "Pages/SignalRelays.qml" },
        MenuItemM { icon: "contract.svg"; title: "Журнал событий"; page: "Pages/Journal.qml" },
        MenuItemM { icon: "electric_bolt.svg"; title: "Нагрузка"; page: "Pages/Load.qml" },
        MenuItemM { icon: "battery_unknown.svg"; title: "Батарея"; page: "Pages/BatteryInfo.qml" },
        MenuItemM { icon: "lan.svg"; title: "УПКБ"; page: "Pages/UPKB.qml" },
        MenuItemM { icon: "battery_checked.svg"; title: "Тесты батареи"; page: "Pages/BatteryTest.qml" },
        MenuItemM { icon: "battery_checked.svg"; title: "Короткий тест батареи"; page: "Pages/BatteryTestShort.qml" },
        MenuItemM { icon: "battery.svg"; title: "Разряды батареи"; page: "Pages/BatteryCharging.qml" },
        MenuItemM { icon: "contactors.svg"; title: "Контакторы"; page: "Pages/Contactors.qml" },
        MenuItemM { icon: "waves.svg"; title: "Выпрямители"; page: "Pages/Rectifiers.qml" },
        MenuItemM { icon: "power.svg"; title: "Сеть"; page: "Pages/ElectricalNetwork.qml" },
        MenuItemM { icon: "thermostat.svg"; title: "Температура"; page: "Pages/Temprerature.qml" },
        MenuItemM { icon: "dry_connectors.svg"; title: "Сухие контакты"; page: "Pages/DryContacts.qml" },
        MenuItemM { icon: "memory.svg"; title: "BMS"; page: "Pages/BMS.qml" },
        MenuItemM { icon: "settings.svg"; title: "Настройки"; callback: () => { loadMenu( settingsMenu ); menuButtons = settingsButtons } }
    ]

    property list<Item> settingsMenu: [
        MenuItemM { icon: "back.svg"; title: "Меню"; callback: () => loadMenu( mainMenu ) },
        MenuItemM { title: "Маски аварий"; page: "Pages/Settings_Masks.qml" },
        MenuItemM { title: "Общее"; page: "Pages/Settings_Overall.qml" },
        MenuItemM { title: "Батарея"; page: "Pages/Settings_Battery.qml" },
        MenuItemM { title: "Контакторы"; page: "Pages/Settings_Contactors.qml" },
        MenuItemM { title: "Сеть"; page: "Pages/Settings_Power.qml" },
        MenuItemM { title: "Температура"; page: "Pages/Settings_Temperature.qml" },
        MenuItemM { title: "Конфигурация"; page: "Pages/Settings_Configuration.qml" },
        MenuItemM { title: "Сетевые настройки"; page: "Pages/Settings_Network.qml" },
        MenuItemM { title: "Безопасность"; page: "Pages/Settings_Security.qml" },
        MenuItemM { title: "SNMP"; page: "Pages/Settings_SNMP.qml" }
    ]

    property list<Item> settingsButtons: [
        MenuItemM { icon: "open.svg"; title: "Считать из файла"; callback: () => {} },
        MenuItemM { icon: "save.svg"; title: "Сохранить в файл"; callback: () => {} }
    ]

    property list<Item> currentMenu: mainMenu
    property list<Item> menuButtons: []

    function loadMenu( items: list<Item> ) { currentMenu = items; menuButtons = [] }
}
