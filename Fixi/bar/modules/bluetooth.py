#!/usr/bin/env python3
import gi
from pydbus import SystemBus

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk, Pango  # type: ignore


class BluetoothWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)

        self.icon = Gtk.Label(label="\ueceb", name="icon")  # disconnected icon
        self.label = Gtk.Label()
        self.label.set_ellipsize(Pango.EllipsizeMode.END)
        self.label.set_max_width_chars(10)

        self.pack_start(self.icon, False, False, 0)
        self.pack_start(self.label, False, False, 0)

        self.bus = SystemBus()
        self.manager = self.bus.get("org.bluez", "/")

        self.bus.subscribe(
            iface="org.freedesktop.DBus.Properties",
            signal="PropertiesChanged",
            object=None,
            arg0="org.bluez.Device1",
            signal_fired=self.on_device_signal,
        )

        self.update_connected_device()

    def on_device_signal(self, sender, object, iface, signal, params):
        iface_name, changed, invalidated = params
        if "Connected" in changed:
            connected = changed["Connected"]
            if connected:
                self.update_connected_device()
            else:
                GLib.idle_add(self.set_disconnected)

    def update_connected_device(self):
        """Busca el primer dispositivo conectado y muestra su nombre."""
        try:
            objects = self.manager.GetManagedObjects()
            for path, interfaces in objects.items():
                device = interfaces.get("org.bluez.Device1")
                if device and device.get("Connected"):
                    name = device.get("Alias") or device.get("Name", "Unknown")
                    GLib.idle_add(self.icon.set_text, "\uea37")  # connected icon
                    GLib.idle_add(self.label.set_text, name)
                    return
            # Si ninguno está conectado
            self.set_disconnected()
        except Exception as e:
            print("DBus error:", e)
            self.set_disconnected()

    def set_disconnected(self):
        self.icon.set_text("\ueceb")
        self.label.set_text("")
