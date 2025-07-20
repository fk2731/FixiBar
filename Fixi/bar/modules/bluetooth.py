#!/usr/bin/env python3
import subprocess
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib, Pango  # type: ignore


class BluetoothWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        self.icon = Gtk.Label(label="\uea37", name="icon")
        self.label = Gtk.Label()
        self.label.set_ellipsize(Pango.EllipsizeMode.END)
        self.label.set_max_width_chars(10)
        self.pack_start(self.icon, False, False, 0)
        self.pack_start(self.label, False, False, 0)

        self.update()
        GLib.timeout_add(100, self.update)

    def update(self):
        try:
            output = subprocess.check_output(["bluetoothctl", "info"], text=True)
            for line in output.splitlines():
                if line.strip().startswith("Name:"):
                    self.label.set_text(line.split("Name:")[1].strip())
                    self.icon.set_text("\uea37")  # Bluetooth icon
                    return True
            self.icon.set_text("\ueceb")
            self.label.set_text("")
        except subprocess.CalledProcessError:
            self.label.set_text("")
            self.icon.set_text("\ueceb")
        return True
