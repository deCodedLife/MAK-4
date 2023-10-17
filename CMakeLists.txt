cmake_minimum_required(VERSION 3.14)

project(MAK-4 VERSION 0.2 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Network HttpServer SVG Widgets)

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
    MACOSX_BUNDLE_GUI_IDENTIFIER me.codedlife.atol
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
)

target_link_libraries(MAK-4
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Network
    PRIVATE Qt6::HttpServer
    PRIVATE Qt6::Widgets
)

set(CPACK_GENERATOR "DragNDrop")
include(CPack)
