#!/usr/bin/env python3
from modes.mode_strategy import ModeStrategy
from modes.modes import Mode
from modes.normal_mode import NormalMode
from modes.power_saving_mode import PowerSavingMode


class ModeFactory:
    """Factory to create ModeStrategy instances, return NormalMode as default."""

    @staticmethod
    def create_mode(mode: Mode) -> ModeStrategy:
        if mode == Mode.POWER_SAVE:
            return PowerSavingMode()
        return NormalMode()
