#!/usr/bin/env bash
# Devcontainer-specific setup.
# Invokes the main install.sh with SKIP_PACKAGES=1 (packages already in Dockerfile).

set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$DOTFILES"
export SKIP_PACKAGES=1
bash install.sh

# Start tailscaled in userspace mode if not already running (container has no TUN).
if command -v tailscaled &>/dev/null && ! pgrep -x tailscaled &>/dev/null; then
    echo "==> Starting tailscaled (userspace networking)..."
    sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &>/dev/null &
    sleep 1
fi

# Allow vscode user to run tailscale without sudo.
if command -v tailscale &>/dev/null; then
    sudo tailscale set --operator="$USER" 2>/dev/null || true
    echo ""
    echo "==> Tailscale ready. Run: tailscale up --accept-dns=false --accept-routes --exit-node=100.81.194.15"
fi
