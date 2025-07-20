#!/usr/bin/env python3
import psutil
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib  # type: ignore


class MemoryWidget(Gtk.Box):
    def __init__(self):
        super().__init__(Gtk.Orientation.HORIZONTAL, spacing=10)
        self.ram_container = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        self.ram = Gtk.Label()
        self.ram_icon = Gtk.Label(label="\ufa77", name="icon")
        self.ram_container.pack_start(self.ram_icon, False, False, 0)
        self.ram_container.pack_start(self.ram, False, False, 0)

        self.rom_container = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        self.rom = Gtk.Label()
        self.rom_icon = Gtk.Label(label="\ueb1f", name="icon")
        self.rom_container.pack_start(self.rom_icon, False, False, 0)
        self.rom_container.pack_start(self.rom, False, False, 0)

        self.pack_start(self.ram_container, False, False, 0)
        self.pack_start(self.rom_container, False, False, 0)

        self.update_memory_usage()
        GLib.timeout_add(1000, self.update_memory_usage)

    def update_memory_usage(self):
        memory = psutil.virtual_memory()
        used = (memory.total - memory.available) / (1024**3)  # Convert to GB

        rom = psutil.disk_usage("/").used / (1024**3)  # Convert to GB
        self.ram.set_text(f"{used:.2f} GB")
        self.rom.set_text(f"{rom:.2f} GB")
        return True  # Keep the timeout active
