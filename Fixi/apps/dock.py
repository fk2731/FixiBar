#!/usr/bin/env python3
import json
import os
import subprocess

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from fabric.utils import get_relative_path
from gi.repository import Gdk, GLib, Gtk, GtkLayerShell  # pyright: ignore

DIR = os.path.dirname(os.path.abspath(__file__))
config_path = get_relative_path("../config.json")

with open(config_path, "r") as f:
    config = json.load(f)

BAR_HEIGHT = config["barHeight"]
TOP_MARGIN = config["topMargin"]
CSS_FILE = get_relative_path(config["cssFile"])


class MenuWindow(Gtk.Window):
    def __init__(self, buttons):
        super().__init__()
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 0)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, TOP_MARGIN)
        GtkLayerShell.set_exclusive_zone(self, -1)

        self.set_decorated(False)
        self.set_resizable(False)

        self.set_size_request(-1, BAR_HEIGHT)

        # Load CSS
        style_provider = Gtk.CssProvider()
        style_provider.load_from_path(CSS_FILE)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        # Content
        self.box = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL, spacing=8, name="dock"
        )
        self.add(self.box)

        for icon, tooltip, command in buttons:
            label = Gtk.Label(name="icon")
            btn = Gtk.Button()
            if len(icon.split(" ")) > 1:
                self.stop = icon.split(" ")[0]
                self.record = icon.split(" ")[1]
                self.btn_screenrecord_label = label
                self.update_screenrecord_state()
            else:
                label.set_text(icon)
            label.set_xalign(0.5)
            btn.add(label)
            btn.set_tooltip_markup(tooltip)
            btn.connect("clicked", lambda _, cmd=command: self.run_script(cmd))
            self.box.pack_start(btn, True, True, 0)

        self.show_all()

    def run_script(self, command):
        subprocess.Popen(command)
        Gtk.main_quit()

    def update_screenrecord_state(self):
        try:
            # Use pgrep with -f to check for the process name anywhere in the command line
            result = subprocess.run(
                "pgrep -f gpu-screen-recorder",
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            running = result.returncode == 0
        except Exception:
            running = False

        if running:
            self.btn_screenrecord_label.set_text(
                self.stop
            )  # Cause actually is recording
            self.btn_screenrecord_label.get_style_context().add_class("stop")
        else:
            self.btn_screenrecord_label.set_text(
                self.record
            )  # Cause actually isn't recording
            self.btn_screenrecord_label.get_style_context().remove_class("recording")

        return True


def main(buttons):
    win = MenuWindow(buttons)
    win.connect("destroy", Gtk.main_quit)
    Gtk.main()
