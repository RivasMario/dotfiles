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

## GitHub & SSH Configuration

The workspace is configured to use SSH for GitHub authentication.
- **Identity File:** `~/.ssh/github`.
- **Config:** `dotfiles/config/ssh/config` is symlinked to `~/.ssh/config`.
- **Note:** SSH is REQUIRED for pushing changes to GitHub since HTTPS password auth is disabled.

---

## SkyWave96 Keyboard Project
**Plate DXF Generation Rules:** See `SKYWAY96_RULES.md` (Claude ↔ Gemini synchronized)
- 96% keyboard, 101 switches, PCB-mount stabs
- Data hierarchy: KiCad (authority) > KLE JSON > images
- Critical: 14mm × 14mm cutouts, no stab plate geometry
- Coordinate mapping required (PCB ≠ plate origin)
- Manual screw hole placement in Inkscape before export
- Verification checklist mandatory before any DXF output
- Current SVG: `96_PLATE_v10.svg` (ready in Downloads)

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

## Work Journal

### Recovery (2026-04-12, 19:39 - Claude Code)
1. **Plate Project Status:** Found gemini's crashed SVG→DXF conversion task in progress (v1-v7 done, v8-v10 pending).
2. **Root Cause:** Conversion scripts hardcoded v7 paths; gemini lacked batch processing capability.
3. **Solution:** Created `batch_convert.py` - robust converter handling all versions with proper error handling.
4. **Outcome:** Successfully converted v4-v10 DXF (v2/v3 skipped due to malformed XML). All active designs now have matching outputs.
5. **Artifacts:** See `PLATE_PROJECT.md` for full details.

### Original (2026-04-12)
1. **Tailscale Fix:** Installed Tailscale via script, started `tailscaled` in userspace mode with SOCKS5 proxy enabled on port 1055.
2. **Network Discovery:** Found Ollama running on TrueNAS port 30068 (not 11434) and OpenClaw on port 18789.
3. **OpenClaw Repair:** Identified security lockout in OpenClaw (binding to LAN without auth). Updated `openclaw.json` to enable token auth (`<REDACTED>`) and set correct Ollama port.
4. **Validation:** Confirmed Proxmox SSH access and Ollama connectivity.
5. **Bottleneck Found:** Ollama container is limited to 3.2GB RAM, but `qwen2.5-coder:7b` needs 5.2GB.
6. **REMINDER:** Increase Ollama App Memory Limit to **16GB+** in TrueNAS SCALE UI (Host has 64GB DDR4 available).
7. **REMINDER:** Configure TrueNAS SSH (System Settings -> Services) to allow the agent access (either via password or adding its public key).
8. **Windows Support:** Added `install.ps1` for automated Windows setup (winget, MSYS2, hard-linked dotfiles, Python 3.12 path).
9. **Portable Clipboard:** Updated `.tmux.conf` to detect `clip.exe` on Windows, `wl-copy` on Wayland, `pbcopy` on macOS, and `xclip` on X11.

## Split-Brain AI Agent Architecture (New 2026-04-21)

The workspace now features a custom, high-performance AI agent suite optimized for 8GB VRAM (RTX 3060 Ti). It uses a "Split-Brain" strategy to maximize speed and intelligence.

### Core Strategy: The "Navy Workflow"
- **Planner Lane (Intelligence Analyst):** Uses `llama3.2:3b` (3 Billion parameters). Lightning fast (160+ tok/s). Responsible for high-level JIPOE (Joint Intelligence Prep), planning, and final briefing.
- **Executor Lane (Cryptologic Technician):** Uses `qwen2.5-coder:7b` (7 Billion parameters). Deep technical logic. Responsible for autonomous execution of the chosen Course of Action (COA).
- **VRAM Guard:** Hard limit of **4096 tokens** (`MAX_CONTEXT_TOKENS`) to ensure 100% GPU residency on 8GB cards. Spilling to system RAM is blocked.

### Tools in `dotfiles/bin/`
- **`diddy`**: The primary action agent. Supports `jipoe` (planning), `execute` (tactical action), and `drone` (interactive autonomous session) modes. Aligned with Navy JIPOE doctrine.
- **`claw`**: A high-end, protocol-first autonomous agent for repository work. Native Python implementation with a visually distinct "Claw" terminal.
- **`brain-router`**: A background proxy (Port 11435) that automatically routes small requests to the 3B model and large context/code tasks to the 7B model.

### VRAM & Hardware Notes
- **Ollama Host:** `100.81.194.15:30068` (TrueNAS). 
- **RTX 3060 Ti (8GB):** Optimized for 7B-8B models. Larger models (e.g. Gemma 4 e4b) will spill to CPU and run slow (20 tok/s vs 80+ tok/s).
- **GPU Upgrade:** If upgraded to **RTX 4080 (16GB)**, increase `MAX_CONTEXT_TOKENS` in `bin/diddy` and `bin/claw-fancy` to unleash full potential.

---

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
- [x] Recover and batch-convert plate DXF files (v4-v10 successful).
- [x] **New:** Implement Split-Brain Agent Suite (`diddy`, `claw`, `brain-router`).
- [x] **New:** Securely purge leaked SSH keys from Git history.
- [ ] Setup automated testing/validation for the install script.
- [ ] Generate KiCad CLI harness via CLI-Anything.
