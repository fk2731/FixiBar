#!/usr/bin/env bash

if [ -z "$XDG_VIDEOS_DIR" ]; then
  XDG_VIDEOS_DIR="$HOME/Videos"
fi

SAVE_DIR="$XDG_VIDEOS_DIR/Recordings"
mkdir -p "$SAVE_DIR"

if pgrep -f "gpu-screen-recorder" >/dev/null; then
  pkill -SIGINT -f "gpu-screen-recorder"
  sleep 1

  VIDEO=$(ls -t "$SAVE_DIR"/*.mp4 2>/dev/null | head -n 1)
  ICON=$HOME/widgets/apps/scripts/icons/movie.svg

  ACTION=$(notify-send -u low -a "FixiApp" "  Recording stopped" \
    -A "view=View" -A "open=Open folder" -i "$ICON" -t 2500)

  if [ "$ACTION" = "view" ] && [ -n "$VIDEO" ]; then
    xdg-open "$VIDEO"
  elif [ "$ACTION" = "open" ]; then
    xdg-open "$SAVE_DIR"
  fi
  exit 0
fi

# Obtener lista de monitores desde Hyprland
MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')
SELECTED=$(echo "$MONITORS" | rofi -dmenu -p "Monitor to record")

[ -z "$SELECTED" ] && notify-send -u low "No monitor selected" && exit 1

OUTPUT_FILE="$SAVE_DIR/$(date +%Y-%m-%d-%H-%M-%S).mp4"

gpu-screen-recorder -w "$SELECTED" -q ultra -a default_output -ac opus -cr full -f 60 -o "$OUTPUT_FILE"
