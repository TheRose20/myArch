#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
  echo "Exitst script with sudo!"
  exit 1
fi

while true; do
    echo -n "Which packs you wanna install (a or s): "
    read packs_choice

    if [[ "$packs_choice" == "a" || "$packs_choice" == "s" ]]; then
        break
    else
        echo "Start install start packs"
    fi
done

BASEPACKAGES_FILE="packs/base.packs"
STARTPACKAGES_FILE="packs/start.packs"

if [[ -f "$BASEPACKAGES_FILE" ]]; then
  mapfile -t BASEPACKAGES < "$BASEPACKAGES_FILE"
else
  echo "Error: file $BASEPACKAGES_FILE not exist."
  exit 1
fi

if [[ -f "$STARTPACKAGES_FILE" ]]; then
  mapfile -t STARTPACKAGES < "$STARTPACKAGES_FILE"
else
  echo "Error: file $STARTPACKAGES_FILE not exist."
  exit 1
fi

echo


if [["#$packs_choice" == "a"]]; then
	pacman -S --noconfirm $BASEPACKAGES
else
	pacman -S --noconfirm $BASEPACKAGES
	pacman -S --noconfirm $STARTPACKAGES

cd /home/user
mkdir programing app picture system
cd picture
mkdir wallpaper

cd /home/user/system
git clone https://git.suckless.org/dwm
git clone https://github.com/torrinfail/dwmblocks.git

cp config.h /home/user/system/dwm/config.h

cd /home/user/system/dwm
make
sudo make install

cd /home/user/system/dwmblocks
sudo make
sudo make install

cp home/user/xinitrc /home/user/.xinitrc
cp home/user/startdwm.sh /home/user/.startdwm.sh
cd /home/user
chmod +x .startdwm.sh

curl -o home/user/picture/wallpaperwall.jpg https://ic.pics.livejournal.com/pantsu_squad/60334932/1436863/1436863_original.jpg
