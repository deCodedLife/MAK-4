// wrappers.mjs

export const RowTypes =
{
    TEXT: 0,
    DESCRIPTION: 1,
    INPUT: 2,
    PASSWORD: 3,
    COMBOBOX: 4,
    CHECKBOX: 5,
    COUNTER: 6
}

export class RowItem
{
    constructor(
        type = RowTypes.DESCRIPTION,
        wrapper = (v) => v,
        key = "num",
        description = null
    ) {
        this.type = type
        this.wrapper = wrapper
        this.key = key
        this.description = description
    }
}

export class ContentItem
{
    constructor(
        oid,
        description = "",
        type = RowTypes.DESCRIPTION,
        key = "num",
        wrapper = (v) => v,
        action = (v) => v
    ) {
        this.oid = oid
        this.description = description
        this.type = type
        this.key = key
        this.wrapper = wrapper
        this.action = action
    }
}

export function byHundredZeroOne( value, reverse = false )
{
    return reverse
            ? parseFloat( value ).toFixed(2) / 0.01
            : value * 0.01
}

export function verySpecificWrapper( value, reverse = false )
{
    value = value.toString().split( "C10" )[0]
    return reverse
            ? parseFloat( value ).toFixed(2) / 0.01
            : value * 0.01 + "C10"
}

export function divideByTen( value, reverse = false ) {
    return reverse
            ? parseFloat( value ).toFixed(1) * 10
            : value / 10
}
export function divideByHundred( value, reverse = false ) {
    return reverse
            ? parseFloat( value ).toFixed(2) * 100
            : value / 100
}
export function divideByThousand( value, reverse = false ){
    return reverse
            ? parseFloat( value ).toFixed(3) * 1000
            : value / 1000
}
export function secondsToMinutes( value, reverse = false ){
    return reverse ? value * 60 : (value / 60).toFixed(2)
}

export function parseVersion( value ) {
    value = value.toString()
    return `${value[0]}.${value[1]}.${value[2]}`
}

export function getFieldValue( field, value ) {
    // if ( field[ "type" ] !== RowTypes.CHECKBOX && field[ "type" ] !== RowTypes.COUNTER )
    return value
    // else return parseFloat( value ).toFixed(1)
}

export function parseErrors ( value ) {
    value = value.split( "(" )[0]

    if ( value === "normal" ) return "Норма"
    if ( value === "alarm" ) return "Авария"
    if ( value === "main-salarm" ) return "Авария сети"
    if ( value === "overheart" ) return "Перегрев"
    if ( value === "overload" ) return "Перегрузка"
    if ( value === "fan-alarm" ) return "Авария вентилятора"
    if ( value === "fan-warning" ) return "Авария вентилятора"
    if ( value === "off" ) return "Отключено"
    if ( value === "wrong-type" ) return "Неверный тип"
    if ( value === "unknown" ) return "Неизвестно"
    if ( value === "absent" ) return "Отсутствует"
    if ( value === "on" ) return "Включено"
    if ( value === "off" ) return "Выключено"
    if ( value === "error" ) return "Ошибка"

    if ( value === "success" ) return "Успешно"
    if ( value === "user-braked" ) return "Остановлено"
    if ( value === "low-current" ) return "Низкое\nнапряжение"
    if ( value === "go-charge" ) return "Идёт заряд"
    if ( value === "battery-off" ) return "Батарея выкл"
    if ( value === "timeout" ) return "Таймаут"
    if ( value === "mesure-error" ) return "Ошибка\nизмерения"
    if ( value === "empty" ) return "Пусто"

    if ( value === "discharge" ) return "Разряжается"
    if ( value === "charge" ) return "Заряжается"
    if ( value === "floating" ) return "Плавает"
    if ( value === "fast-charge" ) return "Быстрая зарядка"
    if ( value === "equalizing-charge" ) return "Зарядка эквалайзер"
    if ( value === "low" ) return "Низкий заряд"
    if ( value === "test" ) return "Тестирование"

    if ( value === "value-normal" ) return "Норма"
    if ( value === "undervoltage" ) return "Понижено"
    if ( value === "overvoltage" ) return "Повышено"
    if ( value === "value-error" ) return "Ошибка"
    if ( value === "threshold-normal" ) return "Отключено"
    if ( value === "threshold-alarm" ) return "Ошибка"

    if ( value === "connected" ) return "Подключена"
    if ( value === "disconnected" ) return "Отключена"

    if ( value === "thermocompensation" ) return "Термокомпенсация"

    if ( value === "stand-by" ) return "Содержание"

    return value
}
