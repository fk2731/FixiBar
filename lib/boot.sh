#!/usr/bin/env bash

# --------------------------------------------------
# Main Function
# --------------------------------------------------

configure_boot() {
  plymouth_setup

  echo ""
  read -rp "Do you wish to enable rEFInd for Secure Boot? [Y/n]: " choice
  case "$choice" in
  [yY]) enable_secure_boot ;;
  [nN])
    sudo refind-install
    setup_refind_basic
    ;;
  *) enable_secure_boot ;;
  esac

  if pacman -Qe grub &>/dev/null; then
    log_warn "Removing GRUB..."
    sudo pacman -Rns grub --noconfirm
  fi

  log_ok "Boot configuration applied."
}

REFIND_SC=0

setup_refind() {
  log_info " Setup rEFInd..."

  sudo install -d /boot/EFI/refind/themes/
  sudo install -m644 "$REPO_DIR/boot/os_arch.png" /boot/vmlinuz-linux.png

  sudo install -d /boot/EFI/refind/themes/

  sudo cp -r "$REPO_DIR/boot/catppuccin/" /boot/EFI/refind/themes/
  local refind_conf="/boot/EFI/refind/refind.conf"
  local include_line="include themes/catppuccin/mocha.conf"
  if [ -f "$refind_conf" ] && ! grep -Fxq "$include_line" "$refind_conf"; then
    echo "$include_line" | sudo tee -a "$refind_conf" >/dev/null
  fi

}

enable_secure_boot() {
  log_info "Enable Secure Boot (Shim + Mokutil)..."
  REFIND_SC=1

  yay -S --needed --noconfirm shim-signed || log_err "Error instalando shim-signed."
  sudo pacman -S --needed --noconfirm mokutil sbsigntools || log_err "Error instalando deps de SB."

  sudo refind-install --shim /usr/share/shim-signed/shimx64.efi --localkeys

  setup_refind

  local key="/etc/refind.d/keys/refind_local.key"
  local cert="/etc/refind.d/keys/refind_local.crt"

  if [ -f "$key" ] && [ -f "$cert" ]; then
    log_info "Firmando el kernel vmlinuz-linux..."

    sudo sbsign \
      --key "$key" \
      --cert "$cert" \
      --output /boot/vmlinuz-linux /boot/vmlinuz-linux

    log_ok "Kernel signed."

    sign_on_update
  else
    log_err "rEFInd keys not found."
  fi
}

final_secure_boot_message() {
  if [[ $REFIND_SC -eq 1 ]]; then
    log_warn "Please reboot with Secure Boot ${RED}DISABLED${RESET}.\nThen enroll the .cer key manually from disk using MokManager.\n(Key likely located at: EFI/refind/keys/refind_local.cer)\nThen reboot with Secure Boot ENABLED."
  fi
}

plymouth_setup() {
  log_info "Plymouth..."

  sudo install -d /usr/share/plymouth/themes
  sudo cp -r "$REPO_DIR/boot/plymouth/catppuccin-mocha" /usr/share/plymouth/themes/
  sudo plymouth-set-default-theme -R catppuccin-mocha

  grep -q "plymouth" /etc/mkinitcpio.conf ||
    sudo sed -i 's/^\(HOOKS=.*\)udev/\1udev plymouth/' /etc/mkinitcpio.conf

  grep -q "quiet splash" /etc/mkinitcpio.conf ||
    sudo sed -i 's/\bquiet\b/quiet splash/' /etc/mkinitcpio.conf

  sudo mkinitcpio -P
}

sign_on_update() {
  log_info "Setting up automatic kernel signing on updates..."

  sudo install -d -m 755 /etc/pacman.d/hooks
  sudo install -d -m 755 /usr/local/lib/pacman-hooks

  # Hooks
  sudo install -m 644 "$REPO_DIR/pacman/hooks/"*.hook /etc/pacman.d/hooks/

  # Hook scripts
  sudo install -m 755 "$REPO_DIR/pacman/hooks.bin/"*.sh /usr/local/lib/pacman-hooks/
}
