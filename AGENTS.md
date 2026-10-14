# AI Coding Agents - Dotfiles Workspace Guide

This guide establishes unified standards and context for AI coding agents (**Antigravity `agy`**, **Claude Code**, **Gemini CLI**, and multi-agent systems) operating in this workspace.

## Project Context
- **Owner:** Mario
- **OS Focus:** Windows 11 (primary work machine), Fedora (homelab/personal), GitHub Codespaces.
- **Core Stack:** Zsh (Oh My Zsh via MSYS2 on Windows), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools & Runtimes:**
  - Python 3.12+ (managed in user profile on Windows, distro on Linux)
  - Node.js 22 (uses `~/.npm-global` prefix without `sudo`)
  - AI Assistants: **Antigravity (`agy`)**, **Claude Code (`claude`)**, **Gemini CLI (`gemini`)**
  - Tooling & Extensions: **Graphify (`graphifyy`)**, **Caveman**, **CLI-Anything**
- **Installers:**
  - Windows: `install.ps1` (PowerShell, handles winget, MSYS2, hard-links, and user-level PATH)
  - Linux/macOS/Codespaces: `install.sh` (Bash, multi-distro: dnf, apt, brew, symlinks)

## Sibling Repos (split out 2026-05-01)
This repo contains **shell and editor configurations only**. Other project domains live in sibling repos cloned alongside:
- `homelab` (private): Proxmox/TrueNAS ops, Tailscale network, AI harness, and service monitoring.
- `skyway96`: 96% keyboard plate DXF + KiCad PCB project.
- `llm-tournament`: Local-model benchmarking harness.

> [!IMPORTANT]
> Homelab/hardware/AI model testing belongs in the sibling repositories. Do not pull those concerns into `dotfiles`.

## Agent Guidelines & Standards

### 1. Architectural Patterns
- **Dotfile Linking:** Windows uses hard links or directory junctions to avoid requiring elevation. Linux/macOS uses symlinks.
- **Node.js Integration:** Never run `sudo npm install -g`. Global installs target `~/.npm-global/bin`, which is pre-configured in PATH.
- **Progressive Disclosure:** Keep rules concise. Deep reference material should be modularized in skills (`.agents/skills/` or `skills/`).

### 2. Knowledge Graph & Codebase Intelligence (Graphify)
- **Knowledge Graphs:** When analyzing architecture, cross-file dependencies, or unfamiliar repositories, check for `graphify-out/` first.
- **Query First:** If `graphify-out/graph.json` exists, use `graphify query "<concept>"` or `/graphify query` rather than grepping through raw source files.
- **Build / Refresh:** Run `/graphify .` or `graphify .` to map or update the knowledge graph.

### 3. Agent Tooling & Customizations
- **Antigravity (`agy`):** Customizations are discovered hierarchically via `.agents/` (workspace), `AGENTS.md` / `GEMINI.md`, and globally in `~/.gemini/config/`.
- **Claude Code (`claude`):** Settings configured via `.claude/settings.json`, with global skills in `~/.claude/skills/` and rules in `CLAUDE.md`.
- **Consistency:** Keep `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md` synchronized regarding workspace conventions.
