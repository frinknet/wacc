# JSCC WebAssembly Bridge — Quickstart & CLI

Welcome to **JSCC**: a sleek, no-nonsense C-to-JS WebAssembly bridge with warp-speed bootstrapping.

---

## Features

- Minimal clutter C and JavaScript bridge for WebAssembly + ImGui demos
- Bidirectional JS/C calls with smart `js_value` packing/unpacking
- CLI tool to **init** new projects with upstream submodule integration and files scaffolded
- Docker-based build and static server powered by Caddy for instant testing
- Auto-rebuild and live reload with `jscc serve` using file watchers
- Clean separation of code (`src`), web assets (`web`), and tooling (`jscc` submodule)

---

## Requirements

- [Docker](https://www.docker.com/get-started)
- [docker-compose](https://docs.docker.com/compose/install/)
- Bash shell (Linux/macOS/WSL)
- Optional: `inotify-tools` for instant rebuilds (Linux)

---

## CLI Usage

### Initialize new project


