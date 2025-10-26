#!/bin/bash

image=$HOME/.dotfiles/Fixi/apps/scripts/icons/ocr.svg

ocr_text=$(grimblast --freeze save area - | tesseract -l spa - - 2>/dev/null)

# Check if OCR was successful
if [[ -n "$ocr_text" ]]; then
  echo -n "$ocr_text" | wl-copy
  notify-send "OCR Success" "Text Copied to Clipboard" -i $image -t 2000
fi
