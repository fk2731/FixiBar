#!/usr/bin/env bash

# ==================================================
# Arch Linux + Hyprland Automated Installer
# ORCHESTRATOR
# ==================================================

set -e
set -o pipefail
IFS=$'\n\t'

# --------------------------------------------------
# Global Paths & Variables
# --------------------------------------------------
REPO_URL="https://github.com/fk2731/FixiBar.git"
REPO_DIR="$HOME/.dotfiles"

# --------------------------------------------------
# Modularization: Source all functions
# --------------------------------------------------
source "$REPO_DIR/lib/logging.sh"
source "$REPO_DIR/lib/checks.sh"
source "$REPO_DIR/lib/packages.sh"
source "$REPO_DIR/lib/system.sh"
source "$REPO_DIR/lib/zsh.sh"
source "$REPO_DIR/lib/dotfiles.sh"
source "$REPO_DIR/lib/boot.sh"
source "$REPO_DIR/lib/neovim.sh"

# --------------------------------------------------
# Core Orchestration Functions
# --------------------------------------------------
banner() {
  echo -e "$BLUE$(
    cat <<'EOF'

  ______   _          _   ____                 
 |  ____| (_)        (_) |  _ \                
 | |__     _  __  __  _  | |_) |   __ _   _ __ 
 |  __|   | | \ \/ / | | |  _ <   / _` | | '__|
 | |      | |  >  <  | | | |_) | | (_| | | |   
 |_|      |_| /_/\_\ |_| |____/   \__,_| |_|   
                                               
EOF
  )$RESET"
  echo -e "${PURPLE}Arch Linux & Hyprland Automated Installer${RESET}\n"
}

update_system() {
  log_info "Updating system and synchronizing repository..."
  sudo pacman -Syyu --noconfirm git base-devel

  if [ ! -d "$REPO_DIR" ]; then
    log_info "Updating config..."
    git -C "$REPO_DIR" pull
  else
    log_info "Cloning config..."
    git clone --depth=1 "$REPO_URL" "$REPO_DIR"
  fi

  if [[ "$(pwd)" != "$REPO_DIR" ]]; then
    cd "$REPO_DIR"
  fi
}

# --------------------------------------------------
# Full Installation Pipeline
# --------------------------------------------------
full_install() {
  # 1. PRE-FLIGHT
  ensure_not_root
  keep_sudo_alive

  # 2. REPO & SYSTEM UPDATE
  update_system

  # 3. PACKAGES
  install_aur_helper
  install_packages

  # 4. SHELL & DOTFILES
  setup_zsh
  apply_dotfiles

  # 5. SYSTEM CONFIG & SERVICES
  configure_system

  # 6. BOOTLOADER
  configure_boot

  log_ok "Installation completed successfully!"
  log_warn "A system reboot is highly recommended for all changes to take effect."
  final_secure_boot_message
}

# --------------------------------------------------
# Main Menu
# --------------------------------------------------
banner
echo -e "${CYAN}1)${RESET} Full installation (recommended)"
echo -e "${CYAN}2)${RESET} Neovim only"
echo -e "${CYAN}3)${RESET} Exit"
read -rp "Select an option: " choice

case "$choice" in
1) full_install ;;
2)
  ensure_not_root
  install_neovim_config
  ;;
3) exit 0 ;;
*) full_install ;;
esac
