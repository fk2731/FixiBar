#! /usr/bin/env python3
import subprocess
import time

import gi
import psutil

gi.require_version("Gtk", "3.0")
from fabric.utils import get_relative_path
from gi.repository import GLib, Gtk  # type: ignore

ALERT_ICON = get_relative_path("../icons/alert.svg")


class BatteryWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)

        self.label = Gtk.Label()

        self.bar = Gtk.LevelBar()
        self.bar.set_min_value(0)
        self.bar.set_max_value(100)
        self.bar.set_value(0)
        self.bar.set_size_request(80, 5)

        self.last_notified_time = 0  # Timestamp
        self.notify_interval = 5 * 60  # 5 minutes in seconds

        overlay = Gtk.Overlay()
        overlay.add(self.bar)
        overlay.add_overlay(self.label)

        self.pack_start(overlay, True, True, 0)

        # inicializar estado
        self.update_battery()

        # intentar iniciar upower --monitor-detail (más información)
        try:
            self._upower_proc = subprocess.Popen(
                ["upower", "--monitor-detail"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                bufsize=1,
                universal_newlines=True,
            )
            # registrar watch para leer líneas cuando haya IO
            self._watch_id = GLib.io_add_watch(
                self._upower_proc.stdout, GLib.IO_IN | GLib.IO_HUP, self._on_upower_event
            )
        except FileNotFoundError:
            # upower no disponible -> fallback a polling
            self._upower_proc = None
            self._watch_id = None
            self._timeout_id = GLib.timeout_add_seconds(5, self.update_battery)

        self.connect("destroy", self._on_destroy)

    def _on_destroy(self, *args):
        # cleanup watch/process
        if getattr(self, "_watch_id", None):
            try:
                GLib.source_remove(self._watch_id)
            except Exception:
                pass
            self._watch_id = None
        if getattr(self, "_upower_proc", None):
            try:
                self._upower_proc.terminate()
            except Exception:
                pass
            self._upower_proc = None
        if getattr(self, "_timeout_id", None):
            try:
                GLib.source_remove(self._timeout_id)
            except Exception:
                pass
            self._timeout_id = None

    def _on_upower_event(self, source, condition):
        # Se corre en el main loop; readline debería devolver la línea ya disponible
        try:
            line = source.readline()
        except Exception:
            line = ""

        if condition & GLib.IO_HUP:
            # upower cerró; eliminar la watch y caer a polling
            return False

        if not line:
            return True

        # Filtra líneas relevantes (si quieres puedes ajustar)
        l = line.strip().lower()
        if "battery" in l or "device" in l or "changed" in l or "changed:" in l:
            # actualizar estado inmediatamente (estamos en el hilo de la GUI)
            self.update_battery()
        return True

    def update_battery(self):
        try:
            battery = psutil.sensors_battery()
        except Exception:
            battery = None

        if battery:
            percent = battery.percent
            self.label.set_text(f" {percent:.0f}%")
            self.bar.set_value(percent)
            self.check_battery_status(battery)
        else:
            self.hide()
            return False
        return True

    def check_battery_status(self, battery=None):
        try:
            if battery is None:
                battery = psutil.sensors_battery()
                if battery is None:
                    return
        except Exception:
            return

        ctx = self.bar.get_style_context()
        ctx.remove_class("low")
        ctx.remove_class("charging")
        ctx.remove_class("full")

        percent = battery.percent

        if battery.power_plugged:
            ctx.add_class("charging")
            if percent >= 80:
                ctx.remove_class("charging")
                ctx.add_class("full")
            self.last_notified_time = 0
        elif percent < 20:
            ctx.add_class("low")
            now = time.time()
            if now - self.last_notified_time >= self.notify_interval:
                self.last_notified_time = now
                try:
                    subprocess.Popen(
                        [
                            "notify-send",
                            "-a",
                            "FixiBar",
                            "-u",
                            "low",
                            "Battery Low",
                            "Please connect your charger.",
                            "-i",
                            ALERT_ICON,
                        ],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                except Exception:
                    pass

    def set_notification_sender(self, icon, message, body):
        try:
            subprocess.Popen(
                [
                    "notify-send",
                    "-a",
                    "FixiBar",
                    "-u",
                    "low",
                    message,
                    body,
                    "-i",
                    icon,
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception:
            pass
