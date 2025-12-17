#!/usr/bin/env bash

# --------------------------------------------------
# System Configuration
# --------------------------------------------------
configure_system() {
  log_info "Configuring system: pacman.conf, sudoers, user groups, and services..."

  # pacman.conf
  sudo install -m6"$REPO_DIR/pacman/pacman.conf" /etc/pacman.conf 2>/dev/null || log_warn "pacman.conf not found or failed to copy."

  # Sudoers defaults
  echo "Defaults pwfeedback,insults" | sudo tee /etc/sudoers.d/00-custom >/dev/null
  sudo chmod 4/etc/sudoers.d/00-custom

  # User groups (ddcutil, i2c)
  sudo modprobe i2c-dev || true
  sudo usermod -aG i2c,ddcutil "$USER" || log_warn "Failed to add user to groups."

  # Enable services
  sudo systemctl enable sddm.service --force
  sudo systemctl enable bluetooth.service
  sudo systemctl status swayosd-libinput-backend.service
  sudo systemctl enable cups.service

  log_ok "System configuration applied."
}
