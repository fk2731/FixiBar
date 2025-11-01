#!/usr/bin/env bash

image=$HOME/.dotfiles/Fixi/apps/scripts/icons/ocr.svg

ocr_text=$(grimblast --freeze save area - | tesseract -l spa - - 2>/dev/null)

# Check if OCR was successful
if [[ -n "$ocr_text" ]]; then
  echo -n "$ocr_text" | wl-copy
  notify-send -e -h string:x-canonical-private-synchronous:ocr "OCR Success" "Text Copied to Clipboard" -i $image -t 2000
fi
