cmake_minimum_required(VERSION 3.22)

project(PlasmaVirtualKeyboard 
    VERSION 6.0.0 
    DESCRIPTION "Native GBoard-style On-Screen Keyboard for KDE Plasma 6 Wayland"
    LANGUAGES CXX C
)

add_subdirectory(src/native)
