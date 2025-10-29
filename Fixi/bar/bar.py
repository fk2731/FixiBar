#!/usr/bin/env python3
import json
import signal
import subprocess
import sys

import gi
import setproctitle

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")

from gi.repository import Gdk, Gtk, GtkLayerShell  # type: ignore
from modes.mode_factory import ModeFactory
from modes.mode_notifier import ModeNotifier
from modes.modes import Mode
from modules.battery import BatteryWidget
from modules.bluetooth import BluetoothWidget
from modules.calendar_widget import CalendarWidget
from modules.clock import ClockWidget
from modules.memory import MemoryWidget
from modules.net import NetworkWidget
from modules.notifications import NotificationWidget
from modules.player import Player
from modules.recorder_indicator import RecorderIndicator
from modules.volume import VolumeWidget
from modules.workspaces import WorkspacesWidget

from config import (BAR_HEIGHT, CSS_FILE, ENV_MODE_FILE, TOP_MARGIN,
                    add_hover_cursor, battery_exists)


class BarDef(Gtk.Window):
    def __init__(self):
        super().__init__()
        self.set_resizable(False)
        self.set_decorated(False)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "FixiBar")

        display = Gdk.Display.get_default()
        monitor = display.get_monitor(1) if display.get_n_monitors() > 1 else display.get_monitor(0)

        GtkLayerShell.set_monitor(self, monitor)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_exclusive_zone(self, BAR_HEIGHT)

        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, TOP_MARGIN)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.LEFT, 10)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, 10)

        self.set_size_request(-1, BAR_HEIGHT)
        self.set_name("bar")

        if len(sys.argv) > 1:
            flag = sys.argv[1]
            mode = Mode(flag) if flag in [m.value for m in Mode] else Mode.NORMAL

        else:
            try:
                with open(ENV_MODE_FILE, "r") as f:
                    data = json.load(f)
                    saved_mode = data.get("mode", "normal")
                    mode = Mode(saved_mode) if saved_mode in [m.value for m in Mode] else Mode.NORMAL
            except (FileNotFoundError, json.JSONDecodeError):
                mode = Mode.NORMAL

        battery_exists()
        strategy = ModeFactory.create_mode(mode)
        active_modules = strategy.get_active_modules()
        ModeNotifier.notify(mode)


        # ========== BUILD BAR ==========
        self.main_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)

        # Workspaces
        if "workspaces" in active_modules:
            self.main_box.pack_start(WorkspacesWidget(), False, False, 0)

        # Stats
        if "stats" in active_modules:
            left_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            left_box.get_style_context().add_class("bubble")
            left_box.pack_start(MemoryWidget(), False, False, 0)
            self.main_box.pack_start(left_box, False, False, 0)

        # Player
        if "player" in active_modules:
            self.main_box.pack_start(Player(), False, False, 0)

        # Spacer
        self.main_box.pack_start(Gtk.Box(), True, True, 0)

        # Recorder
        if "recorder_indicator" in active_modules:
            self.main_box.pack_start(RecorderIndicator(), False, False, 0)

        # Connections
        if any(m in active_modules for m in ["volume", "bluetooth", "network"]):
            eventbox = Gtk.EventBox()
            connections = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            connections.get_style_context().add_class("bubble")
            if "volume" in active_modules:
                connections.pack_start(VolumeWidget(), False, False, 0)
            if "bluetooth" in active_modules:
                connections.pack_start(BluetoothWidget(), False, False, 0)
            if "network" in active_modules:
                connections.pack_start(NetworkWidget(), False, False, 0)
            eventbox.add(connections)
            eventbox.connect("button-press-event", self.connections_event)
            add_hover_cursor(eventbox)
            self.main_box.pack_start(eventbox, False, False, 0)

        # Date/Clock
        if "date_time" in active_modules:
            date_time = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            date_time.get_style_context().add_class("bubble")
            date_time.pack_start(CalendarWidget(), False, False, 0)
            date_time.pack_start(ClockWidget(), False, False, 0)
            self.main_box.pack_start(date_time, False, False, 0)

        # Notifications
        if "notifications" in active_modules:
            notify = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            notify.get_style_context().add_class("bubble")
            notify.pack_start(NotificationWidget(), False, False, 0)
            self.main_box.pack_start(notify, False, False, 0)

        # Battery
        if "battery" in active_modules:
            self.main_box.pack_start(BatteryWidget(), False, False, 0)

        # Apply styles
        self.add(self.main_box)
        style_provider = Gtk.CssProvider()
        style_provider.load_from_path(CSS_FILE)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        self.show_all()

    def connections_event(self, widget, event):
        subprocess.run(["swaync-client", "-t", "-sw"])

signal.signal(signal.SIGINT, signal.SIG_DFL)

if __name__ == "__main__":
    win = BarDef()
    win.connect("destroy", Gtk.main_quit)
    setproctitle.setproctitle("FixiBar")
    Gtk.main()
