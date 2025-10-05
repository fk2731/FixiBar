# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EDITOR=nvim

export JAVA_HOME=/usr/lib/jvm/java-21-jdk
export PATH=$JAVA_HOME/bin:$PATH

# Alias
alias ls='lsd'
alias lst='lsd --tree'
alias la='lsd -a'

alias vi='nvim'
alias cat='bat'

alias add='git add'
alias ada='git add -A'
alias comm='git commit -m'
alias push='git push'

alias man='tldr'
alias ogman='/usr/bin/man'

sign-kernel() {
  echo "Signing Unsigned original image..."
  sudo sbsign \
    --key /etc/refind.d/keys/refind_local.key \
    --cert /etc/refind.d/keys/refind_local.crt \
    --output /boot/vmlinuz-linux.signed \
    /boot/vmlinuz-linux

  sudo mv /boot/vmlinuz-linux.signed /boot/vmlinuz-linux
}

clear-dependencies() {
  sudo pacman -Rns $(pacman -Qdtq)
}

update-system() {
  echo "Updating system..."
  sudo pacman -Syu
  sign-kernel
  echo "Clearing dependencies..."
  clear-dependencies
}
