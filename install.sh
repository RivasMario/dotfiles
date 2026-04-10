#!/usr/bin/env bash
# =============================================================================
# dotfiles/install.sh — Mario's setup bootstrap
# Run this on a fresh Fedora machine:
#   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && bash install.sh
# =============================================================================

set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "==> Mario's dotfiles installer"
echo "    Dotfiles dir: $DOTFILES"
echo ""

# -----------------------------------------------------------------------------
# PACKAGES
# -----------------------------------------------------------------------------
echo "==> Installing packages..."
sudo dnf install -y \
    tmux \
    zsh \
    fzf \
    fastfetch \
    git \
    curl

# lsd (better ls) — not always in default dnf repos, try copr first
if ! command -v lsd &>/dev/null; then
    echo "==> Installing lsd..."
    sudo dnf copr enable -y atim/lsd 2>/dev/null || true
    sudo dnf install -y lsd || echo "  [!] lsd not available via dnf — install manually from https://github.com/lsd-rs/lsd/releases"
fi

# -----------------------------------------------------------------------------
# OH MY ZSH
# -----------------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "==> Oh My Zsh already installed, skipping."
fi

# zsh-autosuggestions
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "==> Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "==> Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# -----------------------------------------------------------------------------
# POKEMON COLORSCRIPTS
# -----------------------------------------------------------------------------
if ! command -v pokemon-colorscripts &>/dev/null; then
    echo "==> Installing pokemon-colorscripts..."
    cd "$DOTFILES/pokemon-colorscripts"
    sudo bash install.sh
    cd "$DOTFILES"
else
    echo "==> pokemon-colorscripts already installed, skipping."
fi

# -----------------------------------------------------------------------------
# SYMLINK DOTFILES
# Symlinks mean editing the file in ~/dotfiles/ updates it everywhere.
# -----------------------------------------------------------------------------
echo ""
echo "==> Linking dotfiles..."

link() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "  [backup] $dst -> $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sf "$src" "$dst"
    echo "  linked: $dst"
}

mkdir -p "$HOME/.config/fastfetch"

link "$DOTFILES/.tmux.conf"                              "$HOME/.tmux.conf"
link "$DOTFILES/.tmux-help.txt"                          "$HOME/.tmux-help.txt"
link "$DOTFILES/.zshrc"                                  "$HOME/.zshrc"
link "$DOTFILES/config/fastfetch/config-pokemon.jsonc"   "$HOME/.config/fastfetch/config-pokemon.jsonc"

# -----------------------------------------------------------------------------
# SET ZSH AS DEFAULT SHELL
# -----------------------------------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "==> Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# -----------------------------------------------------------------------------
# DONE
# -----------------------------------------------------------------------------
echo ""
echo "==> Done! Things to do manually:"
echo "    1. Push this repo to GitHub:  git remote add origin https://github.com/YOUR_USERNAME/dotfiles.git"
echo "    2. Restart your terminal or run: exec zsh"
echo "    3. Open tmux and press Ctrl+a h to see your shortcuts"
echo ""
