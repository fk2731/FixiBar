#!/usr/bin/env python3
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")

from gi.repository import Gtk, GtkLayerShell  # type: ignore


class FloatingPopup(Gtk.Window):
    def __init__(
        self,
        child_widget: Gtk.Widget,
        anchor_top=True,
        anchor_right=False,
        anchor_bottom=False,
        anchor_left=False,
    ):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_decorated(False)
        self.set_resizable(False)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)

        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, anchor_top)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, anchor_right)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, anchor_bottom)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, anchor_left)

        self.add(child_widget)
        self.show_all()
