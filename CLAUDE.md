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
- **SSH to Proxmox:** `ssh -o ProxyCommand='ncat --proxy 127.0.0.1:1055 --proxy-type socks5 %h %p' -o StrictHostKeyChecking=no root@100.70.69.28`

## Progress & Shared Tasks
- [x] Unify `install.sh` and `.devcontainer/setup.sh`.
- [x] Add multi-distro support to `install.sh`.
- [x] Fix `python3` dependency for `pokemon-colorscripts` in Dockerfile.
- [x] Clean up `.zshrc` and integrate `fastfetch` + `pokemon-colorscripts` (now sequential).
- [x] Create `GEMINI.md` and `CLAUDE.md` for AI context.
- [x] Add Tailscale to dotfiles (install, daemon start, operator setup).
- [x] Verify connectivity to Proxmox via SOCKS5 proxy.
- [x] Fix OpenClaw agent configuration and Ollama connection.
- [ ] Add portable clipboard support to `.tmux.conf` (current `wl-copy` is Wayland-specific).
- [ ] Setup automated testing/validation for the install script.

## Notes for Claude
- Gemini CLI is also used in this workspace; please keep `GEMINI.md` and `CLAUDE.md` in sync regarding project progress.
- Avoid `sudo` for npm global packages (use `~/.npm-global/bin` which is already in PATH).
- Tailscale runs in userspace mode; all home network traffic MUST use the SOCKS5 proxy at `127.0.0.1:1055`.
- Ollama is on `100.81.194.15:30068`, and OpenClaw UI is at `192.168.0.119:18789`.
