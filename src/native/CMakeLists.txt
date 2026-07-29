cmake_minimum_required(VERSION 3.22)

project(PlasmaVirtualKeyboard 
    VERSION 6.0.0 
    DESCRIPTION "Native GBoard-style On-Screen Keyboard for KDE Plasma 6 Wayland"
    LANGUAGES CXX C
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Extra CMake Modules (ECM) is required for KDE Frameworks 6 CMake find macros
find_package(ECM 6.0.0 QUIET NO_MODULE)
if (ECM_FOUND)
    list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
    include(KDEInstallDirs OPTIONAL)
    include(KDECompilerSettings OPTIONAL NO_POLICY_SCOPE)
    include(KDECMakeSettings OPTIONAL)
    include(ECMAddWaylandProtocol OPTIONAL)
endif()

# Find Required Qt6 Modules
find_package(Qt6 6.5 REQUIRED COMPONENTS 
    Core 
    Gui 
    Quick 
    QuickControls2 
    Widgets
    DBus 
    WaylandClient
)

# Find Required KDE Frameworks 6 Modules
find_package(KF6 6.0 REQUIRED COMPONENTS 
    Kirigami 
    I18n 
    CoreAddons
)

# Optional KDE components
find_package(KF6KWindowSystem 6.0 QUIET)
find_package(KF6StatusNotifierItem 6.0 QUIET)

# Wayland Protocols & Scanner
find_package(PkgConfig QUIET)
find_package(WaylandScanner QUIET)
find_package(WaylandProtocols 1.31 QUIET)

if (PkgConfig_FOUND)
    pkg_check_modules(WaylandProtocolsPkg wayland-protocols QUIET)
    if (WaylandProtocolsPkg_FOUND)
        pkg_get_variable(WAYLAND_PROTOCOLS_PKGDATADIR wayland-protocols pkgdatadir)
    endif()
endif()

if (NOT WAYLAND_PROTOCOLS_PKGDATADIR)
    find_path(WAYLAND_PROTOCOLS_PKGDATADIR
        NAMES unstable/input-method/input-method-unstable-v2.xml
        PATHS /usr/share/wayland-protocols /usr/local/share/wayland-protocols
    )
endif()

# Executable Target
add_executable(plasma-virtualkeyboard
    src/main.cpp
    src/inputmethod.cpp
    src/inputmethod.h
    src/swypeengine.cpp
    src/swypeengine.h
    resources.qrc
)

target_include_directories(plasma-virtualkeyboard PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

# Generate Wayland Protocol Bindings for zwp_input_method_v2 / v1 if protocol file exists
set(INPUT_METHOD_PROTO_XML "")
if (WAYLAND_PROTOCOLS_PKGDATADIR AND EXISTS "${WAYLAND_PROTOCOLS_PKGDATADIR}/unstable/input-method/input-method-unstable-v2.xml")
    set(INPUT_METHOD_PROTO_XML "${WAYLAND_PROTOCOLS_PKGDATADIR}/unstable/input-method/input-method-unstable-v2.xml")
elseif (WAYLAND_PROTOCOLS_PKGDATADIR AND EXISTS "${WAYLAND_PROTOCOLS_PKGDATADIR}/unstable/input-method/input-method-unstable-v1.xml")
    set(INPUT_METHOD_PROTO_XML "${WAYLAND_PROTOCOLS_PKGDATADIR}/unstable/input-method/input-method-unstable-v1.xml")
elseif (EXISTS "/usr/share/wayland-protocols/unstable/input-method/input-method-unstable-v1.xml")
    set(INPUT_METHOD_PROTO_XML "/usr/share/wayland-protocols/unstable/input-method/input-method-unstable-v1.xml")
endif()

if (INPUT_METHOD_PROTO_XML)
    message(STATUS "Found input-method protocol XML: ${INPUT_METHOD_PROTO_XML}")
    if (COMMAND ecm_add_wayland_client_protocol)
        ecm_add_wayland_client_protocol(WAYLAND_PROTO_SRCS
            PROTOCOL ${INPUT_METHOD_PROTO_XML}
            BASENAME input-method-unstable-v2
        )
        target_sources(plasma-virtualkeyboard PRIVATE ${WAYLAND_PROTO_SRCS})
    elseif (COMMAND qt6_generate_wayland_protocol_client)
        qt6_generate_wayland_protocol_client(plasma-virtualkeyboard
            FILES ${INPUT_METHOD_PROTO_XML}
        )
    endif()
else()
    message(STATUS "wayland-protocols input-method XML not found. Relying on KWin DBus virtual keyboard interface.")
endif()

# DBus Interfaces for KWin Virtual Keyboard & Tablet Mode
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/dbus/org.kde.kwin.virtualkeyboard.xml")
    qt6_add_dbus_interface(DBUS_SRCS
        src/dbus/org.kde.kwin.virtualkeyboard.xml
        virtualkeyboard_interface
    )
    target_sources(plasma-virtualkeyboard PRIVATE ${DBUS_SRCS})
endif()

target_link_libraries(plasma-virtualkeyboard PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    Qt6::DBus
    Qt6::WaylandClient
    KF6::Kirigami
    KF6::I18n
    KF6::CoreAddons
)

if (TARGET KF6::KWindowSystem)
    target_link_libraries(plasma-virtualkeyboard PRIVATE KF6::KWindowSystem)
endif()

if (TARGET KF6::StatusNotifierItem)
    target_link_libraries(plasma-virtualkeyboard PRIVATE KF6::StatusNotifierItem)
    target_compile_definitions(plasma-virtualkeyboard PRIVATE HAVE_KSTATUSNOTIFIERITEM)
endif()

find_package(LayerShellQt QUIET)
if (LayerShellQt_FOUND)
    message(STATUS "Found LayerShellQt library for Wayland Layer Shell window anchoring.")
    target_link_libraries(plasma-virtualkeyboard PRIVATE LayerShellQt::Interface)
    target_compile_definitions(plasma-virtualkeyboard PRIVATE HAVE_LAYERSHELLQT)
endif()

include(GNUInstallDirs)
install(TARGETS plasma-virtualkeyboard DESTINATION ${CMAKE_INSTALL_BINDIR})
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/org.kde.plasma.virtualkeyboard.desktop")
    install(FILES org.kde.plasma.virtualkeyboard.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
endif()
