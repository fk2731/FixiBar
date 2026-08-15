---------------------
---- KEYBINDINGS ----
---------------------

local vars = require("modules/vars")

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod      = vars.mainMod
local fixi         = vars.fixi
local bar          = vars.bar
local terminal     = vars.terminal
local browser      = vars.browser
local browserClass = vars.browserClass
local chat         = vars.chat

-- Example binds
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("killall FixiApp || python " .. fixi .. "/apps/fixiPower.py"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("killall FixiBar || python " .. bar))

-- Web Apps
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/OpenUrl.sh " .. browser .. " " .. browserClass .. " https://chatgpt.com/"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/OpenUrl.sh " .. browser .. " " .. browserClass .. " https://gemini.google.com/app"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/OpenUrl.sh " .. browser .. " " .. browserClass .. " https://claude.ai/"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/OpenUrl.sh " .. browser .. " " .. browserClass .. " https://discord.com/channels/@me"))

-- NOTA: en el .conf original estos dos binds usaban "$mainMode" (con "e" al final),
-- una variable que no existía -> el bind quedaba roto. Se corrigió aquí a mainMod.
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("rofi -show calc -no-show-match -no-sort"))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("$HOME/.dotfiles/config/.config/hypr/scripts/EmojiPicker.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/Music.sh"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(chat))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("killall FixiApp || python " .. fixi .. "/apps/fixiTools.py"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("$HOME/.dotfiles/Fixi/apps/scripts/power_saving.sh"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd([[bash -c "hyprpicker --format hex --autocopy"]]))

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("bluetoothctl connect 2C:FD:B4:A4:43:08")) -- this my speaker

hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + X", hl.dsp.layout("togglesplit")) -- dwindle

-- Control windows
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ monitor = "-1" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "r+1" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "r-1" }), { repeating = true })
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
local focusedMonitorFlag = [[--monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"]]

hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("swayosd-client " .. focusedMonitorFlag .. " --output-volume 5"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("swayosd-client " .. focusedMonitorFlag .. " --output-volume -5"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("swayosd-client " .. focusedMonitorFlag .. " --output-volume mute-toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("swayosd-client " .. focusedMonitorFlag .. " --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("swayosd-client " .. focusedMonitorFlag .. " --brightness lower"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Extra monitor controls (optional) - requires ddcutil and i2c module loaded
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd("~/.dotfiles/config/.config/hypr/scripts/MonitorBrightnessController.sh 1 up"))
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("~/.dotfiles/config/.config/hypr/scripts/MonitorBrightnessController.sh 1 down"))
