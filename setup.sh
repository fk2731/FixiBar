#!/usr/bin/env bash
set -e
  
RESET='\e[0m'
BLUE='\e[1;34m'

log_info() { echo -e "${BLUE}[INFO] ${RESET} $1"; }

REPO_URL="https://github.com/fk2731/FixiBar.git"
REPO_DIR="$HOME/.dotfiles"

log_info "Downloading FixiBar & updating system..."
# sudo pacman -Syyu --needed --noconfirm git base-devel
# git clone --depth=1 "$REPO_URL" "$REPO_DIR"

"$REPO_DIR/install.sh"
