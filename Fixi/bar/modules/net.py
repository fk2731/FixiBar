#!/usr/bin/env python3
import re
import subprocess
import threading

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk  # type: ignore


class NetworkWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)

        # Contenedor interno
        self.box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=3)
        self.icon = Gtk.Label(name="icon")
        self.label = Gtk.Label()

        self.pack_start(self.icon, False, False, 0)
        self.pack_start(self.label, True, True, 0)

        # Inicializa con estado actual
        self.update_network()

        # Hilo que escucha los cambios en red
        thread = threading.Thread(target=self.monitor_network, daemon=True)
        thread.start()

    # -------------------------------
    #  Monitoreo reactivo
    # -------------------------------

    def monitor_network(self):
        """Escucha eventos de red en tiempo real usando nmcli monitor."""
        proc = subprocess.Popen(
            ["nmcli", "monitor"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        for line in proc.stdout:
            line = line.strip()
            if not line:
                continue

            # Cualquier cambio relevante → actualizar estado
            if re.search(r"(connected|disconnected|new|removed)", line, re.IGNORECASE):
                GLib.idle_add(self.update_network)

        proc.wait()

    # -------------------------------
    #  Actualización del estado
    # -------------------------------

    def update_network(self):
        """Actualiza el estado actual de red (Ethernet, Wi-Fi o desconectado)."""
        try:
            output = subprocess.check_output(
                ["nmcli", "-t", "-f", "TYPE,STATE", "device"], text=True
            )

            for line in output.strip().splitlines():
                dev_type, state = line.split(":")
                if state == "connected":
                    if dev_type == "ethernet":
                        self.icon.set_text("\uf866")
                        self.label.set_text("Fixi")
                        return True
                    elif dev_type == "wifi":
                        self.update_wifi_info()
                        return True

            # Si llegamos aquí → nada conectado
            self.icon.set_text("\uf9eb")  # disconnected
            self.label.set_text("")
            return False

        except Exception:
            self.icon.set_text("\uf9e0")  # error
            self.label.set_text("")
            return False

    def update_wifi_info(self):
        """Lee el SSID y señal de la red Wi-Fi actual."""
        try:
            wifi_output = subprocess.check_output(
                ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL", "dev", "wifi"], text=True
            )
            for wifi_line in wifi_output.strip().splitlines():
                in_use, ssid, signal = wifi_line.split(":")
                if in_use == "*":
                    signal = int(signal)
                    icon = self.get_wifi_icon(signal)
                    self.icon.set_text(icon)
                    self.label.set_text(ssid)
                    return
        except Exception:
            self.icon.set_text("\uf9eb")
            self.label.set_text("")

    def get_wifi_icon(self, signal):
        """Devuelve el ícono según la intensidad de señal Wi-Fi."""
        if signal >= 75:
            return "\ueccb"
        elif signal >= 50:
            return "\uecca"
        elif signal >= 25:
            return "\uecc9"
        else:
            return "\uecc8"
