#!/usr/bin/env python3
import gi
import signal
import subprocess

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib  # type: ignore


class RecorderIndicator(Gtk.Revealer):
    def __init__(self):
        super().__init__()
        self.set_transition_type(Gtk.RevealerTransitionType.CROSSFADE)
        self.set_transition_duration(1000)

        self.box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, name="event")

        self.label = Gtk.Label(name="icon")
        self.label.set_text("\uf692")
        self.label.get_style_context().add_class("stop")
        self.label.show()

        self.box.pack_start(self.label, True, True, 0)
        self.box.show()
        self.add(self.box)

        self.show()

        GLib.timeout_add(100, self.update_screenrecord_state)

        self.set_reveal_child(False)

    def show_indicator(self, *args):
        self.set_reveal_child(True)
        return True

    def hide_indicator(self, *args):
        self.set_reveal_child(False)
        return True

    def update_screenrecord_state(self):
        try:
            # Use pgrep with -f to check for the process name anywhere in the command line
            result = subprocess.run("pgrep -f gpu-screen-recorder", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            running = result.returncode == 0
        except Exception:
            running = False

        if running:
            self.show_indicator()
        else:
            self.hide_indicator()
        
        return True
