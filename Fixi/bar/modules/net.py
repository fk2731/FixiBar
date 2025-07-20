#!/usr/bin/env python3
import subprocess

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk  # type: ignore

from config import add_hover_cursor


class NetworkWidget(Gtk.EventBox):
    def __init__(self):
        super().__init__()
        self.set_visible_window(False)

        # Contenedor interno
        self.box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=3)
        self.icon = Gtk.Label(name="icon")
        self.label = Gtk.Label()

        self.box.pack_start(self.icon, False, False, 0)
        self.box.pack_start(self.label, True, True, 0)

        self.add(self.box)

        self.connect("button-press-event", self._on_click)

        add_hover_cursor(self)

        self.update()
        GLib.timeout_add(100, self.update)

    def _on_click(self, widget, event):
        if event.type == Gdk.EventType.BUTTON_PRESS and event.button == 1:
            subprocess.run(
                "~/.dotfiles/config/.config/rofi/scripts/rofi-wifi.sh", shell=True
            )

    def update(self):
        try:
            output = subprocess.check_output(
                ["nmcli", "-t", "-f", "TYPE,STATE", "device"], text=True
            )
            lines = output.strip().splitlines()

            for line in lines:
                dev_type, state = line.split(":")
                if state == "connected":
                    if dev_type == "ethernet":
                        self.icon.set_text("\uf866")
                        self.label.set_text("Fixi")
                        return True
                    elif dev_type == "wifi":
                        wifi_output = subprocess.check_output(
                            ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL", "dev", "wifi"],
                            text=True,
                        )
                        for wifi_line in wifi_output.strip().splitlines():
                            in_use, ssid, signal = wifi_line.split(":")
                            if in_use == "*":
                                signal = int(signal)
                                icon = self.get_wifi_icon(signal)
                                self.icon.set_text(icon)
                                self.label.set_text(ssid)
                                return True
        except Exception:
            self.icon.set_text("\uf9e0")
            self.label.set_text("")
        self.icon.set_text("\uf9eb")
        self.label.set_text("")
        return True

    def get_wifi_icon(self, signal):
        if signal >= 75:
            return "\ueccb"
        elif signal >= 50:
            return "\uecca"
        elif signal >= 25:
            return "\uecc9"
        else:
            return " \uecc8"
