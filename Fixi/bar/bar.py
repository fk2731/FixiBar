#!/usr/bin/env python3
import os
import signal

import gi
import setproctitle
import subprocess

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")

from gi.repository import Gdk, Gtk, GtkLayerShell  # type: ignore
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

DIR = os.path.dirname(os.path.abspath(__file__))

from config import BAR_HEIGHT, CSS_FILE, TOP_MARGIN, add_hover_cursor


class BarDef(Gtk.Window):
    def __init__(self):
        super().__init__()
        self.set_resizable(False)
        self.set_decorated(False)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "FixiBar")

        display = Gdk.Display.get_default()
        monitor = None

        if display.get_n_monitors() > 1:
            monitor = display.get_monitor(1)
        else:
            monitor = display.get_monitor(0)

        GtkLayerShell.set_monitor(self, monitor)

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

        #Memory Box - left side
        self.left_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.left_box.get_style_context().add_class("bubble")
        self.left_box.pack_start(MemoryWidget(), False, False, 0)

        #Connections Box - right side
        self.eventbox = Gtk.EventBox()
        self.connections = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.connections.get_style_context().add_class("bubble")
        self.connections.pack_start(VolumeWidget(), False, False, 0)
        self.connections.pack_start(BluetoothWidget(), False, False, 0)
        self.connections.pack_start(NetworkWidget(), False, False, 0)
        self.eventbox.add(self.connections)
        self.eventbox.connect("button-press-event", self.connections_event)
        add_hover_cursor(self.eventbox)

        #date_time Box - right side
        self.date_time = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.date_time.get_style_context().add_class("bubble")
        self.date_time.pack_start(CalendarWidget(), False, False, 0)
        self.date_time.pack_start(ClockWidget(), False, False, 0)

        #notifications Box - right side
        self.notify = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.notify.get_style_context().add_class("bubble")
        self.notify.pack_start(NotificationWidget(), False, False, 0)

        #Bar
        self.main_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        self.main_box.pack_start(WorkspacesWidget(), False, False, 0)
        self.main_box.pack_start(self.left_box, False, False, 0)
        self.main_box.pack_start(Player(), False, False, 0)
        self.main_box.pack_start(Gtk.Box(), True, True, 0)
        self.main_box.pack_start(RecorderIndicator(), False, False, 0)
        self.main_box.pack_start(self.eventbox, False, False, 0)
        self.main_box.pack_start(self.date_time, False, False, 0)
        self.main_box.pack_start(self.notify, False, False, 0)
        self.main_box.pack_start(
            BatteryWidget(), False, False, 0
        )  # Add BatteryWidget to the right side looks better

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
