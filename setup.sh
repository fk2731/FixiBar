#!/usr/bin/env bash

set -euo pipefail

# === VARIABLES ===
REPO_URL="https://github.com/fk2731/FixiBar.git"
REPO_DIR="$HOME/.dotfiles"
REFIND_SC=0

if [ "$EUID" -eq 0 ]; then
	echo "[!IMPORTANT] Do not run this script as root"
	exit 1
fi

#  --- Updating System ---
sudo pacman -Syyu --noconfirm
sudo pacman -S --needed base-devel git --noconfirm

if [ -d "$REPO_DIR" ]; then
	echo "Updating config..."
	git -C "$REPO_DIR" pull
else
	echo "Cloning config..."
	git clone --depth=1 "$REPO_URL" "$REPO_DIR"
fi

[[ "$(pwd)" != "$REPO_DIR" ]] && cd "$REPO_DIR"

# === CONFIGURATION FUNCTIONS ===
configure_essentials() {
	sudo install -m644 pacman.conf /etc/pacman.conf
	echo "Defaults pwfeedback,insults" | sudo EDITOR='tee -a' visudo >/dev/null
}

install_cargo() {
	if ! command -v cargo &>/dev/null; then
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		export PATH="$HOME/.cargo/bin:$PATH"
		cargo install tree-sitter-cli
	fi
}

install_pacman_packages() {
	local packages=(
		efibootmgr dosfstools mtools brightnessctl zsh lsd kitty hyprland ripgrep
		hyprcursor hypridle hyprlock hyprpaper tldr stow wl-clipboard bat sddm
		npm unzip system-config-printer neovim wget bluez bluez-utils refind
		plymouth sed qt6-svg qt6-declarative qt5-quickcontrols2 qt6-wayland
		xdg-desktop-portal xdg-desktop-portal-hyprland cups rofi
	)
	sudo pacman -Syy --devel --needed --noconfirm "${packages[@]}"
}

install_yay() {
	if ! command -v yay &>/dev/null; then
		local tmpdir
		tmpdir=$(mktemp -d)
		git clone https://aur.archlinux.org/yay.git "$tmpdir"
		(cd "$tmpdir" && makepkg -si --noconfirm)
		rm -rf "$tmpdir"
	fi
}

install_yay_packages() {
	yay -Syy -Syy --pgp-import --needed --noconfirm ttf-jetbrains-mono-nerd hyprshot cava telegram-desktop \
		swaync-git vivaldi rose-pine-cursor rose-pine-hyprcursor spotify grimblast python-psutil nemo \
		python-setproctitle tesseract gpu-screen-recorder python-fabric-git celluloid jdk-lts jdtls fastfetch || true
}

setup_zsh() {
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		RUNZSH=no CHSH=yes sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
		sudo chsh -s "$(command -v zsh)"
	fi

	local theme_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
	[ -d "$theme_dir" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"

	for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
		[ -d "$HOME/.oh-my-zsh/custom/plugins/$plugin" ] ||
			git clone "https://github.com/zsh-users/$plugin" "$HOME/.oh-my-zsh/custom/plugins/$plugin"
	done

	[[ "$SHELL" != "$(command -v zsh)" ]] && sudo chsh -s "$(command -v zsh)"
}

apply_dotfiles() {
	for file in .zshrc .p10k.zsh; do
		[ -f "$HOME/$file" ] && mv "$HOME/$file" "$HOME/$file.bak"
		cp "config/$file" "$HOME/$file"
	done
	stow --adopt --target="$HOME" config
	bat cache --build
}

configure_sddm() {
	sudo cp -r ./login/catppuccin-mocha/ /usr/share/sddm/themes/
	sudo cp ./login/sddm.conf /etc/sddm.conf
	sudo systemctl enable sddm.service --force
}

setup_refind() {
	sudo install -d /boot/EFI/refind/themes/
	sudo install -m644 ./boot/os_arch.png /boot/vmlinuz-linux.png
	sudo cp -r ./boot/catppuccin/ /boot/EFI/refind/themes/
	local refind_conf="/boot/EFI/refind/refind.conf"
	local include_line="include themes/catppuccin/mocha.conf"

	if ! grep -Fxq "$include_line" "$refind_conf"; then
		echo "$include_line" | sudo tee -a "$refind_conf" >/dev/null
	fi

	if pacman -Qe grub &>/dev/null; then
		sudo pacman -Rns grub --noconfirm
	fi
}

configure_plymouth() {
	sudo install -d /usr/share/plymouth/themes/
	sudo cp -r ./boot/plymouth/catppuccin-mocha/ /usr/share/plymouth/themes/

	sudo plymouth-set-default-theme -R catppuccin-mocha
	sudo sed -i 's/^\(HOOKS=.*\)udev/\1udev plymouth/' /etc/mkinitcpio.conf
	grep -q 'quiet splash' /etc/mkinitcpio.conf ||
		sudo sed -i 's/\bquiet\b/quiet splash/' /etc/mkinitcpio.conf
	sudo mkinitcpio -P
}

enable_services() {
	systemctl --user daemon-reload
	systemctl --user enable --now battery-monitor.timer
	sudo systemctl enable bluetooth.service
	sudo install -m644 ./login/index.theme /usr/share/icons/default/index.theme
}

install_neovim() {
	local conf_dir=".config/nvim"
	local nvim_dir="$HOME/$conf_dir"
	sudo pacman -Syy neovim wl-clipboard ripgrep
	install_cargo
	[[ -d $nvim_dir ]] && mv $nvim_dir $conf_dir.bak
	install -d $nvim_dir
	cp -r conf/"$conf_dir" $nvim_dir
}

enable_secure_boot() {
	REFIND_SC=1
	yay -Syy shim-signed
	sudo pacman -Syy mokutil sbsigntools
	sudo refind-install --shim /usr/share/shim-signed/shimx64.efi --localkeys
	setup_refind
	sudo sbsign \
		--key /etc/refind.d/keys/refind_local.key \
		--cert /etc/refind.d/keys/refind_local.crt \
		--output /boot/vmlinuz-linux.signed \
		/boot/vmlinuz-linux

	sudo mv /boot/vmlinuz-linux.signed /boot/vmlinuz-linux
}

configure_refind() {
	read -rp "Do you wish enable refind for secure boot? [Y/n]: " choice
	case "$choice" in
	y)
		enable_secure_boot
		;;
	n)
		sudo refind-install
		setup_refind
		;;
	*)
		enable_secure_boot
		;;
	esac
}

# === EJECUCIÓN PRINCIPAL ===
echo -e "\n1) Install all (default)"
echo "2) Install neovim"
read -rp "Select an option: " choice

default() {
	configure_essentials
	install_pacman_packages
	install_yay
	install_yay_packages
	setup_zsh
	apply_dotfiles
	configure_sddm
	configure_refind
	configure_plymouth
	enable_services
}

case "$choice" in
1)
	default
	;;
2)
	install_neovim
	;;
*)
	default
	;;
esac

[[ $REFIND_SC -eq 1 ]] &&
	echo -e "\n [!IMPORTANT] Please reboot with Secure Boot disabled.\nThen enroll the .cer key manually from disk (likely located at: EFI/refind/keys/refind_local.cer).\nReboot with secure boot enable"
