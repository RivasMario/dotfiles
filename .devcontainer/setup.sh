#!/usr/bin/env bash
# Devcontainer-specific setup — packages already baked into the image via Dockerfile.
# Runs install.sh with SKIP_PACKAGES=1 to jump straight to dotfile linking + tools.
set -e

DOTFILES="/workspaces/dotfiles"

# Extra packages not in Dockerfile
sudo dnf install -y gh tmux fzf fastfetch lsd 2>/dev/null || \
    sudo dnf install -y gh tmux fzf 2>/dev/null || true

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Symlink dotfiles
mkdir -p "$HOME/.config/fastfetch"
link() {
    local src="$1" dst="$2"
    [ -e "$dst" ] && [ ! -L "$dst" ] && mv "$dst" "$dst.bak"
    ln -sf "$src" "$dst"
    echo "  linked: $dst"
}
link "$DOTFILES/.tmux.conf"                            "$HOME/.tmux.conf"
link "$DOTFILES/.tmux-help.txt"                        "$HOME/.tmux-help.txt"
link "$DOTFILES/.zshrc"                                "$HOME/.zshrc"
link "$DOTFILES/config/fastfetch/config-pokemon.jsonc" "$HOME/.config/fastfetch/config-pokemon.jsonc"

# npm global prefix
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH

# Claude Code
if ! command -v claude &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
fi

# Gemini CLI
if ! command -v gemini &>/dev/null; then
    npm install -g @google/gemini-cli
fi

# Caveman plugin
if command -v claude &>/dev/null; then
    claude plugin marketplace add JuliusBrussee/caveman 2>/dev/null || true
    claude plugin install caveman@caveman 2>/dev/null || true
fi

# Set zsh as default shell
sudo usermod --shell "$(which zsh)" "$USER" 2>/dev/null || true

echo ""
echo "==> Devcontainer setup complete. Open a new terminal to get zsh."
