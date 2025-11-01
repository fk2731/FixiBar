#!/usr/bin/env bash

CONFIG_FILE="$HOME/.dotfiles/Fixi/config.json"
STATE_FILE=$(jq -r '.envModeFile' "$CONFIG_FILE")
FALLBACK_MODE="normal"

if [[ -f "$STATE_FILE" ]]; then
  CURRENT_MODE=$(jq -r --arg fallback "$FALLBACK_MODE" '.mode // $fallback' "$STATE_FILE")
else
  CURRENT_MODE="$FALLBACK_MODE"
fi

# Toggle
if [[ "$CURRENT_MODE" == "power_save" ]]; then # Change to normal mode
  killall FixiBar
  python3 "$HOME/.dotfiles/Fixi/bar/bar.py" normal &
  hyprpaper &
else
  killall hyprpaper || true # Change to power_save mode
  killall FixiBar
  python3 "$HOME/.dotfiles/Fixi/bar/bar.py" power_save &
fi
