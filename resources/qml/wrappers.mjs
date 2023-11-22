// wrappers.mjs

export const RowTypes =
{
    TEXT: 0,
    DESCRIPTION: 1,
    INPUT: 2,
    PASSWORD: 3,
    COMBOBOX: 4,
    CHECHBOX: 5,
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


export function divideByTen( value ) { return value / 10 }
export function divideByHundred( value ) { return value / 100 }
export function divideByThousand( value ){ return value / 1000 }
export function secondsToMinutes( value ){ return (value / 60).toFixed(2) }

export function parseVersion( value ) {
    value = value.toString()
    return `${value[0]}.${value[1]}.${value[2]}`
}

export function parseErrors ( value ) {
    if ( value.split( "normal" ).length === 2 ) return "Норма"
    if ( value.split( "alarm" ).length === 2 ) return "Авария"
    if ( value.split( "main-salarm" ).length === 2 ) return "Авария сети"
    if ( value.split( "overheart" ).length === 2 ) return "Перегрев"
    if ( value.split( "overload" ).length === 2 ) return "Перегрузка"
    if ( value.split( "fan-alarm" ).length === 2 ) return "Авария вентилятора"
    if ( value.split( "fan-warning" ).length === 2 ) return "Авария вентилятора"
    if ( value.split( "off" ).length === 2 ) return "Отключено"
    if ( value.split( "wrong-type" ).length === 2 ) return "Неверный тип"
    if ( value.split( "unknown" ).length === 2 ) return "Неизвестно"
    if ( value.split( "absent" ).length === 2 ) return "Отсутствует"
    if ( value.split( "on" ).length === 2 ) return "Включено"
    if ( value.split( "off" ).length === 2 ) return "Выключено"
    if ( value.split( "error" ).length === 2 ) return "Ошибка"

    if ( value.split( "success" ).length === 2 ) return "Успешно"
    if ( value.split( "user-braked" ).length === 2 ) return "Остановлено"
    if ( value.split( "low-current" ).length === 2 ) return "Низкое\nнапряжение"
    if ( value.split( "go-charge" ).length === 2 ) return "Идёт заряд"
    if ( value.split( "battery-off" ).length === 2 ) return "Батарея выкл"
    if ( value.split( "timeout" ).length === 2 ) return "Таймаут"
    if ( value.split( "mesure-error" ).length === 2 ) return "Ошибка\nизмерения"
    if ( value.split( "empty" ).length === 2 ) return "Пусто"

    if ( value.split( "charge" ).length === 2 ) return "Заряжается"
    if ( value.split( "floating" ).length === 2 ) return "Плавает"
    if ( value.split( "fast-charge" ).length === 2 ) return "Быстрая зарядка"
    if ( value.split( "equalizing-charge" ).length === 2 ) return "Зарядка эквалайзер"
    if ( value.split( "discharge" ).length === 2 ) return "Разрядка"
    if ( value.split( "low" ).length === 2 ) return "Низкий заряд"
    if ( value.split( "test" ).length === 2 ) return "Тестирование"

    if ( value.split( "value-normal" ).length === 2 ) return "Норма"
    if ( value.split( "undervoltage" ).length === 2 ) return "Пониженная"
    if ( value.split( "overvoltage" ).length === 2 ) return "Повышенная"
    if ( value.split( "value-error" ).length === 2 ) return "Ошибка"
    if ( value.split( "threshold-normal" ).length === 2 ) return "Отключено"
    if ( value.split( "threshold-alarm" ).length === 2 ) return "Ошибка"

    if ( value.split( "stand-by" ).length === 2 ) return "Поддержка"

    return value
}
