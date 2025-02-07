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

PACMAN_CONF="/etc/pacman.conf"
PARALLEL_DOWNLOADS=8

sed -i "s/^#ParallelDownloads = [0-50]*/ParallelDownloads = $PARALLEL_DOWNLOADS/" "$PACMAN_CONF"
sed -i "s/^#Color/Color/" "$PACMAN_CONF"



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

install_packages "packs/base.packs"
install_packages "packs/start.packs"

#home_path="/home/user"

#Base home dirictores
cd /home/user
sudo -u $SUDO_USER mkdir programing app picture system
cd picture
sudo -u $SUDO_USER mkdir wallpaper

#git clone dwm and blocks
cd /home/user/system
sudo -u $SUDO_USER git clone https://git.suckless.org/dwm
sudo -u $SUDO_USER git clone https://github.com/torrinfail/dwmblocks.git

sudo -u $SUDO_USER cp /home/user/internal/config/config.h /home/user/system/dwm/config.h

#Install dwm
cd /home/user/system/dwm
sudo make install

cd /home/user/system/dwmblocks
sudo make install

#startdwm copy
sudo -u $SUDO_USER cp /home/user/internal/config/xinitrc /home/user/.xinitrc
sudo -u $SUDO_USER cp /home/user/internal/config/startdwm.sh /home/user/.startdwm.sh

cd /home/user
sudo -u $SUDO_USER chmod +x .startdwm.sh

sudo -u $SUDO_USER chmod +x url_test.sh
sudo -u $SUDO_USER ./url_test.sh

#other configs copy
sudo -u $SUDO_USER mkdir -p /home/user/.config
sudo -u $SUDO_USER cp -r /home/user/internal/config/kitty /home/user/.config/
sudo -u $SUDO_USER cp -r /home/user/internal/config/nvim /home/user/.config/

#Wallpaper install
sudo -u $SUDO_USER ${home_path}/internal/url_test.sh

#ohmyzsh
#sudo -u $SUDO_USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo -u $SUDO_USER yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
