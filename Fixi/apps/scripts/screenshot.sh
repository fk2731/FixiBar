#!/usr/bin/env sh

sleep 0.25

if [ -z "$XDG_PICTURES_DIR" ]; then
  XDG_PICTURES_DIR="$HOME/Pictures"
fi

save_dir="${3:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
full_path="/tmp/ss.png"

case $1 in
p) grimblast save screen "$full_path" ;;
f)
  hyprshot --freeze -m region --clipboard-only -s
  wl-paste >"$full_path"
  ;;
m) grimblast save output "$full_path" ;;
*)
  exit 1
  ;;
esac

ACTION=$(notify-send -u low -a "FixiSS" -i "$full_path" "Screenshot saved" "in $full_path" \
  -A "view=View" -A "save=Save" -A "copy=Copy" -t 2500)

case "$ACTION" in
view) xdg-open "$full_path" ;;
save) cp "$full_path" "$save_dir/$save_file" && notify-send -a "FixiSS" "Screenshot saved" "to $save_dir/$save_file" ;;
copy) wl-copy <"$full_path" && notify-send -u low -a "FixiSS" "Screenshot copied" "to clipboard" -i $full_path ;;
esac
