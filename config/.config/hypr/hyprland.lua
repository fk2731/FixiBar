-- Migrado desde hyprland.conf (formato hyprlang) el 2026-08-15.
-- El soporte para .conf se elimina en Hyprland 0.57:
-- https://github.com/hyprwm/Hyprland/pull/15538
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/
--
-- Config dividida en modules/. require() siempre resuelve rutas relativas
-- a este archivo, sin importar desde qué módulo se llame.

require("modules/monitors")
require("modules/autostart")
require("modules/environment")
require("modules/appearance")
require("modules/input")
require("modules/keybinds")
require("modules/rules")
