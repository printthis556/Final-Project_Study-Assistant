# AI Study Assistant — Flashcard Generator (C++ / Qt6)

> Small example project: backend library that generates flashcards from notes, plus a console test app.

Layout
- `core/` — reusable backend (no UI): `Flashcard`, `FlashcardGenerator`, and an `AiClient` skeleton.
- `app/` — simple console app `flashcard_cli` that exercises the generator.
- `CMakeLists.txt` — top-level CMake configuration (C++17, Qt6 Core/Network).
- `.devcontainer/` — devcontainer configuration and setup script for Codespaces.

Quick start (Codespaces / devcontainer)

1. Open this repo in Codespaces or a VS Code devcontainer. The devcontainer image is configured in `.devcontainer/devcontainer.json` and runs `.devcontainer/setup.sh` to install required packages (CMake, Ninja, Qt6).

2. From the repo root, configure and build (Ninja):

```bash
mkdir -p build
cmake -S . -B build -G Ninja
cmake --build build
```

3. Run the console test app:

```bash
./build/flashcard_cli
```

What it does
- `FlashcardGenerator::generateFromText()` splits the input notes into blocks (double-newline separated) and creates a `Flashcard` for each block. The question is the first line truncated to ~80 chars and prefixed with "Explain: ". The answer is the full trimmed block.
- `AiClient` is a network-enabled skeleton that prepares a JSON POST body and parses an array of `{ "question": "...", "answer": "..." }` from a response. It does not call any real service by default — you must configure your endpoint and API key.

AiClient notes
- The placeholder URL is `https://your-ai-endpoint.example.com/v1/flashcards` (in `core/AiClient.cpp`).
- If you set the environment variable `AI_API_KEY`, the client will include an `Authorization: Bearer <key>` header when making requests.
- `AiClient` emits `flashcardsReady(const QVector<Flashcard>&)` on success and `errorOccurred(const QString&)` on errors.

Development tips
- CMake: project requires Qt6 Core and Network. `CMakeLists.txt` enables `AUTOMOC` so `Q_OBJECT` is handled automatically.
- If you change headers in `core/`, rerun CMake configure if necessary.

Troubleshooting
- If `cmake` complains about missing Qt6 packages, ensure the devcontainer setup script ran successfully (see `.devcontainer/setup.sh`) or install `qt6-base-dev` and `qt6-base-dev-tools` on your machine.
- If Ninja is missing, install `ninja-build` (the devcontainer setup installs it).

License
- This repo contains example code and is provided as-is. Add a LICENSE file if you intend to use a specific license.

# Final-Project_Study-Assistant
this is a group project for programming 2. The goal is to create an ai assistant that will help students study and assist with projects that they may have. This will be using the Qt framwork. will be using an AI API key for this project. 
