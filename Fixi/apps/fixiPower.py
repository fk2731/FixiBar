import os
import setproctitle
from dock import main

DIR = os.path.dirname(os.path.abspath(__file__))

buttons = [
    (
        "\ueb0d",
        "Power Off\n<small> Completely shuts down the system.</small>",
        ["systemctl", "poweroff"],
    ),
    ("\ufafd", "Reboot\n<small> Restarts the system.</small>", ["systemctl", "reboot"]),
    (
        "\ueba8",
        "Log Out\n<small> Ends the current Hyprland session.</small>",
        ["hyprctl", "dispatch", "exit"],
    ),
    (
        "\ueaf8",
        "Suspend\n<small> Saves session to RAM. Minimal power usage.</small>",
        ["systemctl", "suspend"],
    ),
    (
        "\ued51",
        "Hibernate\n<small> Saves session to disk. Powers off completely.</small>",
        ["systemctl", "hibernate"],
    ),
    (
        "\ueae2",
        "Lock Screen\n<small> Locks the current session.</small>",
        ["loginctl", "lock-session"],
    ),
]

if __name__ == "__main__":
    setproctitle.setproctitle("FixiApp")
    main(buttons)
