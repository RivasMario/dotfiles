# =============================================================================
# .zshrc — Mario's Zsh configuration
# =============================================================================

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------------------------
# PATH & ENVIRONMENT
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Fuzzy history search with Ctrl+R
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# Better ls
if command -v lsd &>/dev/null; then
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
fi

# -----------------------------------------------------------------------------
# STARTUP (Pokemon!)
# -----------------------------------------------------------------------------
if command -v pokemon-colorscripts &>/dev/null; then
    pokemon-colorscripts -r
fi

if command -v fastfetch &>/dev/null; then
    # Use custom pokemon config if it exists
    if [ -f "$HOME/.config/fastfetch/config-pokemon.jsonc" ]; then
        # If we already showed a pokemon, don't show the fastfetch logo
        if command -v pokemon-colorscripts &>/dev/null; then
            fastfetch --config "$HOME/.config/fastfetch/config-pokemon.jsonc" --logo none
        else
            fastfetch --config "$HOME/.config/fastfetch/config-pokemon.jsonc"
        fi
    else
        fastfetch
    fi
fi

# -----------------------------------------------------------------------------
# UTILS
# -----------------------------------------------------------------------------

# Dotfiles reminder — nags if no commit in 7+ days
_dotfiles_reminder() {
    # Try multiple common locations for dotfiles repo
    local dotfiles
    for dir in "$HOME/dotfiles" "/workspaces/dotfiles"; do
        if [ -d "$dir/.git" ]; then
            dotfiles="$dir"
            break
        fi
    done

    if [ -n "$dotfiles" ]; then
        local last=$(git -C "$dotfiles" log -1 --format="%ct" 2>/dev/null)
        local now=$(date +%s)
        if [ -n "$last" ] && [ $(( (now - last) / 86400 )) -ge 7 ]; then
            echo "\033[33m[dotfiles]\033[0m Last commit was $(( (now - last) / 86400 )) days ago — remember to save any new configs!"
        fi
    fi
}
_dotfiles_reminder
