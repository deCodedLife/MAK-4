// wrappers.mjs

export function divideByTen( value ) { return value / 10 }
export function divideByHundred( value ) { return value / 100 }
export function divideByThousand( value ){ return value / 1000 }

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
    return value
}
