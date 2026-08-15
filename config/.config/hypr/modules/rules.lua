--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.layer_rule({ name = "no-anim-selection", match = { namespace = "^(selection)$" }, no_anim = true })

hl.window_rule({ name = "kitty-opacity", match = { class = "^(kitty)$" }, opacity = "0.93 0.9 override 0.9" })

-- Swaync rules blur and ignorezero
hl.layer_rule({ name = "swaync-control-center-fx",      match = { namespace = "^(swaync-control-center)$" },      blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "swaync-notification-window-fx", match = { namespace = "^(swaync-notification-window)$" }, blur = true, ignore_alpha = 0 })

-- hl.layer_rule({ name = "fixibar-fx", match = { namespace = "^(FixiBar)$" }, blur = true, ignore_alpha = 0 })

hl.window_rule({ name = "nemo-opacity", match = { class = "nemo" }, opacity = "0.85 0.9 override 0.9" })

hl.window_rule({ name = "bluetooth-float-center", match = { title = "^(Bluetooth)$" }, float = true, center = true })
