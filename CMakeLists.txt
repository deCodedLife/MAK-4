cmake_minimum_required(VERSION 3.14)

project(MAK-4 VERSION 0.2 LANGUAGES CXX)
set( PROJECT_NAME MAK-4 )

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

find_package(
    Qt6 6.5
    REQUIRED
    COMPONENTS
    Quick
    Gui
    Network
    HttpServer
    SVG
    Widgets
)
add_subdirectory(sources)

qt_standard_project_setup()
qt_add_executable(MAK-4
    ${SOURCES}
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/qml.qrc
)

if ( APPLE )

    set_target_properties(MAK-4 PROPERTIES
        MACOSX_BUNDLE_GUI_IDENTIFIER org.promsd.mak4
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
    )
    set(CPACK_GENERATOR "DragNDrop")
    include(CPack)

else ( WIN32 )

    set_target_properties( MAK-4 PROPERTIES WIN32_EXECUTABLE TRUE )

endif()

target_link_libraries(
    MAK-4
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Network
    PRIVATE Qt6::HttpServer
    PRIVATE Qt6::Widgets
    PRIVATE Qt6::Svg
    PRIVATE Snmp
    PRIVATE GUI
)

target_include_directories(
    MAK-4 PRIVATE
    ${INCLUDE_FOLDER}
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/core
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/net-snmp
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/gui
)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/mibs)
configure_files( ${CMAKE_CURRENT_SOURCE_DIR}/mibs ${CMAKE_BINARY_DIR}/mibs )
