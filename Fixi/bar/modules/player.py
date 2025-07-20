#!/usr/bin/env python3
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from fabric.widgets.button import Button
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.label import Label
from fabric.widgets.stack import Stack
from gi.repository import Gdk, GLib, Gtk  # type: ignore
from modules.cavalcade import SpectrumRender
from services.mpris import MprisPlayer, MprisPlayerManager
from config import add_hover_cursor

play = "\uf691"  # Play icon
pause = "\uf690"  # Pause icon
default_icon = "\uf00d"  # Default icon for no player


def get_player_icon_markup_by_name(player_name):
    if player_name:
        pn = player_name.lower()
        if pn == "spotify":
            return (
                "<span font-family='tabler-icons' foreground='#1DB954'>&#xfe86;</span>"
            )
        elif pn in ("chromium", "brave", "firefox", "opera", "zen"):
            return (
                "<span font-family='tabler-icons' foreground='#FF0000'>&#xfc22;</span>"
            )
    return "<span font-family='tabler-icons' foreground='#FFF'>&#xf00d;</span>"



class Player(CenterBox):
    def __init__(self):
        super().__init__(
            name="player", orientation="h", h_align="fill", v_align="center"
        )
        self._show_artist = False  # toggle flag
        self._display_options = ["cavalcade", "title", "artist"]
        self._display_index = 0
        self._current_display = "cavalcade"
        self._position_timer_id = None
        self.get_style_context().add_class("bubble")

        self.mpris_icon = Button(
            name="mpris-icon",
            h_align="center",
            v_align="center",
            child=Label(name="icon", label=default_icon, xalign=0.5),
        )
        # Remove scroll events; instead, add button press events.
        self.mpris_icon.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        self.mpris_icon.connect("button-press-event", self._on_icon_button_press)
        # Prevent the child from propagating events.
        child = self.mpris_icon.get_child()
        child.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        child.connect("button-press-event", lambda widget, event: True)
        # Add hover effect
        add_hover_cursor(self.mpris_icon)

        self.mpris_label = Label(
            name="compact-mpris-label",
            label="Nothing Playing",
            ellipsization="end",
            max_chars_width=26,
            h_align="center",
        )
        self.mpris_button = Button(
            h_align="center",
            v_align="center",
            child=Gtk.Label(name="icon", label=play),  # Play icon
        )
        self.mpris_button.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        self.mpris_button.connect(
            "button-press-event", self._on_play_pause_button_press
        )
        # Add hover effect
        add_hover_cursor(self.mpris_button)

        self.cavalcade = SpectrumRender()
        self.cavalcade_box = self.cavalcade.get_spectrum_box()

        self.center_stack = Stack(
            name="compact-mpris",
            transition_type="crossfade",
            transition_duration=100,
            v_align="center",
            v_expand=False,
            children=[
                self.cavalcade_box,
                self.mpris_label,
            ],
        )
        self.center_stack.set_visible_child(self.cavalcade_box)  # default to cavalcade

        # Create additional compact view.
        self.mpris_small = CenterBox(
            name="compact-mpris",
            orientation="h",
            h_expand=True,
            h_align="fill",
            v_align="center",
            v_expand=False,
            start_children=self.mpris_icon,
            center_children=self.center_stack,  # Changed to center_stack to handle stack switching
            end_children=self.mpris_button,
        )

        self.add(self.mpris_small)

        self.mpris_manager = MprisPlayerManager()
        self.mpris_player = None
        # Almacenar el índice del reproductor actual
        self.current_index = 0

        players = self.mpris_manager.players
        if players:
            mp = MprisPlayer(players[self.current_index])
            self.mpris_player = mp
            self._apply_mpris_properties()
            self.mpris_player.connect("changed", self._on_mpris_changed)
        else:
            self._apply_mpris_properties()

        self.mpris_manager.connect("player-appeared", self.on_player_appeared)
        self.mpris_manager.connect("player-vanished", self.on_player_vanished)
        self.mpris_button.connect("clicked", self._on_play_pause_clicked)

    def _apply_mpris_properties(self):
        if not self.mpris_player:
            self.mpris_label.set_text("Nothing Playing")
            self.mpris_button.get_child().set_text(pause)
            self.mpris_icon.get_child().set_text(default_icon)
            if self._current_display != "cavalcade":
                self.center_stack.set_visible_child(
                    self.mpris_label
                )  # if was title or artist, keep showing label
            else:
                self.center_stack.set_visible_child(
                    self.cavalcade_box
                )  # default to cavalcade if no player
            return

        mp = self.mpris_player

        # Choose icon based on player name.
        player_name = (
            mp.player_name.lower()
            if hasattr(mp, "player_name") and mp.player_name
            else ""
        )
        icon_markup = get_player_icon_markup_by_name(player_name)
        self.mpris_icon.get_child().set_markup(icon_markup)
        self.update_play_pause_icon()

        if self._current_display == "title":
            if mp.title and mp.position is not None and mp.length is not None:
                pos_sec = int(mp.position / 1_000_000)
                len_sec = int(int(mp.length) / 1_000_000)

                pos_str = f"{pos_sec // 60:02}:{pos_sec % 60:02}"
                len_str = f"{len_sec // 60:02}:{len_sec % 60:02}"

                text = f"{mp.title}  ({pos_str} / {len_str})"

                if not self._position_timer_id:
                    self._position_timer_id = GLib.timeout_add_seconds(
                        1, self._update_position_loop
                    )
            else:
                text = "Nothing Playing"
            self.mpris_label.set_text(text)
            self.center_stack.set_visible_child(self.mpris_label)
        elif self._current_display == "artist":
            text = mp.artist if mp.artist else "Nothing Playing"
            self.mpris_label.set_text(text)
            self.center_stack.set_visible_child(self.mpris_label)
            if self._position_timer_id is not None:
                GLib.source_remove(self._position_timer_id)
                self._position_timer_id = None
        else:  # default cavalcade
            self.center_stack.set_visible_child(self.cavalcade_box)
            if self._position_timer_id is not None:
                GLib.source_remove(self._position_timer_id)
                self._position_timer_id = None

    def _update_position_loop(self):
        if not self.mpris_player or self._current_display != "title":
            return True

        mp = self.mpris_player
        if mp.title and mp.position is not None and mp.length is not None:
            pos_sec = int(mp.position / 1_000_000)
            len_sec = int(mp.length / 1_000_000)

            pos_str = f"{pos_sec // 60:02}:{pos_sec % 60:02}"
            len_str = f"{len_sec // 60:02}:{len_sec % 60:02}"

            text = f"{mp.title}  ({pos_str} / {len_str})"
            self.mpris_label.set_text(text)

        return True

    def _on_icon_button_press(self, widget, event):
        if event.type == Gdk.EventType.BUTTON_PRESS:
            players = self.mpris_manager.players
            if not players:
                return True

            if event.button == 3:  # Middle-click: cycle display
                self._display_index = (self._display_index + 1) % len(
                    self._display_options
                )
                self._current_display = self._display_options[self._display_index]
                self._apply_mpris_properties()  # Re-apply to update label/cavalcade
                return True

            # Cambiar de reproductor según el botón presionado.
            if event.button == 1:  # Left-click: next player
                self.current_index = (self.current_index + 1) % len(players)

            mp_new = MprisPlayer(players[self.current_index])
            self.mpris_player = mp_new
            # Conectar el evento "changed" para que se actualice
            self.mpris_player.connect("changed", self._on_mpris_changed)
            self._apply_mpris_properties()
            return True  # Se consume el evento
        return True

    def _on_play_pause_button_press(self, widget, event):
        if event.type == Gdk.EventType.BUTTON_PRESS:
            if event.button == 2:  # Click izquierdo -> track anterior
                if self.mpris_player:
                    self.mpris_player.previous()
                    self.mpris_button.get_child().set_text(pause)
                    GLib.timeout_add(500, self._restore_play_pause_icon)
            elif event.button == 3:  # Click derecho -> siguiente track
                if self.mpris_player:
                    self.mpris_player.next()
                    self.mpris_button.get_child().set_text(play)
                    GLib.timeout_add(500, self._restore_play_pause_icon)
            elif event.button == 1:  # Click medio -> play/pausa
                if self.mpris_player:
                    self.mpris_player.play_pause()
                    self.update_play_pause_icon()
            return True
        return True

    def _restore_play_pause_icon(self):
        self.update_play_pause_icon()
        return False

    def _on_icon_clicked(
        self, widget
    ):  # No longer used, logic moved to _on_icon_button_press
        pass

    def update_play_pause_icon(self):
        if self.mpris_player and self.mpris_player.playback_status == "playing":
            self.mpris_button.get_child().set_text(pause)  # Pause icon
        else:
            self.mpris_button.get_child().set_text(play)

    def _on_play_pause_clicked(self, button):
        if self.mpris_player:
            self.mpris_player.play_pause()
            self.update_play_pause_icon()

    def _on_mpris_changed(self, *args):
        # Update properties when the player's state changes.
        self._apply_mpris_properties()

    def on_player_appeared(self, manager, player):
        # When a new player appears, use it if no player is active.
        if not self.mpris_player:
            mp = MprisPlayer(player)
            self.mpris_player = mp
            self._apply_mpris_properties()
            self.mpris_player.connect("changed", self._on_mpris_changed)

    def on_player_vanished(self, manager, player_name):
        players = self.mpris_manager.players
        if (
            players
            and self.mpris_player
            and self.mpris_player.player_name == player_name
        ):
            if players:  # Check if players is not empty after vanishing
                self.current_index = self.current_index % len(players)
                new_player = MprisPlayer(players[self.current_index])
                self.mpris_player = new_player
                self.mpris_player.connect("changed", self._on_mpris_changed)
            else:
                self.mpris_player = None  # No players left
        elif not players:
            self.mpris_player = None
        self._apply_mpris_properties()
