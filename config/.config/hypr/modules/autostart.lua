-------------------
---- AUTOSTART ----
-------------------

local vars = require("modules/vars")

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("env SWAYNC_DAEMON=1 swaync")
    hl.exec_cmd("killall FixiBar;python " .. vars.bar .. " & hyprpaper & hypridle & wl-paste --watch cliphist store & swayosd-server")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme BreezeX-RosePine-Linux")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
end)
