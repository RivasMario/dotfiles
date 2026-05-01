# dotfiles

Mario's config files. Works on **Windows** (primary), Fedora, and Ubuntu.

## What's included

| File | Purpose |
|------|---------|
| `.tmux.conf` | tmux config — Monokai theme, sane keybinds, mouse + portable clipboard |
| `.tmux-help.txt` | Cheatsheet popup (`Ctrl+a h`) |
| `.zshrc` | Zsh + Oh My Zsh, fzf, lsd, pokemon on startup |
| `config/fastfetch/config-pokemon.jsonc` | Fastfetch layout for pokemon-colorscripts |
| `config/ssh/config` | GitHub SSH configuration (expects `~/.ssh/github`) |
| `pokemon-colorscripts/` | Pokemon ASCII art scripts |

## GitHub & SSH Setup

The dotfiles expect a GitHub SSH key at `~/.ssh/github`.
To generate a new key and add it to GitHub:

1. Generate key: `ssh-keygen -t ed25519 -f ~/.ssh/github`
2. Copy public key: `cat ~/.ssh/github.pub`
3. Add to GitHub: [Settings -> SSH and GPG keys](https://github.com/settings/keys)

Once linked, all `git push` operations will use this key automatically.

---

## Fresh install

### Windows (PowerShell)
```powershell
git clone https://github.com/RivasMario/dotfiles.git $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles
.\install.ps1
```

### Linux / Fedora / Ubuntu
```bash
git clone git@github.com:RivasMario/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
exec zsh
```

## Sibling repos (split out 2026-05-01)

This repo holds shell/editor config only. Other concerns live in sibling repos cloned alongside `dotfiles`:

| Sibling | Purpose |
|---------|---------|
| `homelab` (private) | TrueNAS/Proxmox ops, AI agent harness (goose / aider / claw / diddy / brain-router), local-LLM benchmarks, ops memory sidecars |
| `skyway96` | 96% keyboard plate DXF + KiCad notes |
| `llm-tournament` | Local-model bench harness + results |

`.zshrc` adds `<homelab>/bin` to `PATH` and aliases `dgoose`, `dclaw`, `daider`, `brain-router` if the homelab repo is cloned at `/workspaces/homelab` or `~/homelab`.

## Requires

- **Windows:** winget, Git for Windows (bash), PowerShell 5+
- **Linux:** Fedora (uses `dnf`) or Ubuntu/Debian (uses `apt`)
- Internet connection

## After install

- Open a terminal and run `zsh` (MSYS2 zsh is installed)
- tmux: `Ctrl+a h` to see shortcuts
- Pokemon + system info shows on every new zsh session
- Log in to Claude Code: `claude`
- Log in to Gemini CLI: `gemini`

## Adding new configs

```bash
cp ~/.config/something ~/dotfiles/config/something
cd ~/dotfiles && git add . && git commit -m "add: something config" && git push
```

## Tools installed by install.ps1

| Tool | Purpose |
|------|---------|
| MSYS2 + zsh + tmux | Unix shell on Windows |
| fzf, lsd, fastfetch | Shell quality-of-life |
| Python 3.12 | Scripts, pokemon-colorscripts, CLI harnesses |
| Node.js 22 | Claude Code, Gemini CLI |
| Calibre | ebook → PDF conversion |
| GIMP, Inkscape | Image editing |
| Tailscale | Homelab VPN |
| CLI-Anything | Agent-native CLI for GIMP, Inkscape, KiCad |
| caveman | Claude Code plugin |
