import os

import setproctitle
from dock import main
from fabric.utils import get_relative_path

DIR = os.path.dirname(os.path.abspath(__file__))

POWER_SAVING_SCRIPT = get_relative_path("scripts/power_saving.sh")

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
        ["hyprctl", "dispatch", "hl.dsp.exit()"],
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
    (
        "\ufb9e",
        "Power Saving Mode\n<small> Reduces power consumption.</small>",
        [POWER_SAVING_SCRIPT],
    ),
]

if __name__ == "__main__":
    setproctitle.setproctitle("FixiApp")
    main(buttons)
