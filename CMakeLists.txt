cmake_minimum_required(VERSION 3.16)
project(ai_study_assistant LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable Qt's automoc for QObject (AiClient)
set(CMAKE_AUTOMOC ON)

# We now need Widgets too
find_package(Qt6 REQUIRED COMPONENTS Core Network Widgets)

# ---- core library ----
add_library(core
    core/Flashcard.h
    core/FlashcardGenerator.h
    core/FlashcardGenerator.cpp
    core/AiClient.h
    core/AiClient.cpp
)

target_include_directories(core
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/core
)

target_link_libraries(core
    PUBLIC
        Qt6::Core
        Qt6::Network
)

# ---- CLI test app (for Codespaces / backend debug) ----
add_executable(flashcard_cli
    app/main.cpp
)

target_link_libraries(flashcard_cli
    PRIVATE
        core
        Qt6::Core
)

# ---- Qt Widgets GUI app ----
add_executable(study_assistant_gui
    qtgui/main.cpp
    qtgui/MainWindow.h
    qtgui/MainWindow.cpp
)

target_link_libraries(study_assistant_gui
    PRIVATE
        core
        Qt6::Widgets
)
