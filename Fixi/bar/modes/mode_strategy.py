#!/usr/bin/env python3
import abc


class ModeStrategy(abc.ABC):
    @abc.abstractmethod
    def get_active_modules(self) -> set[str]:
        """Return the set of active modules for this mode."""
        pass
