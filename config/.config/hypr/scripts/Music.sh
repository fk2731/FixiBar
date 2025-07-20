#!/bin/bash

move=false

# If Spotify is already open, notify and exit
if [[ -n $(hyprctl -j clients | jq -r '.[] | select(.class == "Spotify")') ]]; then
  notify-send -u low "Already open" -i /usr/share/icons/hicolor/48x48/apps/spotify.png "Spotify open at workspace: $(hyprctl -j clients | jq -r '.[] | select(.class == "Spotify") | .workspace.id')" -t 2500
  exit 0
fi

# Launch Spotify in the (now) current workspace
spotify --title Spotify &
