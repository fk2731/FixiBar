#!/usr/bin/env python3
import json

from fabric.utils import get_relative_path
from gi.repository import Gdk  # type: ignore

CONFIG_PATH = get_relative_path("../config.json")

with open(CONFIG_PATH, "r") as f:
    CONFIG = json.load(f)

BAR_HEIGHT = CONFIG["barHeight"]
TOP_MARGIN = CONFIG["topMargin"]
CSS_FILE = get_relative_path(CONFIG["cssFile"])
ENV_MODE_FILE = CONFIG["envModeFile"]

ALL_MODULES = {
    "date_time",
    "battery",
    "stats",
    "network",
    "bluetooth",
    "volume",
    "notifications",
    "player",
    "recorder_indicator",
    "workspaces",
}

POWER_SAVE_MODULES = {
    "date_time",
    "battery",
    "workspaces",
}


def battery_exists() -> bool:
    """Ensure 'battery' module is included if a battery is present."""
    try:
        with open("/sys/class/power_supply/BAT0/status", "r"):
            ALL_MODULES.add("battery")
            POWER_SAVE_MODULES.add("battery")
            return True
    except FileNotFoundError:
        return False


def add_hover_cursor(widget):
    """Add pointer cursor hover effect."""
    widget.add_events(Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK)
    widget.connect(
        "enter-notify-event",
        lambda w, event: w.get_window().set_cursor(
            Gdk.Cursor.new_from_name(Gdk.Display.get_default(), "pointer")
        ),
    )
    widget.connect("leave-notify-event", lambda w, event: w.get_window().set_cursor(None))
