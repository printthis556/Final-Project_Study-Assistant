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

Cloudflare Worker (optional, simple setup)
- **What**: a small Cloudflare Worker can host a simple flashcard generator endpoint. The repository includes a demo worker in `worker/worker.js` that accepts a POST JSON body `{ "notes": "..." }` and returns a JSON array of `{ "question": "..", "answer": ".." }`.
- **Why**: this lets you run the AI portion as a tiny serverless function you control (no external API keys required for the demo worker).
- **Files added**: `worker/worker.js`, `worker/wrangler.toml`.
- **Deploy quickly with Wrangler**:

```bash
# install wrangler (if needed)
npm install -g wrangler

# login and publish (interactive)
wrangler login
wrangler publish --project-worker-path worker/worker.js
```

- **Local testing**:

```bash
# run a local dev server from the repo root; this listens on port 8787 by default
wrangler dev worker/worker.js --port 8787

# then in another shell point the app at the worker
export CF_WORKER_URL="http://127.0.0.1:8787/"
./build/study_assistant_gui
```

If you've published the demo worker, the repository now defaults to the public URL below when `CF_WORKER_URL` is not set. You can explicitly set it as well:

```bash
export CF_WORKER_URL="https://ai-study-app.mhess0308.workers.dev/"
./build/study_assistant_gui
```

- **Usage from the app**: set the environment variable `CF_WORKER_URL` to your worker's public URL (for example `https://<your-subdomain>.workers.dev/`) before launching the GUI/CLI. `AiClient` will post `{ "notes": ... }` to that URL and expects an array of flashcards back.

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
