#Mouse

MOUSE_SENSETIVE=0.3

xinput --set-prop 12 'Coordinate Transformation Matrix' MOUSE_SENSETIVE 0 0 0 MOUSE_SENSETIVE 0 0 0 1

xinput --set-prop 14 'Coordinate Transformation Matrix' MOUSE_SENSETIVE 0 0 0 MOUSE_SENSETIVE 0 0 0 1

xset mouse 0 0

#keyboard swap
setxkbmap us,ru -option 'grp:caps_toggle'

#Wallpaper
feh --bg-scale /home/rose/picture/wallpaper/wall.jpg

#Opacity terminal
picom&

#Not closed dwm
while true; do
	dwm
done

