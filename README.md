# Final-Project_Study-Assistant

A Qt 6 + QML Study Assistant application built for a Programming 2 project.

This guide shows how to install Qt Creator, clone the repo, open the project, and run it from source.

---

## Install Qt Creator

1. Go to: https://www.qt.io/download-open-source  
2. Download the **Qt Online Installer**.
3. During installation, select custom installation and install the following:

   **Qt Version (required):**
   - Select the dropdown on "Qt 6.7.3", select:
```bash
MinGW 11.2.0 64-bit.
```

   **Toolchain (Windows):**
   - Select the dropdown on "Build Tools", select:
```bash
MinGW 11.2.0 64-bit
CMake 3.30.5
Ninja 1.12.1
```

   **IDE:**
   - Qt Creator 18.0.0

5. Finish installation and open **Qt Creator**.

---

## Clone This Repository

Clone using **Git** or **GitHub Desktop**.

### Option A — Git (command line)

```bash
git clone https://github.com/forwizzel/Final-Project_Study-Assistant.git
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
2. Navigate to the cloned project and select:
```bash
CMakeLists.txt
```
Qt Creator will detect this as a CMake + Qt Quick project.

3. When prompted to configure kits, select:
```bash
Qt 6.7.3
```

> Note: If no kits appear:
> - Open the Qt Maintenance Tool
> - Make sure a Qt 6.7.3 version and a compiler toolchain (e.g., MinGW 64-bit) are installed

---

## Build and Run

### IMPORTANT!:
Navigate to "Projects" (left side bar), click to "Run Settings" (top of projects page), and right under run settings you will see:
```bash
"Active run configuration:"
```
with a drop down including the options:
- flashcard_cli
- study_assistant_qml.

 **You must** select **study_assistant_qml**

> Selecting flashcard_cli will cause the program to run unexpectedly

Once you've done that, continue:


**In Qt Creator:**
1. Click the Run button (green play icon, bottom left) in Qt Creator.
2. On first run, CMake will configure the project automatically.

Qt Creator then builds the project and launches the application.

The QML frontend (UI) is in:
```bash
src/qml/
```

The C++ backend code is in:
```bash
src/
```

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

Regular .qml files are edited in code mode only and I used standard .qml to work better with backend integration, so the designer does not work.

### Missing Qt modules / import errors

If you see errors like “module ‘QtQuick.Controls’ is not installed”, make sure your Qt installation includes:
- Qt Quick
- Qt Quick Controls 2
- Qt QML
- Qt Declarative

These typically come with the normal Qt 6 desktop installation, but you can re-run the Qt Maintenance Tool to add them if you dont have them for any reason.

---

## Running the project from Terminal (I DO NOT RECCOMMEND)

You can build and run the project manually via CMake with:

```bash
cd Final-Project_Study-Assistant
mkdir build
cd build
cmake ..
cmake --build .
```

Then run the generated executable from the build directory.

---

## Using a Cloudflare Worker for AI

- **Built-in default:** The application will use the Cloudflare Worker at
   `https://ai-study-app.mhess0308.workers.dev/` automatically if no AI endpoint
   environment variables are set. This worker implements a simple deterministic
   flashcard generator and accepts POST JSON with a `notes` field.
- **Optional env var:** To override or use a different endpoint, set
   `AI_FLASHCARDS_ENDPOINT`, `AI_ASK_ENDPOINT`, or `AI_API_ENDPOINT` to the
   desired URL before launching the app. Example (bash):

```bash
export AI_API_ENDPOINT="https://ai-study-app.mhess0308.workers.dev/"
```

- **API key:** If you have an API key for another AI provider, set
   `AI_API_KEY`. The app will include an `Authorization: Bearer <key>` header
   when the var is present. The Cloudflare Worker does not require an API key.

To test quickly, open the app and use the AI features — the app will POST
JSON like `{"notes": "..."}` to the endpoint and expects a JSON array of
objects with `question` and `answer` fields in response.


License
This project is for educational use.
