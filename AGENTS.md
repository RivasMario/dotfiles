# AI Coding Agents - Dotfiles Workspace Guide

Canonical, tool-neutral rules for every agent in this workspace (**Antigravity `agy`**, **Claude Code**, **Gemini CLI**).
`CLAUDE.md` and `GEMINI.md` import this file and add only tool-specific notes. Edit shared rules **here**, not there.

## Project Context
- **Owner:** Mario
- **OS Focus:** Windows 11 (primary work machine), Fedora (homelab/personal), GitHub Codespaces; Ubuntu/Debian/macOS secondary.
- **Core Stack:** Zsh (Oh My Zsh via MSYS2 on Windows), tmux, fastfetch, lsd, pokemon-colorscripts.
- **Tools & Runtimes:**
  - Python 3.12+ (managed in user profile on Windows, distro on Linux)
  - Node.js 22 (uses `~/.npm-global` prefix without `sudo`)
  - AI Assistants: **Antigravity (`agy`)**, **Claude Code (`claude`)**, **Gemini CLI (`gemini`)**
  - Tooling & Extensions: **Graphify (`graphifyy`)**, **Caveman**, **CLI-Anything**
  - Reverse engineering: **REA** (MCP, "Reverse Engineer Anything" — binaries/apps/runtime). Upstream [morluto/rea](https://github.com/morluto/rea); cloned at `~/rea`. Install deps there with `npx rea-agents setup`; wire the MCP server per-machine (keep its config out of this repo). Useful for the `open-astro-cps` DLL disassembly work.

## Sibling Repos (split out 2026-05-01)
This repo contains **shell and editor configuration only**. Other domains live in sibling repos cloned alongside:

| Sibling | Purpose |
|---|---|
| `homelab` (private) | Proxmox/TrueNAS ops, Tailscale network, AI agent harness (goose/aider/claw/diddy/brain-router), benchmarks, memory sidecars |
| `skyway96` | 96% keyboard plate DXF + KiCad notes |
| `llm-tournament` | Local-model bench harness + results |

`.zshrc` adds `<homelab>/bin` to `PATH` and aliases `dgoose`, `dclaw`, `daider`, `brain-router` if the homelab repo is cloned at `/workspaces/homelab` or `~/homelab`.

> [!IMPORTANT]
> Homelab/hardware/AI model testing belongs in the sibling repositories. Do not pull those concerns into `dotfiles`.

## Multi-Agent Layout (how Claude and Gemini coexist)

| Concern | Shared (all agents) | Claude Code only | Gemini / agy only |
|---|---|---|---|
| Rules | `AGENTS.md` | `CLAUDE.md` (imports `AGENTS.md`) | `GEMINI.md` (imports `AGENTS.md`) |
| Skills | `skills/<name>/SKILL.md` | `.claude/skills/<name>/` | `.gemini/skills/<name>/` |
| Plugins | `plugins/<name>/` | — | — |
| Settings | — | `.claude/settings.json` (linked) | `~/.gemini/settings.json` (machine-local) |
| MCP servers | — | `~/.claude.json` (machine-local) | `~/.gemini/config/mcp_config.json` (machine-local) |

- **New skill:** put it in `skills/` if it works for every agent. Use `.claude/skills/` or `.gemini/skills/` only when it is tool-specific; a tool dir entry with the same name as a shared skill overrides it for that tool (e.g. `context-audit`).
- **MCP configs stay out of the repo:** they hold tokens and machine-specific paths, and the repo is public.
- Installers copy shared skills to `~/.claude/skills`, `~/.gemini/skills`, `~/.gemini/config/skills`, then overlay tool-specific ones.

## Architectural Patterns
- **Dotfile Linking:** Root dotfiles are symlinked to `$HOME` on Linux/macOS and hard-linked on Windows (no elevation). Tools that save by replacing the file break Windows hard links; re-run `install.ps1` to relink.
- **Node.js Integration:** Never run `sudo npm install -g`. Global installs target `~/.npm-global/bin`, which is pre-configured in PATH.
- **Progressive Disclosure:** Keep rules concise. Deep reference material belongs in skills.

## Knowledge Graph & Codebase Intelligence (Graphify)
- When analyzing architecture, cross-file dependencies, or unfamiliar repositories, check for `graphify-out/` first.
- If `graphify-out/graph.json` exists, use `graphify query "<concept>"` or `/graphify query` rather than grepping raw source.
- Run `/graphify .` or `graphify .` to build or refresh the graph.

## Key Files
- `install.sh`: Linux/macOS bootstrap (multi-distro: dnf, apt, brew; symlinks).
- `install.ps1`: Windows bootstrap (winget, MSYS2, hard links, Python/npm tooling, user-level PATH).
- `.zshrc`: Shell configuration; conditionally wires homelab repo aliases.
- `.tmux.conf`: tmux with portable clipboard (clip.exe / wl-copy / pbcopy / xclip).
- `config/fastfetch/config-pokemon.jsonc`: Custom fastfetch layout.
- `.devcontainer/`: Codespaces environment (Tailscale userspace, /dev/net/tun, CAP_NET_ADMIN).

## Commands
- **Install (Linux/macOS):** `bash install.sh`
- **Install (Windows):** `powershell -ExecutionPolicy Bypass -File install.ps1` (no Tailscale on Windows; the homelab is reached only through the Linux/WSL Tailscale from `install.sh`)
- **Reload Shell:** `exec zsh`
- **Verify Links:** `ls -la ~ | grep '\->'` (Linux) or `fsutil hardlink list $HOME\.zshrc` (Windows)
