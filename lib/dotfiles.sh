#!/usr/bin/env bash

# --------------------------------------------------
# Apply Dotfiles
# --------------------------------------------------
apply_dotfiles() {
  log_info "Applying dotfiles using Stow..."

  # Backup critical files before linking
  for f in .zshrc .p10k.zsh; do
    if [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]]; then
      mv "$HOME/$f" "$HOME/$f.bak.$(date +%s)"
      log_info "Backed up $f."
    fi
  done

  # Stow
  stow --adopt --target="$HOME" config

  # Restore repo files (if 'adopt' modified them)
  git -C "$REPO_DIR" restore .
  
  # Build bat cache
  bat cache --build 2>/dev/null || true

  log_ok "Dotfiles linked."
}
