#!/usr/bin/env python3
import time

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk  # type: ignore


class ClockWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)

        self.time = Gtk.Label()

        self.pack_start(self.time, False, False, 0)

        self.update_time()
        GLib.timeout_add(1000, self.update_time)

    def update_time(self):
        self.time.set_text(time.strftime("%H:%M"))
        return True
