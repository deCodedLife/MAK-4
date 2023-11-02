FIND_LIBRARY ( NETSNMP_LIBRARY          NAMES netsnmp           )
FIND_LIBRARY ( NETSNMPAGENT_LIBRARY     NAMES netsnmpagent      )
FIND_LIBRARY ( NETSNMPHELPERS_LIBRARY   NAMES netsnmphelpers    )
FIND_LIBRARY ( NETSNMPMIBS_LIBRARY      NAMES netsnmpmibs       )
FIND_LIBRARY ( NETSNMPTRAPD_LIBRARY     NAMES netsnmptrapd      )

add_subdirectory(core)
add_subdirectory(net-snmp)

target_link_libraries(
    Core
    PUBLIC Qt6::Core
)

set( LIBS_FOLDER ${CMAKE_SOURCE_DIR}/libs )

if ( APPLE )
    set( LIBS_FOLDER ${LIBS_FOLDER}/mac_os )
elseif( UNIX )
    set( LIBS_FOLDER ${LIBS_FOLDER}/unix )
else()
    set( LIBS_FOLDER ${LIBS_FOLDER}/win )
endif()

target_link_libraries(
    Snmp
    PRIVATE Core
    ${LIBS_FOLDER}/libsnmppp.a
    ${NETSNMP_LIBRARY}
    ${NETSNMPAGENT_LIBRARY}
    ${NETSNMPHELPERS_LIBRARY}
    ${NETSNMPMIBS_LIBRARY}
    ${NETSNMPTRAPD_LIBRARY}
)

target_include_directories(
    Snmp PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

target_include_directories(
    Snmp PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/core
)
