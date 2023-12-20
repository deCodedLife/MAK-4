FILE ( GLOB SNMP_SOURCES *.cpp *.h )
LIST ( SORT SNMP_SOURCES )

if ( APPLE )

    FIND_LIBRARY ( NETSNMP_LIBRARY          NAMES netsnmp           )
    FIND_LIBRARY ( NETSNMPAGENT_LIBRARY     NAMES netsnmpagent      )
    FIND_LIBRARY ( NETSNMPMIBS_LIBRARY      NAMES netsnmpmibs       )
    FIND_LIBRARY ( NETSNMPTRAPD_LIBRARY     NAMES netsnmptrapd      )

    set(
        SNMP_LIBS
        ${NETSNMP_LIBRARY}
        ${NETSNMPAGENT_LIBRARY}
        ${NETSNMPMIBS_LIBRARY}
        ${NETSNMPTRAPD_LIBRARY}
        ${LIBS_FOLDER}/libsnmppp.a
    )

elseif( WIN32 )

    set(
        SNMP_LIBS

        ${LIBS_FOLDER}/netsnmp.lib
        ${LIBS_FOLDER}/netsnmpagent.lib
        ${LIBS_FOLDER}/netsnmpmibs.lib
        ${LIBS_FOLDER}/netsnmptrapd.lib
        ${LIBS_FOLDER}/snmppp.lib

        ${LIBS_FOLDER}/libcrypto32MD.lib
        ${LIBS_FOLDER}/libssl32MD.lib
    )

endif()

add_library(
    Snmp STATIC
    ${SNMP_SOURCES}
)

target_include_directories(
    Snmp PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/../core
    ${INCLUDES}
)

target_link_libraries(
    Snmp
    PRIVATE Core
    ${SNMPPP}
    ${SNMP_LIBS}
)
