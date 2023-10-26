cmake_minimum_required(VERSION 3.14)

project(MAK-4 VERSION 0.2 LANGUAGES CXX)

macro(configure_files srcDir destDir)
    message(STATUS "Configuring directory ${destDir}")
    make_directory(${destDir})

    file(GLOB templateFiles RELATIVE ${srcDir} "${srcDir}/*")
    foreach(templateFile ${templateFiles})
        set(srcTemplatePath ${srcDir}/${templateFile})
        if(NOT IS_DIRECTORY ${srcTemplatePath})
            message(STATUS "Configuring file ${templateFile}")
            configure_file(
                    ${srcTemplatePath}
                    ${destDir}/${templateFile}
                    @ONLY)
        endif(NOT IS_DIRECTORY ${srcTemplatePath})
    endforeach(templateFile)
endmacro(configure_files)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Network HttpServer SVG Widgets)
add_subdirectory(sources)

FIND_LIBRARY ( NETSNMP_LIBRARY          NAMES netsnmp           )
FIND_LIBRARY ( NETSNMPAGENT_LIBRARY     NAMES netsnmpagent      )
FIND_LIBRARY ( NETSNMPHELPERS_LIBRARY   NAMES netsnmphelpers    )
FIND_LIBRARY ( NETSNMPMIBS_LIBRARY      NAMES netsnmpmibs       )
FIND_LIBRARY ( NETSNMPTRAPD_LIBRARY     NAMES netsnmptrapd      )

qt_standard_project_setup()
qt_add_executable(MAK-4
    ${SOURCES}
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/qml.qrc
)

qt_add_qml_module(MAK-4
    URI AtolServer
    VERSION 1.0
)

set( PROJECT_NAME MAK-4 )

set_target_properties(MAK-4 PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER org.promsd.mak4
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
)

target_include_directories(
    MAK-4 PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include/snmp/include
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/core
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/configs
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/net-snmp
)

set( LIBS_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/libs )

set(
    SNMP_LIBS
    ""
)

set(
    SSL_LIBS
    ""
)

if ( APPLE )
    set( LIBS_FOLDER ${LIBS_FOLDER}/mac_os )
    set(
        SNMP_LIBS
#        ${LIBS_FOLDER}/libnetsnmp.a
#        ${LIBS_FOLDER}/libnetsnmpagent.a
#        ${LIBS_FOLDER}/libnetsnmphelpers.a
#        ${LIBS_FOLDER}/libnetsnmpmibs.a
#        ${LIBS_FOLDER}/libnetsnmptrapd.a
        ${LIBS_FOLDER}/libsnmppp.a
        ${NETSNMP_LIBRARY}
        ${NETSNMPAGENT_LIBRARY}
        ${NETSNMPHELPERS_LIBRARY}
        ${NETSNMPMIBS_LIBRARY}
        ${NETSNMPTRAPD_LIBRARY}
    )
    set(
        SSL_LIBS
        ${LIBS_FOLDER}/libssl.a
        ${LIBS_FOLDER}/libcrypto.a
    )

    set(CPACK_GENERATOR "DragNDrop")
    include(CPack)
endif()

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/mibs)
configure_files( ${CMAKE_CURRENT_SOURCE_DIR}/mibs ${CMAKE_BINARY_DIR}/mibs )

target_link_libraries(MAK-4
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Network
    PRIVATE Qt6::HttpServer
    PRIVATE Qt6::Widgets
    PRIVATE Configs
    PRIVATE Snmp
    ${SNMP_LIBS}
    ${SSL_LIBS}
)


