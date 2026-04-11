#!/usr/bin/env bash
# Devcontainer-specific setup.
# Invokes the main install.sh with SKIP_PACKAGES=1 (packages already in Dockerfile).

set -e
DOTFILES="/workspaces/dotfiles"

cd "$DOTFILES"
export SKIP_PACKAGES=1
bash install.sh
