#!/usr/bin/env python3
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib, Gtk


class NetworkWidget(Gtk.Box):
    """
    NetworkWidget displays the current network status reactively using D-Bus.

    Features:
    - Shows Wi-Fi SSID or Ethernet connection.
    - Updates signal strength icons for Wi-Fi.
    - Indicates disconnected or error states.
    - Uses NetworkManager's Connectivity property to detect internet availability.
    """

    NM_BUS_NAME = "org.freedesktop.NetworkManager"
    NM_OBJECT_PATH = "/org/freedesktop/NetworkManager"
    NM_INTERFACE = "org.freedesktop.NetworkManager"

    # NetworkManager Connectivity states
    CONNECTIVITY_UNKNOWN = 0
    CONNECTIVITY_NONE = 1
    CONNECTIVITY_PORTAL = 2
    CONNECTIVITY_LIMITED = 3
    CONNECTIVITY_FULL = 4

    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)

        self.icon = Gtk.Label(name="icon")
        self.label = Gtk.Label()
        self.pack_start(self.icon, False, False, 0)
        self.pack_start(self.label, True, True, 0)

        # Connect to the system bus
        self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
        self.nm_proxy = Gio.DBusProxy.new_sync(
            self.bus,
            Gio.DBusProxyFlags.NONE,
            None,
            self.NM_BUS_NAME,
            self.NM_OBJECT_PATH,
            self.NM_INTERFACE,
            None,
        )

        # Listen for NetworkManager property changes
        self.nm_proxy.connect("g-properties-changed", self.on_nm_properties_changed)

        # Initial update
        self.update_network()

    def on_nm_properties_changed(self, proxy, changed, invalidated):
        """
        Callback triggered when NetworkManager properties change.
        """
        if "PrimaryConnection" in changed.keys() or "State" in changed.keys() or "Connectivity" in changed.keys():
            GLib.idle_add(self.update_network)

    def update_network(self):
        """
        Update the widget to reflect the current network status.
        Uses the Connectivity property to check if internet is available.
        """
        try:
            state = self.nm_proxy.get_cached_property("State").unpack()
            connectivity = self.nm_proxy.get_cached_property("Connectivity").unpack()

            # If disconnected
            if state != 70 or connectivity in (self.CONNECTIVITY_NONE, self.CONNECTIVITY_PORTAL):
                self.icon.set_text("\uecfa")  # disconnected icon
                self.label.set_text("")
                return

            # Active connection
            active_path = self.nm_proxy.get_cached_property("PrimaryConnection").unpack()
            if active_path == "/":
                self.icon.set_text("\uecfa")
                self.label.set_text("")
                return

            conn_proxy = Gio.DBusProxy.new_sync(
                self.bus,
                Gio.DBusProxyFlags.NONE,
                None,
                self.NM_BUS_NAME,
                active_path,
                "org.freedesktop.NetworkManager.Connection.Active",
                None,
            )

            conn_type = conn_proxy.get_cached_property("Type").unpack()

            # Ethernet
            if conn_type == "802-3-ethernet":
                if connectivity == self.CONNECTIVITY_FULL:
                    self.icon.set_text("\uf860")  # ethernet icon
                else:
                    self.icon.set_text("\uf870")  # ethernet warning/no internet
                self.label.set_text("Fixi")

            # Wi-Fi
            elif conn_type == "802-11-wireless":
                specific_proxy = Gio.DBusProxy.new_sync(
                    self.bus,
                    Gio.DBusProxyFlags.NONE,
                    None,
                    self.NM_BUS_NAME,
                    conn_proxy.get_cached_property("SpecificObject").unpack(),
                    "org.freedesktop.NetworkManager.AccessPoint",
                    None,
                )
                ssid_bytes = specific_proxy.get_cached_property("Ssid").unpack()
                ssid = "".join(chr(b) for b in ssid_bytes)
                strength = specific_proxy.get_cached_property("Strength").unpack()

                # Set Wi-Fi icon based on strength
                if strength >= 75:
                    self.icon.set_text("\ueb52")  # strong
                elif strength >= 50:
                    self.icon.set_text("\ueba5")  # medium
                elif strength >= 25:
                    self.icon.set_text("\ueba4")  # weak
                else:
                    self.icon.set_text("\ueba3")  # very weak

                # Show warning if no internet
                if connectivity != self.CONNECTIVITY_FULL:
                    self.icon.set_text("\ueb53")  # warning / no internet

                self.label.set_text(ssid)

        except Exception as e:
            self.icon.set_text("\uf9e0")  # error icon
            self.label.set_text("Error")
            print("NetworkWidget error:", e)
