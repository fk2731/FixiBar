#!/usr/bin/env bash

tmp_dir="/tmp/cliphist"
rm -rf "$tmp_dir"
mkdir -p "$tmp_dir"

# Icono para texto (elige el que quieras)
text_icon="/usr/share/icons/hicolor/48x48/apps/text-x-generic.png"

if [[ -n "$1" ]]; then
	cliphist decode <<<"$1" | wl-copy
	exit
fi

cliphist list | awk -v dir="$tmp_dir" -v text_icon="$text_icon" '
{
    id=$1
    if ($0 ~ /binary data/ && $0 ~ /(png|jpg|jpeg|bmp)/) {
        ext="png"
        if ($0 ~ /jpg/) ext="jpg"
        if ($0 ~ /jpeg/) ext="jpeg"
        if ($0 ~ /bmp/) ext="bmp"
        system("cliphist decode " id " > " dir "/" id "." ext)
        print $0 "\0icon\x1f" dir "/" id "." ext
    } else {
        print $0 "\0icon\x1f" text_icon
    }
}' | rofi -dmenu -show-icons -i -p "Clipboard" | {
	read -r selection
	[ -n "$selection" ] && cliphist decode <<<"$selection" | wl-copy
}
