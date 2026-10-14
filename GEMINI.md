# Dotfiles Workspace Guide

This workspace manages Mario's dotfiles, optimized for Windows 11, Fedora, and GitHub Codespaces. The goal is a seamless, automated setup that works identically on physical laptops and cloud environments.

## Project Context
- **OS Focus:** Windows 11 via `install.ps1`, Fedora (primary Linux), Ubuntu/Debian/macOS (secondary compatibility).
- **Core Stack:** Zsh (Oh My Zsh via MSYS2 on Windows), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools & Assistants:** Antigravity (`agy`), Claude Code (`claude`), Gemini CLI (`gemini`), Graphify (`graphifyy`), CLI-Anything.

## Sibling Repos (split out 2026-05-01)

This repo holds **shell/editor config only**. Larger concerns moved to sibling repos cloned alongside:

| Sibling | Purpose | Was previously at |
|---|---|---|
| `homelab` (private) | TrueNAS/Proxmox ops, AI agent harness (goose/aider/claw/diddy/brain-router), benchmarks, memory sidecars | `dotfiles/homelab/` + `dotfiles/bin/homelab-*` + `dotfiles/scripts/` + `dotfiles/memory/` |
| `skyway96` | 96% keyboard plate DXF + KiCad notes | `dotfiles/projects/skyway96/` |
| `llm-tournament` | Local-model bench harness + results | `dotfiles/projects/llm_tournament/` |

`.zshrc` adds `<homelab>/bin` to `PATH` and aliases `dgoose`, `dclaw`, `daider`, `brain-router` if the homelab repo is cloned at `/workspaces/homelab` or `~/homelab`.

## Architectural Patterns
- **Symlinking & Hardlinking:** Dotfiles in root (e.g., `.zshrc`, `.tmux.conf`) are symlinked on Linux/macOS and hardlinked on Windows.
- **Node.js Integration:** Uses custom `.npm-global` prefix in user profile to avoid permission issues without `sudo`.
- **Agent Guidelines:** Unified rules across `GEMINI.md`, `CLAUDE.md`, and `AGENTS.md`.

## Knowledge Graph & Codebase Intelligence (Graphify)
- Graphify is available as an agent skill under `.gemini/skills/graphify/SKILL.md` and as a plugin in `plugins/graphify`.
- When investigating architecture or cross-module relationships, query the knowledge graph in `graphify-out/` before making sweeping file reads.
- Run `/graphify .` or `graphify .` to build or update the project knowledge graph.

## Key Files
- `install.sh`: Linux/macOS bootstrap (multi-distro: dnf, apt, brew).
- `install.ps1`: Windows bootstrap (winget, MSYS2, hard-linked dotfiles, Python/npm tooling).
- `AGENTS.md`: Multi-agent workspace guide.
- `.zshrc`: Shell configuration; conditionally wires homelab repo aliases.
- `.tmux.conf`: Terminal multiplexer with portable clipboard (clip.exe / wl-copy / pbcopy / xclip).
- `config/fastfetch/config-pokemon.jsonc`: Custom fastfetch layout.
- `.devcontainer/`: Codespaces environment (Tailscale userspace, /dev/net/tun, CAP_NET_ADMIN).

## Operational Instructions
- **Installation (Linux/macOS):** `bash install.sh` from repo root.
- **Installation (Windows):** `powershell -ExecutionPolicy Bypass -File install.ps1` from repo root.
- **Validation:** Verify links with `ls -la ~ | grep '\->'` (Linux) or `fsutil hardlink list $HOME\.zshrc` (Windows).
- **Testing:** `exec zsh` after install.

## Notes
- Homelab/AI/keyboard work belongs in sibling repos — do not pull that content back into this repo.
- Keep `GEMINI.md`, `CLAUDE.md`, and `AGENTS.md` synchronized on dotfiles-only concerns.
