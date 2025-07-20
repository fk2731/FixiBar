#!/usr/bin/env python3
import os

import setproctitle
from dock import main
from fabric.utils import get_relative_path

DIR = os.path.dirname(os.path.abspath(__file__))

OCR_SCRIPT = get_relative_path("scripts/ocr.sh")
SCREENSHOT_SCRIPT = get_relative_path("scripts/screenshot.sh")
RECORD_SCRIPT = get_relative_path("scripts/screenrecord.sh")

buttons = [
    ("\ufcc3", "OCR", [OCR_SCRIPT]),
    ("\uf02a", "Print current screen", [SCREENSHOT_SCRIPT, "m"]),
    ("\ued37", "Print all screens", [SCREENSHOT_SCRIPT, "p"]),
    ("\ueaea", "Snip area", [SCREENSHOT_SCRIPT, "f"]),
    ("\uf698 \ued22", "Record screen", [RECORD_SCRIPT]),
]

if __name__ == "__main__":
    setproctitle.setproctitle("FixiApp")
    main(buttons)
