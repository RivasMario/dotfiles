# Dotfiles Workspace Guide

This workspace manages Mario's dotfiles, optimized for Fedora and GitHub Codespaces. The goal is a seamless, automated setup that works identically on physical laptops and cloud environments.

## Project Context
- **OS Focus:** Fedora (primary), Ubuntu/Debian/macOS (secondary compatibility), Windows 11 via `install.ps1`.
- **Core Stack:** Zsh (Oh My Zsh), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools:** Claude Code, Gemini CLI.

## Sibling Repos (split out 2026-05-01)

This repo holds **shell/editor config only**. Larger concerns moved to sibling repos cloned alongside:

| Sibling | Purpose | Was previously at |
|---------|---------|-------------------|
| `homelab` (private) | TrueNAS/Proxmox ops, AI agent harness (goose/aider/claw/diddy/brain-router), benchmarks, memory sidecars | `dotfiles/homelab/` + `dotfiles/bin/homelab-*` + `dotfiles/scripts/` + `dotfiles/memory/` |
| `skyway96` | 96% keyboard plate DXF + KiCad notes | `dotfiles/projects/skyway96/` |
| `llm-tournament` | Local-model bench harness + results | `dotfiles/projects/llm_tournament/` |

`.zshrc` adds `<homelab>/bin` to `PATH` and aliases `dgoose`, `dclaw`, `daider`, `brain-router` if the homelab repo is cloned at `/workspaces/homelab` or `~/homelab`.

## Architectural Patterns
- **Symlinking:** All dotfiles in the root directory (e.g., `.zshrc`, `.tmux.conf`) are symlinked to `$HOME` on Linux/macOS; hard-linked on Windows (no admin needed).
- **Environment Detection:** The installer detects GitHub Codespaces vs. a physical machine to handle shell changes and package installation differently.
- **Node.js Integration:** Uses a custom `.npm-global` prefix to avoid permission issues without `sudo`.

## Key Files
- `install.sh`: Linux/macOS bootstrap (multi-distro: dnf, apt, brew).
- `install.ps1`: Windows bootstrap (winget, MSYS2, hard-linked dotfiles).
- `.zshrc`: Shell configuration; conditionally wires homelab repo aliases.
- `.tmux.conf`: Terminal multiplexer with portable clipboard (clip.exe / wl-copy / pbcopy / xclip).
- `config/fastfetch/config-pokemon.jsonc`: Custom fastfetch layout.
- `.devcontainer/`: Codespaces environment (Tailscale userspace, /dev/net/tun, CAP_NET_ADMIN).

## Operational Instructions
- **Installation (Linux/macOS):** `bash install.sh` from repo root.
- **Installation (Windows):** `powershell -ExecutionPolicy Bypass -File install.ps1` from repo root.
- **Validation:** Verify links with `ls -la ~ | grep '\->'` (Linux) or `fsutil hardlink list $HOME\.zshrc` (Windows).
- **Testing:** `exec zsh` after install.
- **Commit Style:** Focused on "why" the dotfiles change.

## GitHub & SSH Configuration
- **GitHub identity:** `~/.ssh/github` (`config/ssh/config` symlinked to `~/.ssh/config`).
- **Note:** SSH is REQUIRED for pushing to GitHub since HTTPS password auth is disabled.
- **Note:** `~/.ssh` lives on container ephemeral storage in the devcontainer — not the workspace mount. Keys (homelab/github) are lost on rebuild. TODO: bind-mount `~/.ssh` in `.devcontainer/devcontainer.json` to fix.

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

## Notes
- Homelab/AI/keyboard work belongs in the sibling repos — do not pull that content back into this repo.
- Keep `GEMINI.md` and `CLAUDE.md` in sync regarding dotfiles-only concerns.
