#!/usr/bin/env bash

setup_zsh() {
  log_info "Configuring Zsh (Oh My Zsh, P10k, Plugins)..."

  # Install Oh My Zsh
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=yes sh -c \
      "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended
  fi

  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # Install Plugins/Theme
  declare -A plugins=(
    ["themes/powerlevel10k"]="https://github.com/romkatv/powerlevel10k.git"
    ["plugins/zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["plugins/zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  )

  for path in "${!plugins[@]}"; do
    if [[ ! -d "$ZSH_CUSTOM/$path" ]]; then
      log_info "Cloning $path..."
      git clone --depth=1 "${plugins[$path]}" "$ZSH_CUSTOM/$path"
    fi
  done

  if [[ "$SHELL" != */zsh ]]; then
    log_info "Changing default shell to zsh..."
    sudo chsh -s "$(command -v zsh)" "$USER"
  fi

  log_ok "Zsh configured."
}
