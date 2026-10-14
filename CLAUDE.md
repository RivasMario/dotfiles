# Claude Code - Dotfiles Workspace Guide

This file provides context for Claude Code when working in this repository.

## Project Context
- **Owner:** Mario
- **OS Focus:** Windows 11 (primary work machine), Fedora (homelab/personal), GitHub Codespaces.
- **Core Stack:** Zsh (Oh My Zsh via MSYS2 on Windows), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools:** Claude Code, Antigravity (`agy`), Gemini CLI, CLI-Anything (GIMP/Inkscape/KiCad harnesses), Graphify (`graphifyy`).
- **Windows installer:** `install.ps1` (PowerShell) — use this on Windows. `install.sh` is for Linux/macOS.
- **Dotfile linking:** Windows uses hard links (no admin needed). Linux uses symlinks.

## Sibling Repos (split out 2026-05-01)

This repo is **shell/editor config only**. Other concerns live in sibling repos cloned alongside:

| Sibling | Purpose | Was previously at |
|---|---|---|
| `homelab` (private) | TrueNAS/Proxmox ops, AI agent harness (goose/aider/claw/diddy/brain-router), benchmarks, memory sidecars | `dotfiles/homelab/` + `dotfiles/bin/homelab-*` + `dotfiles/scripts/` + `dotfiles/memory/` |
| `skyway96` | 96% keyboard plate DXF + KiCad notes | `dotfiles/projects/skyway96/` |
| `llm-tournament` | Local-model bench harness + results | `dotfiles/projects/llm_tournament/` |

`.zshrc` adds `<homelab>/bin` to `PATH` and aliases `dgoose`, `dclaw`, `daider`, `brain-router` if the homelab repo is cloned at `/workspaces/homelab` or `~/homelab`.

## Architectural Patterns
- **Symlinking:** Dotfiles in the root are symlinked to `$HOME` (hardlinked on Windows).
- **Unified Installer:** `install.sh` handles multiple Linux package managers; `install.ps1` bootstraps Windows.
- **Node.js:** Uses `.npm-global` prefix to avoid `sudo` for global installs.
- **Agent Guidelines:** Keep `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md` synchronized on workspace rules.

## Knowledge Graph & Codebase Navigation (Graphify)
- Graphify is integrated as a skill (`~/.claude/skills/graphify/SKILL.md` and `plugins/graphify`).
- Trigger: `/graphify` or `graphify`
- Before performing broad file scans or grepping, check if `graphify-out/graph.json` exists and use `graphify query` for token-efficient architecture context.

## Build & Test Commands
- **Install (Linux/macOS):** `bash install.sh`
- **Install (Windows):** `powershell -ExecutionPolicy Bypass -File install.ps1`
- **Reload Shell:** `exec zsh`
- **Verify Links:** `ls -la ~ | grep '\->'`

## Notes for Claude
- Antigravity (`agy`) and Gemini CLI are also used in this environment; maintain consistency across `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md`.
- Avoid `sudo` for npm global packages (use `~/.npm-global/bin` which is already in PATH).
- Homelab/AI/hardware work belongs in sibling repos — do not pull that content back into this repo.
