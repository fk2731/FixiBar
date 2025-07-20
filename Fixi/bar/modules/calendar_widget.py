#!/usr/bin/env python3
from datetime import datetime

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk  # type: ignore
from widgets.popup import FloatingPopup

from config import add_hover_cursor


class CalendarWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)

        self.popup = None  # Ventana del calendario

        self.eventbox = Gtk.EventBox()
        self.label = Gtk.Label(label=datetime.now().strftime("%a %d %b"))
        self.label.set_xalign(0.5)
        self.eventbox.add(self.label)
        self.pack_start(self.eventbox, False, False, 5)

        add_hover_cursor(self.eventbox)
        self.eventbox.connect("button-press-event", self.toggle_popup)

        GLib.timeout_add_seconds(1600, self.update_date)

    def toggle_popup(self, widget, event):
        if self.popup and self.popup.get_visible():
            self.popup.hide()
        else:
            if not self.popup:
                calendar = Gtk.Calendar()
                self.popup = FloatingPopup(
                    child_widget=calendar,
                    anchor_top=True,
                    anchor_right=True,
                )
            self.popup.show_all()

    def update_date(self):
        self.label.set_text(datetime.now().strftime("%a %d %b"))
        return True
