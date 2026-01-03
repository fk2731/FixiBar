#!/usr/bin/env bash

FAILED_AUR_PKGS=()

AUR_PKGS=(
  efibootmgr
  dosfstools
  mtools
  brightnessctl
  zsh
  lsd
  less
  kitty
  neovim
  hyprland
  hyprcursor
  hypridle
  hyprlock
  hyprpaper
  wl-clipboard
  bat
  ripgrep
  stow
  sddm
  playerctl
  plymouth
  cups
  bluez
  bluez-utils
  refind
  rofi-calc
  rofi
  wget
  unzip
  npm
  qt6-svg
  qt6-declarative
  qt5-quickcontrols2
  qt6-wayland
  xdg-desktop-portal
  xdg-desktop-portal-hyprland-git
  system-config-printer
  sed
  hyprshot
  cava
  swaync-git
  spotify
  vivaldi
  grimblast-git
  rose-pine-cursor
  rose-pine-hyprcursor
  nemo
  gpu-screen-recorder
  python-psutil
  python-setproctitle
  python-pydbus
  python-fabric-git
  jdk-lts
  jdtls
  fastfetch
  hyprshade
  cliphist
  swayosd-git
  inter-font
  ddcutil
  kuro-appimage
  r-quick-share-bin
  tesseract
  tesseract-data-spa
  ttf-apple-emoji
  tldr
  ttf-jetbrains-mono-nerd
  tree-sitter-cli
  rofi-emoji
  rofi-calc
  wtype
  adw-bluetooth
  swappy
  hyprpicker
)

# --------------------------------------------------
# Installation Functions
# --------------------------------------------------
install_aur_helper() {
  if command -v yay &>/dev/null; then
    log_ok "yay already installed."
    return
  fi

  log_info "Installing yay (AUR Helper)..."
  local tmp
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp"
  (cd "$tmp" && makepkg -si --noconfirm)
  log_ok "yay installed."
}

install_packages() {
  log_info "Installing AUR packages (Yay)..."

  for pkg in "${AUR_PKGS[@]}"; do
    yay -S --needed --noconfirm "$pkg" || {
      log_warn Fail to install "$pkg"
      FAILED_AUR_PKGS+=("$pkg")
    }
  done 

  log_ok "Package installation completed."
}

print-missing-packages() {
  (( ${#FAILED_AUR_PKGS[@]} )) && {
    log_warn "Fail installation packages:"
    printf ' - %s\n' "${FAILED_AUR_PKGS[@]}"
    log_warn "Need manual intervention"
  }
}
