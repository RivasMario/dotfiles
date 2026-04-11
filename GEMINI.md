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
- **Installation:** Always use `bash install.sh` from the root of the repo.
- **Validation:** After installation, verify symlinks with `ls -la ~ | grep '\->'`.
- **Testing:** Test changes in a new terminal session or by running `exec zsh`.
- **Commit Style:** Focused on "why" and "what" changed in the environment.

## Progress & Shared Tasks
- [x] Unify `install.sh` and `.devcontainer/setup.sh`.
- [x] Add multi-distro support to `install.sh`.
- [x] Fix `python3` dependency for `pokemon-colorscripts` in Dockerfile.
- [x] Clean up `.zshrc` and integrate `fastfetch` + `pokemon-colorscripts`.
- [x] Create `GEMINI.md` and `CLAUDE.md` for AI context.
- [ ] Add portable clipboard support to `.tmux.conf` (current `wl-copy` is Wayland-specific).
- [ ] Setup automated testing/validation for the install script.
