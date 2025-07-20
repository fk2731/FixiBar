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

        self.update_battery()
        GLib.timeout_add_seconds(5, self.update_battery)  # every 5 seconds

    def update_battery(self):
        battery = psutil.sensors_battery()
        if battery:
            percent = battery.percent
            self.label.set_text(f" {percent:.0f}%")
            self.bar.set_value(percent)
            self.check_battery_status()
        else:
            self.hide()
            return False
        return True

    def check_battery_status(self):
        ctx = self.bar.get_style_context()

        # Elimina clases previas
        ctx.remove_class("low")
        ctx.remove_class("charging")
        ctx.remove_class("full")

        battery = psutil.sensors_battery()
        percent = battery.percent

        if battery.power_plugged:
            ctx.add_class("charging")
            if percent >= 80:
                ctx.remove_class("charging")
                ctx.add_class("full")
            # Reset timer
            self.last_notified_time = 0
        elif percent < 20:
            ctx.add_class("low")
            now = time.time()
            if now - self.last_notified_time >= self.notify_interval:
                self.last_notified_time = now
                GLib.idle_add(
                    self.set_notification_sender,
                    ALERT_ICON,
                    "Battery Low",
                    "Please connect your charger.",
                )

    def set_notification_sender(self, icon, mesagge, body):
        subprocess.run(
            [
                "notify-send",
                "-a",
                "FixiBar",
                "-u",
                "low",
                mesagge,
                body,
                "-i",
                icon,
            ]
        )
