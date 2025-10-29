#!/usr/bin/env python3
import json

from modes.modes import Mode

from config import ENV_MODE_FILE


class ModeNotifier:
    @staticmethod
    def notify(mode: Mode):
        try:
            with open(ENV_MODE_FILE, "w") as f:
                json.dump({"mode": mode.value}, f)
        except Exception as e:
            print(f"[!] Failed to write mode: {e}")
