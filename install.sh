#!/usr/bin/env bash
# =============================================================================
# dotfiles/install.sh — Mario's setup bootstrap
# Works on Fedora, Debian/Ubuntu, and GitHub Codespaces.
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
if [ -z "$SKIP_PACKAGES" ]; then
    echo "==> Installing packages..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y \
            tmux zsh fzf fastfetch git curl nodejs npm python3 lsd libsecret
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            tmux zsh fzf fastfetch git curl nodejs npm python3 lsd libsecret-1-0
    elif command -v brew &>/dev/null; then
        brew install tmux zsh fzf fastfetch git node python3 lsd libsecret
    else
        echo "  [!] No supported package manager found (dnf, apt, brew). Please install requirements manually."
    fi
else
    echo "==> Skipping package installation (SKIP_PACKAGES=1)"
fi

# -----------------------------------------------------------------------------
# OH MY ZSH
# -----------------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "==> Oh My Zsh already installed, skipping."
fi

# zsh-plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# -----------------------------------------------------------------------------
# POKEMON COLORSCRIPTS
# -----------------------------------------------------------------------------
if ! command -v pokemon-colorscripts &>/dev/null; then
    echo "==> Installing pokemon-colorscripts..."
    cd "$DOTFILES/pokemon-colorscripts"
    # Ensure it uses the right python even if 'python3' is just 'python'
    PYTHON_CMD=$(command -v python3 || command -v python)
    if [ -n "$PYTHON_CMD" ]; then
        sudo bash install.sh
    else
        echo "  [!] Python not found, skipping pokemon-colorscripts installation."
    fi
    cd "$DOTFILES"
else
    echo "==> pokemon-colorscripts already installed, skipping."
fi

# -----------------------------------------------------------------------------
# SYMLINK DOTFILES
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
# NPM GLOBAL PREFIX
# -----------------------------------------------------------------------------
echo "==> Configuring npm global prefix..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH

# -----------------------------------------------------------------------------
# TOOLS (Claude, Gemini)
# -----------------------------------------------------------------------------
if ! command -v claude &>/dev/null; then
    echo "==> Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

if ! command -v gemini &>/dev/null; then
    echo "==> Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi

# Plugins/Extensions
if command -v claude &>/dev/null; then
    yes | claude plugin marketplace add JuliusBrussee/caveman 2>/dev/null || true
    yes | claude plugin install caveman@caveman 2>/dev/null || true
fi
if command -v gemini &>/dev/null; then
    yes | gemini extensions install https://github.com/JuliusBrussee/caveman 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# SET ZSH AS DEFAULT SHELL
# -----------------------------------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "==> Setting zsh as default shell..."
    if [ "$CODESPACES" = "true" ]; then
        sudo usermod --shell "$(which zsh)" "$USER"
    else
        chsh -s "$(which zsh)"
    fi
fi

echo ""
echo "==> Done! exec zsh to start."
