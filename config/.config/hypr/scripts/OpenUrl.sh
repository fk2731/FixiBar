#!/bin/bash

browser=$1
classBrowser=$2
url=$3

# Get the IDs of workspaces where Brave browser windows are present
browserOnWorspaces=$(hyprctl -j clients | jq -r --arg cls "$classBrowser" '.[] | select(.class == $cls) | .workspace.id')

# Open ChatGPT in a new tab if Brave is running on the current workspace
for workspaceID in $browserOnWorspaces; do
  currentWorkspace=$(hyprctl activeworkspace | grep 'ID' | awk 'NR==1 {print $3}')
  if [[ "$workspaceID" == "$currentWorkspace" ]]; then
    $browser $url
    exit 0
  fi
done

# If Brave is not on the current workspace, open a new window with ChatGPT
$browser --new-window $url
