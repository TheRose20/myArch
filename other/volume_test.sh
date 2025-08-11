#!/bin/bash

pactl set-sink-volume @DEFAULT_SINK@ +5%

VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]\+%' | head -n 1)

notify-send "Громкость увеличена" "$VOLUME"
