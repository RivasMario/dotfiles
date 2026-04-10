# dotfiles

My personal config files for Fedora. Run `install.sh` on a fresh machine to get everything set up.

## What's included

| File | Purpose |
|------|---------|
| `.tmux.conf` | tmux config — Monokai theme, sane keybinds, mouse support |
| `.tmux-help.txt` | Cheatsheet popup (`Ctrl+a h`) |
| `.zshrc` | Zsh + Oh My Zsh, fzf, lsd, pokemon on startup |
| `config/fastfetch/config-pokemon.jsonc` | Fastfetch layout for pokemon-colorscripts |
| `pokemon-colorscripts/` | Pokemon ASCII art scripts |

## Fresh install

```bash
git clone git@github.com:RivasMario/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
exec zsh
```

## Requires

- Fedora (uses `dnf`)
- Internet connection (installs Oh My Zsh, plugins)

## After install

- Open tmux and press `Ctrl+a h` to see shortcuts
- Pokemon + system info shows on every new terminal
- Log in to Claude Code: `claude` (follows browser OAuth)
- Log in to Gemini CLI: `gemini` (follows browser OAuth) or set API key:
  ```bash
  export GEMINI_API_KEY="your-key-here"
  ```
  Add that export to `~/.zshrc` to make it permanent.

## Adding new configs

```bash
cp ~/.config/something ~/dotfiles/config/something
cd ~/dotfiles && git add . && git commit -m "add: something config" && git push
```
