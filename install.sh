#!/usr/bin/env bash
# =============================================================================
# dotfiles/install.sh — Mario's setup bootstrap
# Works on Fedora, Debian/Ubuntu, and GitHub Codespaces.
# =============================================================================

set -e
export DEBIAN_FRONTEND=noninteractive
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "==> Mario's dotfiles installer"
echo "    Dotfiles dir: $DOTFILES"
echo ""

# Check for sudo password requirement
if ! sudo -n true 2>/dev/null; then
    echo "==> [!] Sudo requires a password. Please be ready to enter it."
fi

# -----------------------------------------------------------------------------
# PACKAGES
# -----------------------------------------------------------------------------
if [ -z "$SKIP_PACKAGES" ]; then
    echo "==> Installing packages..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y \
            tmux zsh fzf fastfetch git curl nodejs npm python3 lsd libsecret tailscale sshpass
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            tmux zsh fzf git curl nodejs npm python3 libsecret-1-0 sshpass || true
        # fastfetch and lsd not in standard apt repos — install separately
        if ! command -v fastfetch &>/dev/null; then
            FASTFETCH_DEB=$(mktemp --suffix=.deb)
            if command -v dpkg &>/dev/null && curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb" -o "$FASTFETCH_DEB" 2>/dev/null; then
                sudo dpkg -i "$FASTFETCH_DEB" && rm -f "$FASTFETCH_DEB" || echo "  [!] fastfetch deb install failed, trying tarball."
            fi
            # Fallback: extract binary to ~/.local/bin (works without root / when dpkg absent)
            if ! command -v fastfetch &>/dev/null; then
                mkdir -p "$HOME/.local/bin"
                FASTFETCH_TGZ=$(mktemp --suffix=.tar.gz)
                if curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.tar.gz" -o "$FASTFETCH_TGZ" 2>/dev/null; then
                    tar -xzf "$FASTFETCH_TGZ" -C /tmp/ 2>/dev/null && \
                        cp /tmp/fastfetch-linux-amd64/usr/bin/fastfetch "$HOME/.local/bin/fastfetch" && \
                        chmod +x "$HOME/.local/bin/fastfetch" && \
                        echo "  fastfetch installed to ~/.local/bin/fastfetch" || echo "  [!] fastfetch tarball install failed, skipping."
                fi
                rm -f "$FASTFETCH_TGZ"
            fi
        fi
        if ! command -v lsd &>/dev/null; then
            LSD_DEB=$(mktemp --suffix=.deb)
            curl -fsSL "https://github.com/lsd-rs/lsd/releases/latest/download/lsd_amd64.deb" -o "$LSD_DEB" && \
                sudo dpkg -i "$LSD_DEB" && rm -f "$LSD_DEB" || echo "  [!] lsd install failed, skipping."
        fi
    elif command -v brew &>/dev/null; then
        brew install tmux zsh fzf fastfetch git node python3 lsd libsecret tailscale
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
    PYTHON_CMD=$(command -v python3 || command -v python)
    if [ -n "$PYTHON_CMD" ]; then
        sudo bash install.sh
    else
        echo "  [!] Python not found, skipping pokemon-colorscripts installation."
    fi
    cd "$DOTFILES"
fi

# Fix CRLF in pokemon-colorscripts — Windows checkouts corrupt the shebang.
for _pokemon_file in \
    /usr/local/opt/pokemon-colorscripts/pokemon-colorscripts.py \
    /usr/local/bin/pokemon-colorscripts; do
    if [ -f "$_pokemon_file" ] && grep -qP '\r' "$_pokemon_file" 2>/dev/null; then
        sudo sed -i 's/\r//' "$_pokemon_file" && echo "  Fixed CRLF in $_pokemon_file"
    fi
done
unset _pokemon_file

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
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.claude"

link "$DOTFILES/.tmux.conf"                              "$HOME/.tmux.conf"
link "$DOTFILES/.tmux-help.txt"                          "$HOME/.tmux-help.txt"
link "$DOTFILES/.zshrc"                                  "$HOME/.zshrc"
link "$DOTFILES/config/fastfetch/config-pokemon.jsonc"   "$HOME/.config/fastfetch/config-pokemon.jsonc"
link "$DOTFILES/config/ssh/config"                       "$HOME/.ssh/config"
link "$DOTFILES/.claude/settings.json"                   "$HOME/.claude/settings.json"

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
# TAILSCALE
# -----------------------------------------------------------------------------
if ! command -v tailscale &>/dev/null; then
    echo "==> Installing Tailscale..."
    if command -v apt-get &>/dev/null; then
        curl -fsSL https://tailscale.com/install.sh | sh || echo "  [!] Tailscale install failed, skipping."
    fi
    # dnf and brew already handled in the PACKAGES section above
fi

if command -v tailscale &>/dev/null; then
    # Start daemon if not running
    if ! pgrep -x tailscaled &>/dev/null; then
        if [ "$CODESPACES" = "true" ] || [ -f "/.dockerenv" ] || grep -qE 'docker|lxc|container' /proc/1/cgroup 2>/dev/null; then
            # Container — use real TUN if available (devcontainer runArgs may provide it).
            if [ -c /dev/net/tun ]; then
                sudo tailscaled --socks5-server=localhost:1055 &>/dev/null &
            else
                sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &>/dev/null &
            fi
            sleep 1
        elif command -v systemctl &>/dev/null; then
            sudo systemctl enable --now tailscaled 2>/dev/null || true
        fi
    fi

    # Let current user run tailscale without sudo in future
    sudo tailscale set --operator="$USER" 2>/dev/null || true

    echo ""
    echo "==> Tailscale ready. Connect with:"
    echo "    tailscale up --accept-dns=false --accept-routes --exit-node=100.81.194.15"
fi

# -----------------------------------------------------------------------------
# SET ZSH AS DEFAULT SHELL
# -----------------------------------------------------------------------------
if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo ""
    echo "==> Setting zsh as default shell..."
    sudo usermod --shell "$(command -v zsh)" "$USER"
fi

echo ""
echo "==> Done! exec zsh to start."
