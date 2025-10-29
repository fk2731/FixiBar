#!/usr/bin/env python3
from modes.mode_strategy import ModeStrategy

from config import POWER_SAVE_MODULES


class PowerSavingMode(ModeStrategy):
    def get_active_modules(self) -> set[str]:
        return POWER_SAVE_MODULES
