# Claude Code - Dotfiles Workspace Guide

This file provides context for Claude Code when working in this repository.

## Project Context
- **Owner:** Mario
- **OS Focus:** Windows 11 (primary work machine), Fedora (homelab/personal).
- **Core Stack:** Zsh (Oh My Zsh via MSYS2 on Windows), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools:** Claude Code, Gemini CLI, CLI-Anything (GIMP/Inkscape/KiCad harnesses).
- **Windows installer:** `install.ps1` (PowerShell) — use this on Windows. `install.sh` is for Linux/macOS.
- **Dotfile linking:** Windows uses hard links (no admin needed). Linux uses symlinks.

## Sibling Repos (split out 2026-05-01)

This repo is **shell/editor config only**. Other concerns live in sibling repos cloned alongside:

| Sibling | Purpose | Was previously at |
|---------|---------|-------------------|
| `homelab` (private) | TrueNAS/Proxmox ops, AI agent harness (goose/aider/claw/diddy/brain-router), benchmarks, memory sidecars | `dotfiles/homelab/` + `dotfiles/bin/homelab-*` + `dotfiles/scripts/` + `dotfiles/memory/` |
| `skyway96` | 96% keyboard plate DXF + KiCad notes | `dotfiles/projects/skyway96/` |
| `llm-tournament` | Local-model bench harness + results | `dotfiles/projects/llm_tournament/` |

`.zshrc` adds `<homelab>/bin` to `PATH` and aliases `dgoose`, `dclaw`, `daider`, `brain-router` if the homelab repo is cloned at `/workspaces/homelab` or `~/homelab`.

## Architectural Patterns
- **Symlinking:** Dotfiles in the root are symlinked to `$HOME`.
- **Unified Installer:** `install.sh` handles multiple package managers and environments.
- **Node.js:** Uses `.npm-global` prefix to avoid `sudo` for global installs.

## Build & Test Commands
- **Install:** `bash install.sh`
- **Reload Shell:** `exec zsh`
- **Verify Links:** `ls -la ~ | grep '\->'`

## Progress & Shared Tasks
- [x] Unify `install.sh` and `.devcontainer/setup.sh`.
- [x] Add multi-distro support to `install.sh`.
- [x] Fix `python3` dependency for `pokemon-colorscripts` in Dockerfile.
- [x] Clean up `.zshrc` and integrate `fastfetch` + `pokemon-colorscripts`.
- [x] Add Tailscale to dotfiles (install, daemon start, operator setup).
- [x] Add portable clipboard support to `.tmux.conf`.
- [x] Add Windows PowerShell installer (`install.ps1`).
- [x] **Securely purge leaked SSH keys from Git history.**
- [x] **Split homelab + projects into sibling repos (2026-05-01).**
- [ ] Setup automated testing/validation for the install scripts.
- [ ] Bind-mount `~/.ssh` in `.devcontainer/devcontainer.json` so SSH keys persist across container rebuilds.

## Notes for Claude
- Gemini CLI is also used in this workspace; keep `GEMINI.md` and `CLAUDE.md` in sync regarding dotfiles-only concerns.
- Avoid `sudo` for npm global packages (use `~/.npm-global/bin` which is already in PATH).
- Tailscale runs in userspace mode in the devcontainer (CAP_NET_ADMIN + /dev/net/tun via runArgs).
- Homelab/AI/keyboard work belongs in the sibling repos — do not pull that content back into this repo.
