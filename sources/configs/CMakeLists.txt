set (
    CONFIGS_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/configs.h
    ${CMAKE_CURRENT_SOURCE_DIR}/configs.cpp
)

add_library(
    Configs STATIC
    ${CONFIGS_SOURCES}
)
