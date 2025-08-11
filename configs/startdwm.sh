#!/bin/bash
#Monitor
xrandr --output Virtual-1 --mode 1920x1080

#Keyboard swap
setxkbmap us,ru -option 'grp:caps_toggle'

#Wallpaper
feh --bg-fill --randomize /home/user/picture/wallpaper

#Opacity terminal
#picom &

#notify
#dunst &

#Blocks
~/system/dwmblocks/dwmblocks &

exec dwm
