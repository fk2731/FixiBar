#!/usr/bin/env python3
from fabric.hyprland.widgets import WorkspaceButton, Workspaces

from config import add_hover_cursor


# Name it like a class so it appears as a widget during import
def WorkspacesWidget():
    w = Workspaces(
        name="workspaces",
        invert_scroll=True,
        empty_scroll=True,
        v_align="fill",
        orientation="h",
        spacing=5,
        buttons=[WorkspaceButton(id=i, label=str(i)) for i in range(1, 4)],
    )

    ignored = [-99, -98]

    for b in w.get_child():
        add_hover_cursor(b)

    def hide_ignored(*_):
        for b in w.get_child():
            if b.id in ignored:
                w.remove_button(b)

    for signal in ["event::workspacev2", "event::createworkspacev2", "event::urgent"]:
        w.connection.connect(signal, hide_ignored)

    hide_ignored()
    return w
