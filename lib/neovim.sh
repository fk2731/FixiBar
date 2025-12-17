#!/usr/bin/env bash

# --------------------------------------------------
# Neovim Configuration
# --------------------------------------------------
install_neovim_config() {
  log_info "Installing Neovim configuration..."

  local nvim="$HOME/.config/nvim"
  local nvim_repo_path="$REPO_DIR/config/.config/nvim"

  # Backup
  if [[ -d "$nvim" ]]; then
    mv "$nvim" "$nvim.bak.$(date +%s)"
    log_info "Backed up existing Neovim config."
  fi

  # Install
  if [[ -d "$nvim_repo_path" ]]; then
    mkdir -p "$nvim"
    cp -r "$nvim_repo_path/"* "$nvim/"
    log_ok "Neovim configuration copied."
  else
    log_err "Neovim config source not found at $nvim_repo_path."
  fi
}
