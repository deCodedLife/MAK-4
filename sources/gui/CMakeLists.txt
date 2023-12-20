FILE ( GLOB GUI_SOURCES *.cpp *.h )
LIST ( SORT GUI_SOURCES )

add_library(
    GUI STATIC
    ${GUI_SOURCES}
)

target_link_libraries(
    GUI PUBLIC
    Qt6::Core
    Qt6::Gui
)
