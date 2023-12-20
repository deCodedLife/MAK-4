FILE ( GLOB CORE_SOURCES *.cpp *.h )
LIST ( SORT CORE_SOURCES )

add_library(
    Core STATIC
    ${CORE_SOURCES}
)
