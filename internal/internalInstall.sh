#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "Exitst script with sudo!"
  exit 1
fi

while true; do
    echo -n "Which packs you wanna install (a or b): "
    read packs_choice

    if [[ "$packs_choice" == "a" || "$packs_choice" == "b" ]]; then
        break
    else
        echo "Start install packs"
    fi
done



PARALLER_COUNT=6

install_packages() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        echo "Файл $file не найден!"
        exit 1
    fi

    packages=$(grep -v -e '^$' -e '^#' "$file")
    if [[ -z "$packages" ]]; then
        echo "Have'n files to install in $file."
        return
    fi

    echo "$packages" | xargs -n 1 -P $PARALLER_COUNT sudo pacman -Sw --noconfirm --needed

    sudo pacman -S --noconfirm --needed $packages
}

#sudo pacman -Sy

if [["#$packs_choice" == "a"]]; then
	install_packages "packs/base.packs"
	install_packages "packs/start.packs"
else
	install_packages "packs/base.packs"
fi

home_path="/home/user"


cd /home/user
sudo -u $SUDO_USER mkdir programing app picture system
cd picture
sudo -u $SUDO_USER mkdir wallpaper

cd /home/user/system
sudo -u $SUDO_USER git clone https://git.suckless.org/dwm
sudo -u $SUDO_USER git clone https://github.com/torrinfail/dwmblocks.git

sudo -u $SUDO_USER cp /home/user/config.h /home/user/system/dwm/config.h

cd /home/user/system/dwm
sudo make install

cd /home/user/system/dwmblocks
sudo make install

sudo -u $SUDO_USER cp home/user/internal/xinitrc /home/user/.xinitrc
sudo -u $SUDO_USER cp home/user/internal/startdwm.sh /home/user/.startdwm.sh

cd /home/user
sudo -u $SUDO_USER chmod +x .startdwm.sh

curl -o home/user/picture/wallpaperwall/wall.jpg https://ic.pics.livejournal.com/pantsu_squad/60334932/1436863/1436863_original.jpg
