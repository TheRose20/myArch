#Monitor
xrandr --output Virtual-1 --mode 1920x1080

#Keyboard swap
setxkbmap us,ru -option 'grp:caps_toggle'

#Wallpaper
feh --bg-scale /home/user/picture/wallpaper/wall.jpg

#Opacity terminal
picom &

#notify
#dunst &

#Blocks
~/system/dwmblocks/dwmblocks &

exec dwm
