# Dotfiles Workspace Guide

This workspace manages Mario's dotfiles, optimized for Fedora and GitHub Codespaces. The goal is a seamless, automated setup that works identically on physical laptops and cloud environments.

## Project Context
- **OS Focus:** Fedora (primary), Ubuntu/Debian/macOS (secondary compatibility).
- **Core Stack:** Zsh (Oh My Zsh), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools:** Claude Code, Gemini CLI.

## Architectural Patterns
- **Symlinking:** All dotfiles in the root directory (e.g., `.zshrc`, `.tmux.conf`) are symlinked to `$HOME`.
- **Environment Detection:** The installer should detect if it's running in GitHub Codespaces vs. a physical machine to handle shell changes and package installation differently.
- **Node.js Integration:** Uses a custom `.npm-global` prefix to avoid permission issues without `sudo`.

## Current State (Newly Fixed)
- **Dotfile Loading:** The installation process now automatically detects if it's in a physical machine (`~/dotfiles`) or Codespaces (`/workspaces/dotfiles`) and symlinks correctly.
- **Redundancy:** `install.sh` has been unified and `setup.sh` now simply calls it with appropriate flags.
- **Unified Logic:** `install.sh` now supports `dnf` (Fedora), `apt` (Debian/Ubuntu), and `brew` (macOS), improving portability.
- **Dependencies:** `python3` was added to the `Dockerfile` to support `pokemon-colorscripts`.
- **Startup Integration:** `.zshrc` has been cleaned and now correctly triggers BOTH `pokemon-colorscripts` and `fastfetch` with the custom config for a complete startup experience.

## Key Files
- `install.sh`: The main bootstrap script.
- `.zshrc`: Shell configuration (needs cleanup and Pokemon integration).
- `.tmux.conf`: Terminal multiplexer configuration.
- `config/fastfetch/config-pokemon.jsonc`: Custom fastfetch layout.
- `.devcontainer/`: Codespaces environment definition.

## Operational Instructions
- **Installation (Linux/macOS):** Always use `bash install.sh` from the root of the repo.
- **Installation (Windows):** Run `powershell -ExecutionPolicy Bypass -File install.ps1` from the root of the repo.
- **Validation:** After installation, verify links with `ls -la ~ | grep '\->'` (Linux) or `fsutil hardlink list $HOME\.zshrc` (Windows).
- **Testing:** Test changes in a new terminal session or by running `exec zsh`.
- **Commit Style:** Focused on "why" and "what" changed in the environment.

## Tailscale & Homelab Integration (Updated 2026-04-12)

Tailscale is fully operational in userspace mode within Codespaces, and now also configured via `install.ps1` for Windows.

### Connectivity Status
- **Exit Node:** `truenas` (100.81.194.15) is active and reachable.
- **SOCKS5 Proxy:** Required for userspace networking, running on `127.0.0.1:1055`.
- **Proxmox (PVE):** `100.70.69.28`. Reachable via SSH using the SOCKS5 proxy and `root` user.
- **Ollama:** Running as a container on `truenas` (100.81.194.15 / 192.168.0.203) on **port 30068**. Model: `qwen2.5-coder:7b`.
- **OpenClaw Agent:** Fixed and running on LXC 101 (`192.168.0.119`). Port `18789`, Token `<REDACTED>`.
- **Kasm Machine:** VMID 100 (`192.168.0.235`). Accessible via SSH as `kasmadmin`.
- **GL.iNet Router:** `192.168.0.1`. Accessible via SSH as `root` (Password: `<REDACTED>`).

### Usage Patterns
- **SSH to Proxmox:**
  ```bash
  ssh -o ProxyCommand='ncat --proxy 127.0.0.1:1055 --proxy-type socks5 %h %p' -o StrictHostKeyChecking=no root@100.70.69.28
  ```
- **Ollama API Query:**
  ```bash
  curl --socks5-hostname 127.0.0.1:1055 http://100.81.194.15:30068/api/tags
  ```
- **OpenClaw UI:** `http://192.168.0.119:18789` (accessible via home network/VPN).

## Work Journal (2026-04-12)
1. **Tailscale Fix:** Installed Tailscale via script, started `tailscaled` in userspace mode with SOCKS5 proxy enabled on port 1055.
2. **Network Discovery:** Found Ollama running on TrueNAS port 30068 (not 11434) and OpenClaw on port 18789.
3. **OpenClaw Repair:** Identified security lockout in OpenClaw (binding to LAN without auth). Updated `openclaw.json` to enable token auth (`<REDACTED>`) and set correct Ollama port.
4. **Validation:** Confirmed Proxmox SSH access and Ollama connectivity.
5. **Bottleneck Found:** Ollama container is limited to 3.2GB RAM, but `qwen2.5-coder:7b` needs 5.2GB.
6. **REMINDER:** Increase Ollama App Memory Limit to **16GB+** in TrueNAS SCALE UI (Host has 64GB DDR4 available).
7. **REMINDER:** Configure TrueNAS SSH (System Settings -> Services) to allow the agent access (either via password or adding its public key).
8. **Windows Support:** Added `install.ps1` for automated Windows setup (winget, MSYS2, hard-linked dotfiles, Python 3.12 path).
9. **Portable Clipboard:** Updated `.tmux.conf` to detect `clip.exe` on Windows, `wl-copy` on Wayland, `pbcopy` on macOS, and `xclip` on X11.

## Progress & Shared Tasks
- [x] Unify `install.sh` and `.devcontainer/setup.sh`.
- [x] Add multi-distro support to `install.sh`.
- [x] Fix `python3` dependency for `pokemon-colorscripts` in Dockerfile.
- [x] Clean up `.zshrc` and integrate `fastfetch` + `pokemon-colorscripts`.
- [x] Create `GEMINI.md` and `CLAUDE.md` for AI context.
- [x] Add Tailscale to dotfiles (install, daemon start, operator setup).
- [x] Verify connectivity to Proxmox via SOCKS5 proxy.
- [x] Fix OpenClaw agent configuration and Ollama connection.
- [x] Add portable clipboard support to `.tmux.conf` (detects clip.exe/wl-copy/pbcopy/xclip).
- [x] Add Windows PowerShell installer (`install.ps1`).
- [x] Add MSYS2 and Python 3.12 PATH support to `.zshrc` for Windows.
- [ ] Setup automated testing/validation for the install script.
- [ ] Generate KiCad CLI harness via CLI-Anything (`/cli-anything:cli-anything https://github.com/KiCad/kicad-source-mirror`).
