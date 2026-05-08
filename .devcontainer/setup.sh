#!/usr/bin/env bash
# Devcontainer-specific setup.
# Invokes the main install.sh with SKIP_PACKAGES=1 (packages already in Dockerfile).

set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Normalize CRLF line endings that survive a Windows-side clone (defensive — safe if already LF).
find "$DOTFILES" -name "*.sh" -exec sed -i 's/\r$//' {} +

cd "$DOTFILES"
export SKIP_PACKAGES=1
bash install.sh

# Start tailscaled if not already running.
# Use real TUN when the device is available (runArgs provides /dev/net/tun),
# otherwise fall back to userspace networking.
if command -v tailscaled &>/dev/null && ! pgrep -x tailscaled &>/dev/null; then
    if [ -c /dev/net/tun ]; then
        echo "==> Starting tailscaled (kernel TUN)..."
        sudo tailscaled --socks5-server=localhost:1055 &>/dev/null &
    else
        echo "==> Starting tailscaled (userspace networking)..."
        sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &>/dev/null &
    fi
    sleep 1
fi

# Allow vscode user to run tailscale without sudo.
if command -v tailscale &>/dev/null; then
    sudo tailscale set --operator="$USER" 2>/dev/null || true
    echo ""
    echo "==> Tailscale ready. Run: tailscale up --accept-dns=false --accept-routes --exit-node=100.81.194.15"
fi
