# Claude Code - Dotfiles Workspace Guide

This file provides context for Claude Code when working in this repository.

## Project Context
- **Owner:** Mario
- **OS Focus:** Windows 11 (primary work machine), Fedora (homelab/personal).
- **Core Stack:** Zsh (Oh My Zsh via MSYS2 on Windows), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools:** Claude Code, Gemini CLI, CLI-Anything (GIMP/Inkscape/KiCad harnesses).
- **Windows installer:** `install.ps1` (PowerShell) — use this on Windows. `install.sh` is for Linux/macOS.
- **Dotfile linking:** Windows uses hard links (no admin needed). Linux uses symlinks.

## Architectural Patterns
- **Symlinking:** Dotfiles in the root are symlinked to `$HOME`.
- **Unified Installer:** `install.sh` handles multiple package managers and environments.
- **Node.js:** Uses `.npm-global` prefix to avoid `sudo` for global installs.

## Build & Test Commands
- **Install:** `bash install.sh`
- **Reload Shell:** `exec zsh`
- **Verify Links:** `ls -la ~ | grep '\->'`
- **SSH to Proxmox:** `ssh -o ProxyCommand='ncat --proxy 127.0.0.1:1055 --proxy-type socks5 %h %p' -o StrictHostKeyChecking=no root@100.70.69.28`

## Progress & Shared Tasks
- [x] Unify `install.sh` and `.devcontainer/setup.sh`.
- [x] Add multi-distro support to `install.sh`.
- [x] Fix `python3` dependency for `pokemon-colorscripts` in Dockerfile.
- [x] Clean up `.zshrc` and integrate `fastfetch` + `pokemon-colorscripts`.
- [x] Create `GEMINI.md` and `CLAUDE.md` for AI context.
- [x] Add Tailscale to dotfiles (install, daemon start, operator setup).
- [x] Verify connectivity to Proxmox via SOCKS5 proxy.
- [x] Fix OpenClaw agent configuration and Ollama connection.
- [x] Add portable clipboard support to `.tmux.conf`.
- [x] Add Windows PowerShell installer (`install.ps1`).
- [x] **New:** Implement Split-Brain Agent Suite (`diddy`, `claw`, `brain-router`).
- [x] **New:** Securely purge leaked SSH keys from Git history.
- [ ] Setup automated testing/validation for the install scripts.
- [ ] Generate KiCad CLI harness via CLI-Anything.
- [ ] **Tournament (2026-04-22):** Bench low+high model pairs from distinct non-Meta providers (Mistral, Qwen, Gemma, Phi, Granite, DeepSeek, Cohere, Yi, Exaone, SmolLM, StableLM) on split-brain suite.
- [ ] **Handoff contract:** Design + wire JSON schema between planner/executor in brain-router to cut telephone-game fidelity loss (see `memory/handoff_contract_concept.md`).
- [ ] **RTX 4080:** Recover from buddy → collapse split-brain to single 12-14B model.

### Maybe / Backlog
- [ ] **MCP Ollama server** for Claude Code — lets Claude offload bulk edits / boilerplate / commits to local models mid-session. Defer until tournament picks winning low+high pair.
- [ ] **Hybrid routing rules** in `CLAUDE.md` — "use `ollama_local` for X, Claude for Y". Pairs with MCP server above.
- [ ] **Aider / Continue.dev / Cline eval** — multi-provider tools with native weak+strong model split. Low-effort alt to custom MCP.
- [ ] **3-tier brain-router** — 3B planner → 7B executor → Claude fallback on acceptance-criteria fail. Daily Claude-call budget knob.

## AI Suite Operational Instructions (Updated 2026-04-22)
The workspace uses a **Split-Brain** strategy (Planner 3B / Executor 7.8B) to protect the **RTX 3060 Ti (8GB VRAM)**.

**Active pair** (winner of 2026-04-22 tournament, see `projects/llm_tournament/RESULTS.md`):
- **Planner:** `qwen2.5-coder:3b` (Alibaba) — best contract adherence + speed at 3B scale
- **Executor:** `exaone3.5:7.8b` (LG) — cross-provider pairing reduces paraphrase bias vs same-provider pairs

No Meta/Llama models — user trust stance.

**Model refresh policy:** Always check for newer non-Meta releases (qwen, exaone, gemma, granite, mistral, phi, command-r, yi, deepseek, smollm, stablelm, etc.) before starting local-model work. If a newer tag exists in a slot, propose swap + run tournament subset to validate before committing. Don't stay on configured pair out of inertia.

### Commands for AI Tasks:
- **`diddy drone`**: Launch an interactive autonomous session.
- **`claw "task"`**: Launch the protocol-first autonomous coding assistant (v6.1 - Rich).
- **`claw --drone`**: Launch an interactive autonomous session.
- **`diddy jipoe "task"`**: Generate a `MISSION_PACKET.md` course-of-action plan.
- **`diddy execute --coa 1`**: Execute Course of Action 1 from the packet.
- **`brain-router`**: Must be running in background (Port 11435) to handle 3B/7B routing.

### Hardware-Safe Context:
- **`MAX_CONTEXT_TOKENS`**: 4096. 
- **VRAM Residency**: Keep models 100% on GPU. If upgraded to RTX 4080 (16GB), increase this limit to 16k+.
- **Model Unloading**: All scripts use `keep_alive: 0` to flush VRAM between turns.

## Skyway96 Keyboard Project
**Project files:** `projects/skyway96/` — all DXF rules, Inkscape notes, screw hole attempts.
**Plate DXF Generation Rules:** See `projects/skyway96/SKYWAY96_RULES.md` (Claude ↔ Gemini synchronized)
- 96% keyboard, 101 switches, PCB-mount stabs
- Data hierarchy: KiCad (authority) > KLE JSON > images
- Critical: 14mm × 14mm cutouts, no stab plate geometry
- Coordinate mapping required (PCB ≠ plate origin)
- Verification checklist mandatory before any DXF output
- Current SVG: `96_PLATE_v10.svg` (ready for manual screw hole placement)

## Notes for Claude
- Gemini CLI is also used in this workspace; keep `GEMINI.md` and `CLAUDE.md` in sync regarding project progress.
- Avoid `sudo` for npm global packages (use `~/.npm-global/bin` which is already in PATH).
- Tailscale runs in userspace mode; all home network traffic MUST use the SOCKS5 proxy at `127.0.0.1:1055`.
- Ollama is on `100.81.194.15:30068`, and OpenClaw UI is at `192.168.0.119:18789`.
