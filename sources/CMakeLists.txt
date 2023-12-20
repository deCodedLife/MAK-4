add_subdirectory(core)
add_subdirectory(configs)

target_link_libraries(
    Core
    PUBLIC Qt6::Core
)


target_link_libraries(
    Configs
    PRIVATE Core
)

target_include_directories(
    Configs PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/core
)
