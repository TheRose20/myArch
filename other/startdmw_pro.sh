
#Monitors settings
xrandr --output DP-2 --pos 1080x700
xrandr --output DP-2 --primary

#xrandr --output DP-1 --pos 0x0
xrandr --output DP-1 --rotate right 

xrandr --output DP-1 --auto --right-of DP-1 

#Mouse

MOUSE_SENSETIVE=0.3
#MOUSE_SENSETIVE2=0.18
MOUSE_SENSETIVE2=1

xinput --set-prop 12 'Coordinate Transformation Matrix' $MOUSE_SENSETIVE2 0 0 0 $MOUSE_SENSETIVE2 0 0 0 1

#xinput --set-prop 14 'Coordinate Transformation Matrix' $MOUSE_SENSETIVE 0 0 0 $MOUSE_SENSETIVE 0 0 0 1

xset mouse 0 0

#keyboard swap
setxkbmap us,ru -option 'grp:caps_toggle'


#Wallpaper
feh --bg-scale /home/rose/picture/wallpaper/wall.jpg

#Opacity terminal
picom &

#notify
#TODO is it needble?
dunst &

#Blocks
~/system/dwmblocks/dwmblocks &

exec dwm

#Not closed dwm
# while true; do
# 	setxkbmap us,ru -option 'grp:caps_toggle'
# 	dwm
# done

