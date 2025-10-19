#!/usr/bin/env python3
import re
import subprocess

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk  # type: ignore


class VolumeWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        self.icon = Gtk.Label(name="icon")
        self.label = Gtk.Label()
        self.pack_start(self.icon, False, False, 0)
        self.pack_start(self.label, False, False, 0)

        # Estado inicial
        self.update_volume()

        # Inicia pactl subscribe y registra la watch
        try:
            self.proc = subprocess.Popen(
                ["pactl", "subscribe"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                bufsize=1,
                universal_newlines=True,
            )
            # Guarda el id de la source para poder quitarla después
            self._watch_id = GLib.io_add_watch(
                self.proc.stdout, GLib.IO_IN | GLib.IO_HUP, self.on_event
            )
        except Exception:
            # Si no puede crear el subscribe, usar fallback a polling lento
            self.proc = None
            self._watch_id = None
            GLib.timeout_add_seconds(1, self._poll_update)

        # Asegurar limpieza cuando el widget se destruye
        self.connect("destroy", lambda *a: self.stop())

    # Callback para eventos de pactl subscribe
    def on_event(self, source, condition):
        try:
            # readline debería ser no bloqueante porque GLib notificó IO_IN
            line = source.readline()
            if line is None:
                return True
            line = line.strip()
        except Exception:
            line = ""

        # Si hubo un hangup (pactl murió), dejamos de escuchar y pedimos fallback
        if condition & GLib.IO_HUP:
            return False  # remove source

        # Filtrar sólo eventos relevantes; pactl emite muchas líneas
        if line and ("sink" in line or "server" in line or "volume" in line or "mute" in line):
            # Actualiza inmediatamente (estamos ya en el hilo de la GUI)
            self.update_volume()

        return True 

    # Fallback polling si pactl subscribe no está disponible
    def _poll_update(self):
        self.update_volume()
        return True

    def get_volume(self):
        """Devuelve el porcentaje de volumen (primer número % encontrado)."""
        try:
            result = subprocess.run(
                ["pactl", "get-sink-volume", "@DEFAULT_SINK@"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=True,
            )
            # Buscar el primer porcentaje en la salida
            m = re.search(r"(\d+)\s*%", result.stdout)
            if m:
                return int(m.group(1))
        except Exception:
            pass
        return 0

    def is_muted(self):
        try:
            result = subprocess.run(
                ["pactl", "get-sink-mute", "@DEFAULT_SINK@"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=True,
            )
            return "yes" in result.stdout.lower()
        except Exception:
            return False

    def update_volume(self):
        """Actualiza icono y texto (corre en hilo de la GUI)."""
        try:
            volume = self.get_volume()
            muted = self.is_muted()
        except Exception:
            volume = 0
            muted = False

        if muted or volume == 0:
            self.icon.set_text("\uf1c3")  # muted
        elif volume < 50:
            self.icon.set_text("\ueb4f")  # low
        else:
            self.icon.set_text("\ueb51")  # high

        self.label.set_text(f"{volume}")

    def stop(self):
        """Limpia resources: quita la watch y termina el proceso pactl subscribe."""
        try:
            if hasattr(self, "_watch_id") and self._watch_id:
                try:
                    GLib.source_remove(self._watch_id)
                except Exception:
                    pass
                self._watch_id = None
            if getattr(self, "proc", None):
                try:
                    self.proc.terminate()
                except Exception:
                    pass
                try:
                    self.proc.wait(timeout=0.5)
                except Exception:
                    pass
                self.proc = None
        except Exception:
            pass
