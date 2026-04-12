# dotfiles

Mario's config files. Works on **Windows** (primary), Fedora, and Ubuntu.

## What's included

| File | Purpose |
|------|---------|
| `.tmux.conf` | tmux config — Monokai theme, sane keybinds, mouse + portable clipboard |
| `.tmux-help.txt` | Cheatsheet popup (`Ctrl+a h`) |
| `.zshrc` | Zsh + Oh My Zsh, fzf, lsd, pokemon on startup |
| `config/fastfetch/config-pokemon.jsonc` | Fastfetch layout for pokemon-colorscripts |
| `pokemon-colorscripts/` | Pokemon ASCII art scripts |

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
