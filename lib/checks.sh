#!/usr/bin/env bash

# --------------------------------------------------
# Pre-flight Checks
# --------------------------------------------------
ensure_not_root() {
  if [[ $EUID -eq 0 ]]; then
    log_err "Do not run this script as root."
    exit 1
  fi
}

keep_sudo_alive() {
  log_info "Authenticating sudo and keeping session alive..."
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}
