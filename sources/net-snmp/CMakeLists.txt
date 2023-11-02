FILE ( GLOB SNMP_SOURCES *.cpp *.h )
LIST ( SORT SNMP_SOURCES )

add_library(
    Snmp STATIC
    ${SNMP_SOURCES}
)
