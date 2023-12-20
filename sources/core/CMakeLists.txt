set (
    CORE_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/tobject.h
    ${CMAKE_CURRENT_SOURCE_DIR}/tobject.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/config.h
    ${CMAKE_CURRENT_SOURCE_DIR}/config.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/callback.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/callback.cpp
)

add_library(
    Core STATIC
    ${CORE_SOURCES}
)
