#!/usr/bin/env bash

# --------------------------------------------------
# Neovim Configuration
# --------------------------------------------------
install_neovim_config() {
  log_info "Installing Neovim configuration..."

  local nvim="$HOME/.config/nvim"
  local nvim_repo_path="$REPO_DIR/nvim/lua"
  local nvim_config="$nvim/lua"

  # Backup
  if [[ -d "$nvim" ]]; then
    mv "$nvim" "$nvim.bak.$(date +%s)"
    log_info "Backed up existing Neovim config."
  fi

  # Install
  log_info "Installing NvChad repository..."

  git clone https://github.com/NvChad/starter "$nvim"

  log_info "Using Fixi configuration..."

  cat "$nvim_repo_path/chadrc.lua" > "$nvim_config/chadrc.lua"
  cat "$nvim_repo_path/autocmds.lua" >> "$nvim_config/autocmds.lua"
  cat "$nvim_repo_path/mappings.lua" >> "$nvim_config/mappings.lua"
  cat "$nvim_repo_path/options.lua" >> "$nvim_config/options.lua"
  cat "$nvim_repo_path/plugins/init.lua" > "$nvim_config/plugins/init.lua"
  for i in "$nvim_repo_path"/plugins/*; do
    cp "$i" "$nvim_config/plugins/"
  done

  sed -i 's/servers *= *{.*}/servers = {\n  "html",\n  "cssls",\n  "ts_ls",\n  "astro",\n  "pyright",\n  "bashls",\n  "marksman",\n  "grammarly-languageserver",\n  "clangd",\n  "biome",\n  "tailwindcss",\n}/' "$nvim/configs/lspconfig.lua"

  log_ok "Neovim configuration copied."
}
