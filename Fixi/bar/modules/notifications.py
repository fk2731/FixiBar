#!/usr/bin/env python3
import subprocess
import gi
import threading
import json

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk  # type: ignore

from config import add_hover_cursor


class NotificationWidget(Gtk.EventBox):
    def __init__(self):
        super().__init__()
        self.set_visible_window(False)

        # Íconos
        self.notification = "\uea35"
        self.silent = "\uece9"
        self.pending = "\uf725"

        # Label del ícono
        self.icon = Gtk.Label(self.notification)
        add_hover_cursor(self)
        self.add(self.icon)
        self.connect("button-press-event", self.open_notifications)


        # Lanzar hilo para subscription
        thread = threading.Thread(target=self.subscribe_swaync, daemon=True)
        thread.start()


    def open_notifications(self, widget, event):
        subprocess.run(["swaync-client", "-t", "-sw"])

    def subscribe_swaync(self):
        """Escucha cambios de Swaync en tiempo real usando JSON"""
        proc = subprocess.Popen(
            ["swaync-client", "-s"],  # -s = subscribe
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        for line in proc.stdout:
            line = line.strip()
            if not line:
                continue

            try:
                data = json.loads(line)
            except json.JSONDecodeError:
                continue  # ignorar líneas inválidas

            # Determinar ícono según estado
            if data.get("dnd", False):
                icon = self.silent
            elif data.get("count", 0) > 0:
                icon = self.pending
            else:
                icon = self.notification

            # Actualizar GTK desde el hilo principal
            GLib.idle_add(self.icon.set_text, icon)
