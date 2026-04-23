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
- [x] **Handoff contract:** Design + wire JSON schema between planner/executor in brain-router to cut telephone-game fidelity loss (see memory/handoff_contract_concept.md).
- [ ] **RTX 4080:** Recover from buddy → collapse split-brain to single 12-14B model.

### Maybe / Backlog
- [ ] **MCP Ollama server** for Claude Code — lets Claude offload bulk edits / boilerplate / commits to local models mid-session. Defer until tournament picks winning low+high pair.
- [ ] **Hybrid routing rules** in `CLAUDE.md` — "use `ollama_local` for X, Claude for Y". Pairs with MCP server above.
- [x] **Aider / Continue.dev / Cline / goose eval** — 2026-04-23 bench: goose + qwen3:8b beats aider + claw for homelab ops. `bin/homelab-goose` wired.
- [ ] **3-tier brain-router** — 3B planner → 7B executor → Claude fallback on acceptance-criteria fail. Daily Claude-call budget knob.

## AI Suite Operational Instructions (Updated 2026-04-23)

**Primary homelab agent:** goose 1.32 + qwen3:8b via `bin/homelab-goose` (alias `dgoose`).
Won agent bench 2026-04-23 vs aider (no chmod) and claw-code-local (crashed on tool-call parse). See `homelab/CLAUDE.md` for details.

**Legacy split-brain** (RTX 3060 Ti 8GB VRAM safeguard, tournament winner 2026-04-22):
- **Planner:** `qwen2.5-coder:3b` (Alibaba) — best contract adherence + speed at 3B scale
- **Executor:** `exaone3.5:7.8b` (LG) — note: lacks Ollama tool capability, limits reuse as agent model

No Meta/Llama models — user trust stance.

**Model refresh policy:** Always check for newer non-Meta releases (qwen, exaone, gemma, granite, mistral, phi, command-r, yi, deepseek, smollm, stablelm, etc.) before starting local-model work. If a newer tag exists in a slot, propose swap + run tournament subset to validate before committing. Don't stay on configured pair out of inertia.

### Commands for AI Tasks:
- **`dgoose` / `homelab-goose "task"`**: Primary homelab agent (goose + qwen3:8b). One-shot or REPL, auto-loads `homelab/CLAUDE.md` via `.goosehints` symlink.
- **`daider` / `homelab-aider`**: Fallback code-editor (aider + qwen3:8b). Use when task is pure code edit.
- **`dclaw` / `homelab-claw`**: Legacy claw-code-local harness. Unstable on qwen-coder tool_calls; kept for comparison only.
- **`diddy drone`**: Legacy HITL planner/executor session.
- **`diddy jipoe "task"`**: Legacy JIPOE course-of-action planner.
- **`brain-router`**: Legacy port 11435 3B/7B router, superseded by goose.

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
