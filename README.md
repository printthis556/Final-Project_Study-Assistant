# Final-Project_Study-Assistant

A Qt 6 + QML Study Assistant application built for a Programming 2 project.

This guide shows how to install Qt Creator, clone the repo, open the project, and run it from source.

---

## Install Qt (with Qt Creator)

1. Go to: https://www.qt.io/download-open-source  
2. Download the **Qt Online Installer**.
3. During installation, select:

   **Qt Version (required):**
   - Qt 6.x.x (**6.7 or newer recommended**)

   **Toolchain (Windows):**
   - MinGW 64-bit

   **IDE:**
   - Qt Creator

4. Finish installation and open **Qt Creator**.

---

## Clone This Repository

Clone using **Git** or **GitHub Desktop**.

### Option A — Git (command line)

```bash
git clone https://github.com/forwizzel/Final-Project_Study-Assistant.git'''
```

### Option B — GitHub Desktop

1. Open GitHub Desktop

2. Go to File → Clone Repository

3. Paste the URL: https://github.com/forwizzel/Final-Project_Study-Assistant

4. Choose a local folder and clone.

---

## Open the Project in Qt Creator

**In Qt Creator:**
1. Go to: File → Open File or Project
2. Navigate to the cloned folder and select:
```bash
CMakeLists.txt
```
Qt Creator will detect this as a CMake + Qt Quick project.

3. When prompted to configure kits, select:
- Qt 6.x.x (**6.7 or newer**)

> Note: If no kits appear:
> - Open the Qt Maintenance Tool
> - Make sure a Qt 6.x.x version and a compiler toolchain (e.g., MinGW 64-bit) are installed

---

## Build and Run

**In Qt Creator:**
1. Click the Run button (green play icon, bottom left) in Qt Creator.
2. On first run, CMake will configure the project automatically.

Qt Creator then builds the project and launches the application.

The QML frontend (UI) lives in:
```bash
src/qml/
```

The C++ backend code lives in:
```bash
src/
```


> Note: main.cpp loads the QML UI via QQmlApplicationEngine.

---

## Project Structure


Final-Project_Study-Assistant/

│

├── CMakeLists.txt          ← *main project file (open this in Qt Creator)*

├── src/

│   ├── main.cpp            ← *entry point*

│   ├── qml.qrc             ← *resource file bundling QML*

│   ├── qml/

│   │   ├── Main.qml        ← *root QML file*

│   │   ├── Pages/…         ← *other UI pages*

│   │   └── Components/…    ← *reusable QML components*

│   └── ... *(other C++ files if added later)*

│

└── README.md

---

## Troubleshooting

### Qt Creator says “No kits available”
This usually means no compiler / Qt version is configured.

Fix:

1. Open the Qt Maintenance Tool

2. Ensure the following are installed:
- Qt 6.x.x (with Qt Quick modules)
- MinGW 64-bit (on Windows) or your platform compiler
- Qt Creator

3. Reopen the project and reconfigure kits.

### Design tab is greyed out
Only .ui.qml files support the drag-and-drop visual designer.

Regular .qml files are edited in code mode only.

The project uses standard .qml, so the designer will not work.

### Missing Qt modules / import errors

If you see errors like “module ‘QtQuick.Controls’ is not installed”, make sure your Qt installation includes:
- Qt Quick
- Qt Quick Controls 2
- Qt QML
- Qt Declarative

These typically come bundled with a normal Qt 6 desktop installation, but you can re-run the Qt Maintenance Tool to add them if needed.

---

## Running from Terminal (Optional; I DO NOT RECCOMEND)

You can build and run the project manually via CMake.

```bash
cd Final-Project_Study-Assistant
mkdir build
cd build
cmake ..
cmake --build .
```

Then run the generated executable from the build directory.

---

License
This project is for educational use.
