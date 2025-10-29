#!/usr/bin/env python3
from modes.mode_strategy import ModeStrategy

from config import ALL_MODULES


class NormalMode(ModeStrategy):
    def get_active_modules(self) -> set[str]:
        return ALL_MODULES

    def set_env(self) -> None:
        with open("/dev/null", "w") as f:
            f.write("power_save")
