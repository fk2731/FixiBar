#!/usr/bin/env bash

AUR_PKGS=(
  efibootmgr
  dosfstools
  mtools
  brightnessctl
  zsh
  lsd
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
  tldr
  system-config-printer
  sed
  ttf-jetbrains-mono-nerd
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
  yay -S --needed --noconfirm "${AUR_PKGS[@]}" || log_warn "Some AUR packages failed, continuing."
  log_ok "Package installation completed."
}

setup_rust() {
  if ! command -v cargo &>/dev/null; then
    log_info "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    cargo install tree-sitter-cli # Nvim stuff
    log_ok "Rust installed."
  else
    log_ok "Rust already installed."
  fi
}
