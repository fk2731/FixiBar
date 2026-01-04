#!/usr/bin/env bash

# --------------------------------------------------
# System Configuration
# --------------------------------------------------
configure_system() {
  log_info "Configuring system: pacman.conf, sudoers, user groups, and services..."

  # pacman.conf
  sudo install -m644 "$REPO_DIR/pacman/pacman.conf" /etc/pacman.conf 2>/dev/null || log_warn "pacman.conf not found or failed to copy."

  # Sudoers defaults
  echo "Defaults pwfeedback,insults" | sudo tee /etc/sudoers.d/00-custom >/dev/null
  sudo chmod 440 /etc/sudoers.d/00-custom

  # User groups
  sudo modprobe i2c-dev || true
  sudo usermod -aG i2c "$USER" || log_warn "Failed to add user to groups."

  # SDDM config
  log_info "Configuring sddm..."
  setup_sddm

  # Enable services
  sudo systemctl enable sddm.service --force
  sudo systemctl enable bluetooth.service
  sudo systemctl enable --now swayosd-libinput-backend.service
  sudo systemctl enable cups.service

  log_ok "System configuration applied."
}

setup_sddm() {
  sudo cp -r ./login/catppuccin-mocha/ /usr/share/sddm/themes/
  sudo cp ./login/sddm.conf /etc/sddm.conf
  sudo install -m644 ./login/index.theme /usr/share/icons/default/index.theme
}
