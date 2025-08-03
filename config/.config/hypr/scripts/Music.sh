#!/bin/bash

move=false

# If Spotify is already open, notify and exit
if [[ -n $(hyprctl -j clients | jq -r '.[] | select(.class == "Spotify")') ]]; then
  notify-send -u low "Already open" -i /usr/share/icons/hicolor/48x48/apps/spotify.png "Spotify open at workspace: $(hyprctl -j clients | jq -r '.[] | select(.class == "Spotify") | .workspace.id')" -t 2500
  exit 0
fi

current_ws=$(hyprctl activeworkspace | grep 'ID' | awk 'NR==1 {print $3}')

# Check if the current workspace is in use (has any client)
if [[ -n $(hyprctl clients | grep "workspace" | grep "$current_ws") ]]; then
  # Switch to an empty workspace
  hyprctl dispatch workspace empty n+1 &
  move=true
fi

# Launch Spotify in the (now) current workspace
spotify --title Spotify &
