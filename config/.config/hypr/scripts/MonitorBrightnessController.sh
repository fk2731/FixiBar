#!/usr/bin/env bash

# Monitor number (as recognized by ddcutil)
MONITOR=$1
BRIGHTNESS_STEP=5

# Current brightness
val=$(ddcutil -d "$MONITOR" getvcp 10 | awk -F'current value = |,' '{print $2}' | tr -d ' ')

if [[ -z "$val" ]]; then
	exit 1
fi

case "$2" in
up)
	new=$((val + $BRIGHTNESS_STEP))
	;;
down)
	new=$((val - $BRIGHTNESS_STEP))
	;;
*)
	echo "Usage: brightness <id> {up|down}"
	exit 1
	;;
esac

# Limit brightness between 0 and 100
((new < 0)) && new=0
((new > 100)) && new=100

# User must have permission to access the monitor via ddcutil
ddcutil -d "$MONITOR" setvcp 10 "$new"

swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')" --custom-message "Monitor $MONITOR brightness: $new%"
