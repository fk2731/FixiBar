#!/usr/bin/env python3
import subprocess
import time

import gi
import psutil

gi.require_version("Gtk", "3.0")
from fabric.utils import get_relative_path
from gi.repository import GLib, Gtk  # type: ignore

ALERT_ICON = get_relative_path("../icons/alert.svg")
PLUGIN_ICON = get_relative_path("../icons/plug.svg")
CARE_ICON = get_relative_path("../icons/care.svg")
PLUG_OFF_ICON = get_relative_path("../icons/plug-off.svg")


class BatteryWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)

        self.set_name("battery-widget")

        self.label = Gtk.Label()
        self.bar = Gtk.LevelBar()
        self.bar.set_min_value(0)
        self.bar.set_max_value(100)
        self.bar.set_value(0)
        self.bar.set_size_request(80, 5)

        overlay = Gtk.Overlay()
        overlay.add(self.bar)
        overlay.add_overlay(self.label)
        self.pack_start(overlay, True, True, 0)

        # Notification state
        self.notify_interval = 5 * 60  # 5 minutes
        self.last_notified_time = 0  # timestamp of last periodic notification
        self.last_notified_condition = None  # 'plugged_high' | 'unplugged_low' | None
        self.last_plugged_state = None  # last known power_plugged (bool)

        # Initialize UI/state (don't trigger a transition notification on startup)
        self.update_battery()

        # Try to use upower --monitor-detail for realtime events
        try:
            self._upower_proc = subprocess.Popen(
                ["upower", "--monitor-detail"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                bufsize=1,
                universal_newlines=True,
            )
            self._watch_id = GLib.io_add_watch(
                self._upower_proc.stdout, GLib.IO_IN | GLib.IO_HUP, self._on_upower_event
            )
            # Keep a light polling fallback even when upower is present
            self._timeout_id = GLib.timeout_add_seconds(30, self.update_battery)
        except FileNotFoundError:
            # upower not available -> polling fallback
            self._upower_proc = None
            self._watch_id = None
            self._timeout_id = GLib.timeout_add_seconds(5, self.update_battery)

        self.connect("destroy", self._on_destroy)

    def _on_destroy(self, *args):
        # Cleanup GLib sources / process
        if getattr(self, "_watch_id", None):
            try:
                GLib.source_remove(self._watch_id)
            except Exception:
                pass
            self._watch_id = None
        if getattr(self, "_timeout_id", None):
            try:
                GLib.source_remove(self._timeout_id)
            except Exception:
                pass
            self._timeout_id = None
        if getattr(self, "_upower_proc", None):
            try:
                self._upower_proc.terminate()
            except Exception:
                pass
            self._upower_proc = None

    def _on_upower_event(self, source, condition):
        # Runs in the main loop; readline() should return the available line
        try:
            line = source.readline()
        except Exception:
            line = ""

        if condition & GLib.IO_HUP:
            # upower closed; stop watching (polling remains if configured)
            return False

        if not line:
            return True

        l = line.strip().lower()
        # Filter to reduce calls to update (adjust rules as desired)
        if "battery" in l or "device" in l or "changed" in l or "state changed" in l:
            self.update_battery()
        return True

    def update_battery(self):
        """Read current battery state, update UI and notifications."""
        try:
            battery = psutil.sensors_battery()
        except Exception:
            battery = None

        if not battery:
            # If no battery present, hide widget
            try:
                self.hide()
            except Exception:
                pass
            return True

        percent = battery.percent
        self.label.set_text(f" {percent:.0f}")
        self.bar.set_value(percent)
        self.check_battery_status(battery)
        return True

    def check_battery_status(self, battery=None):
        """Manage CSS classes and send notifications according to state and transitions."""
        try:
            if battery is None:
                battery = psutil.sensors_battery()
                if battery is None:
                    return
        except Exception:
            return

        ctx = self.bar.get_style_context()
        # Clear classes
        for cls in ("low", "charging", "full"):
            ctx.remove_class(cls)

        percent = battery.percent
        plugged = bool(battery.power_plugged)

        # ---- Detect plug/unplug transitions ----
        if self.last_plugged_state is None:
            # Initial state: don't send transition notification
            self.last_plugged_state = plugged
        elif plugged != self.last_plugged_state:
            # State changed: send one immediate notification
            self.last_plugged_state = plugged
            if plugged:
                self._send_immediate_notification(
                    icon=PLUGIN_ICON,
                    title="Charger connected",
                    body=f"Battery: {percent:.2f}% — charging started."
                )
            else:
                self._send_immediate_notification(
                    icon=PLUG_OFF_ICON,
                    title="Charger disconnected",
                    body=f"Battery: {percent:.2f}% — charger unplugged."
                )
            # Reset periodic notification state so the periodic flow can notify immediately
            self.last_notified_time = 0
            self.last_notified_condition = None

        # ---- Visual classes ----
        if plugged:
            ctx.add_class("charging")
            if percent >= 80:
                ctx.remove_class("charging")
                ctx.add_class("full")
        elif percent < 20:
            ctx.add_class("low")

        # ---- Periodic notifications (every self.notify_interval) ----
        # Conditions to notify periodically:
        # - plugged and percent >= 80 -> 'plugged_high'
        # - unplugged and percent < 20 -> 'unplugged_low'
        condition = None
        if plugged and percent >= 80:
            condition = "plugged_high"
        elif (not plugged) and percent < 20:
            condition = "unplugged_low"

        now = time.time()
        if condition is None:
            # Not in a periodic-notify condition -> clear state
            self.last_notified_condition = None
        else:
            # If just entered the condition, or enough time passed, notify
            if (self.last_notified_condition != condition) or (now - self.last_notified_time >= self.notify_interval):
                if condition == "plugged_high":
                    title = "Battery high while charging"
                    body = f"Battery {percent:.2f}% — consider unplugging to preserve battery health."
                    icon = CARE_ICON
                else:  # 'unplugged_low'
                    title = "Battery low"
                    body = f"Battery {percent:.2f}% — please plug in the charger."
                    icon = ALERT_ICON

                try:
                    self.notification_sender(icon=icon, message=title, body=body)
                except Exception:
                    pass
                self.last_notified_time = now
                self.last_notified_condition = condition

    def _send_immediate_notification(self, icon, title, body):
        try:
            self.notification_sender(icon=icon, message=title, body=body)
        except Exception:
            pass

    def notification_sender(self, icon="", message="", body=""):
        # Use notify-send and a private synchronous tag to replace notifications of the same group if supported
        subprocess.Popen(
            [
                "notify-send",
                "-e",
                "-h",
                "string:x-canonical-private-synchronous:battery-widget",
                message,
                body,
                "-i",
                icon,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
