FILE ( GLOB GUI_SOURCES *.cpp *.h )
LIST ( SORT GUI_SOURCES )

add_library(
    GUI STATIC
    ${GUI_SOURCES}
    wrappers.h wrappers.cpp
)

target_link_libraries(
    GUI PUBLIC
    Qt6::Core
    Qt6::Gui
    PRIVATE Core
)


target_include_directories(
    GUI PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/../core
    ${INCLUDES}
)
