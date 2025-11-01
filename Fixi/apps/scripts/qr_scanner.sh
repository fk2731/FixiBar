#!/usr/bin/env bash
grim -g "$(slurp)" /tmp/qrcode && wl-copy -p "$(zbarimg -q --raw /tmp/qrcode)" && xdg-open "$(wl-paste -p)"
