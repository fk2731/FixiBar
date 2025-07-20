#!/usr/bin/env python3

import gi
import subprocess

gi.require_version("Gtk", "3.0")

from gi.repository import Gtk, GLib  # type: ignore


class VolumeWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        self.icon = Gtk.Label(name="icon")
        self.label = Gtk.Label()

        self.pack_start(self.icon, False, False, 0)
        self.pack_start(self.label, False, False, 0)
        self.update_volume()

        GLib.timeout_add(100, self.update_volume)

    def get_volume(self):
        result = subprocess.run(
            ["pactl", "get-sink-volume", "@DEFAULT_SINK@"],
            stdout=subprocess.PIPE,
            text=True,
        )
        return int(result.stdout.split("/")[1].replace("%", "").strip())

    def is_muted(self):
        result = subprocess.run(
            ["pactl", "get-sink-mute", "@DEFAULT_SINK@"],
            stdout=subprocess.PIPE,
            text=True,
        )
        return "yes" in result.stdout

    def update_volume(self):
        volume = self.get_volume()
        muted = self.is_muted()

        if volume == 0:
            self.icon.set_text("\ueb50")
        elif muted:
            self.icon.set_text("\uf1c3")
        elif volume < 50:
            self.icon.set_text("\ueb4f")
        else:
            self.icon.set_text("\ueb51")

        self.label.set_text(f"{volume}")
        return True  # keep updating
