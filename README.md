Final-Project_Study-Assistant

A Qt 6 + QML Study Assistant application built for a Software Engineering project.

This guide shows how to install Qt Creator, clone the repo, open the project, and run it from source.

1. Install Qt (with Qt Creator)

Go to:
https://www.qt.io/download-open-source

Download the Qt Online Installer.

During installation, select:

Qt Version (required):

Qt 6.x.x (6.7 or newer recommended)

Toolchain (Windows):

MinGW 64-bit

IDE:

Qt Creator

Finish installation and open Qt Creator.

2. Clone This Repository

Clone using Git, GitHub Desktop, or Qt Creator.

Option A — Git (command line)
git clone https://github.com/forwizzel/Final-Project_Study-Assistant.git

Option B — GitHub Desktop

Open GitHub Desktop

Go to File → Clone Repository

Paste the URL:

https://github.com/forwizzel/Final-Project_Study-Assistant


Choose a local folder and clone.

Option C — Qt Creator (from Version Control)

In Qt Creator, go to File → New Project → Projects from Version Control

Choose Git

Enter:

https://github.com/forwizzel/Final-Project_Study-Assistant


Select a local directory and clone.

3. Open the Project in Qt Creator

In Qt Creator, go to:
File → Open File or Project

Navigate to the cloned folder and select:

CMakeLists.txt


Qt Creator will detect this as a CMake + Qt Quick project.

When prompted to configure kits, select:

Qt 6.x.x MinGW 64-bit (on Windows)

Or your appropriate Qt 6 kit on other platforms

If no kits appear:

Open the Qt Maintenance Tool

Make sure a Qt 6.x.x version and a compiler toolchain (e.g., MinGW 64-bit) are installed

4. Build and Run

Click the Run button (green play icon) in Qt Creator.

On first run, CMake will configure the project automatically.

Qt Creator then builds the project and launches the application.

Your QML frontend lives in:

src/qml/


Your backend C++ code lives in:

src/


main.cpp loads the QML UI via QQmlApplicationEngine.

5. Project Structure
Final-Project_Study-Assistant/
│
├── CMakeLists.txt          ← main project file (open this in Qt Creator)
├── src/
│   ├── main.cpp            ← entry point
│   ├── qml.qrc             ← resource file bundling QML
│   ├── qml/
│   │   ├── Main.qml        ← root QML file
│   │   ├── Pages/…         ← other UI pages
│   │   └── Components/…    ← reusable QML components
│   └── ... (other C++ files if added later)
│
└── README.md

6. Troubleshooting
Qt Creator says “No kits available”

This usually means no compiler / Qt version is configured.

Fix:

Open the Qt Maintenance Tool

Ensure the following are installed:

Qt 6.x.x (with Qt Quick modules)

MinGW 64-bit (on Windows) or your platform compiler

Qt Creator

Then reopen the project and reconfigure kits.

Design tab is greyed out

This is normal for most .qml files.

Only .ui.qml files support the drag-and-drop visual designer.

Regular .qml files are edited in code mode only.

The project uses standard .qml, so you’ll mostly work in the text editor view.

Missing Qt modules / import errors

If you see errors like “module ‘QtQuick.Controls’ is not installed”, make sure your Qt installation includes:

Qt Quick

Qt Quick Controls 2

Qt QML

Qt Declarative

These typically come bundled with a normal Qt 6 desktop installation, but you can re-run the Qt Maintenance Tool to add them if needed.

7. Running from Terminal (Optional)

You can also build and run the project manually via CMake.

cd Final-Project_Study-Assistant
mkdir build
cd build
cmake ..
cmake --build .


Then run the generated executable from the build directory.

License
This project is for educational use.
