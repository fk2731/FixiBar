#!/usr/bin/env bash

if [ -z "$XDG_PICTURES_DIR" ]; then
  XDG_PICTURES_DIR="$HOME/Pictures"
fi

save_dir="${3:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
full_path="/tmp/ss.png"

case $1 in
p) grimblast copysave save screen "$full_path" ;;
f) grimblast --freeze copysave area "$full_path" ;;
m) grimblast copysave output "$full_path" ;;
*) exit 1 ;;
esac

ACTION=$(notify-send -e \
  -h string:x-canonical-private-synchronous:Screenshot \
  -i "$full_path" \
  -a "FixiSS" \
  "Screenshot captured" "in $full_path" \
  -A "view=View" \
  -A "edit=Edit" \
  -A "save=Save")

case "$ACTION" in
view)
  xdg-open "$full_path"
  ;;
edit)
  swappy -f "$full_path"
  ;;
save)
  final_path="$save_dir/$save_file"
  mkdir -p "$save_dir"
  cp "$full_path" "$final_path"

  ACTION2=$(notify-send -e \
    -h string:x-canonical-private-synchronous:ScreenshotSaved \
    -i "$final_path" \
    -a "FixiSS" \
    "Screenshot saved successfully" "to $final_path" \
    -A "open=View image" \
    -A "folder=Open folder")

  case "$ACTION2" in
  open)
    xdg-open "$final_path"
    ;;
  folder)
    xdg-open "$save_dir"
    ;;
  esac
  ;;
esac
