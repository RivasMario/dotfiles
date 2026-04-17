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
- [x] Clean up `.zshrc` and integrate `fastfetch` + `pokemon-colorscripts` (now sequential).
- [x] Create `GEMINI.md` and `CLAUDE.md` for AI context.
- [x] Add Tailscale to dotfiles (install, daemon start, operator setup).
- [x] Verify connectivity to Proxmox via SOCKS5 proxy.
- [x] Fix OpenClaw agent configuration and Ollama connection.
- [x] Add portable clipboard support to `.tmux.conf` (now detects clip.exe/wl-copy/pbcopy/xclip).
- [x] Add Windows PowerShell installer (`install.ps1`).
- [x] Add MSYS2 PATH to `.zshrc` for Windows.
- [ ] Setup automated testing/validation for the install scripts.
- [ ] Generate KiCad CLI harness via CLI-Anything (`/cli-anything:cli-anything https://github.com/KiCad/kicad-source-mirror`).

## SkyWave96 Keyboard Project
**Plate DXF Generation Rules:** See `SKYWAY96_RULES.md` (Claude ↔ Gemini synchronized)
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
