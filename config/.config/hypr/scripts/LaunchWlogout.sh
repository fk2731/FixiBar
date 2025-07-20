#!/bin/bash

if ! pgrep -x "wlogout" > /dev/null; then
    wlogout &
fi

