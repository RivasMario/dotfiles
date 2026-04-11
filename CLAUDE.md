# Claude Code - Dotfiles Workspace Guide

This file provides context for Claude Code when working in this repository.

## Project Context
- **Owner:** Mario
- **OS Focus:** Fedora (primary), Ubuntu/Debian/macOS (secondary compatibility).
- **Core Stack:** Zsh (Oh My Zsh), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools:** Claude Code, Gemini CLI.

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
- [x] Clean up `.zshrc` and integrate `fastfetch` + `pokemon-colorscripts` (now sequential).
- [x] Create `GEMINI.md` and `CLAUDE.md` for AI context.
- [ ] Add portable clipboard support to `.tmux.conf` (current `wl-copy` is Wayland-specific).
- [ ] Setup automated testing/validation for the install script.

## Notes for Claude
- Gemini CLI is also used in this workspace; please keep `GEMINI.md` and `CLAUDE.md` in sync regarding project progress.
- Avoid `sudo` for npm global packages (use `~/.npm-global/bin` which is already in PATH).
