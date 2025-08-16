#!/bin/bash

HOME_PATH="/home/user"
CONFIG_PATH="/home/user/myArch/configs"

#rewrite to saing password
if [ "$(id -u)" -ne 0 ]; then
  echo "Exitst script with sudo!"
  exit 1
fi


function get_question_yn() {
	local text_input=$1

	local YN_TEXT="[Y/n]: "
	echo -n "$text_input $YN_TEXT"

	read input

	if [[ $input == "y" ||  -z $input ]]; then
		return 0
	else
		return 1
	fi
}

#get_question_yn "Do you wanna married?"
#if [ $? -eq 0 ]; then
#	echo "succes"
#else
#	echo "failer"
#fi

function set_pacman_conf() {
	PACMAN_CONF="/etc/pacman.conf"
	PARALLEL_DOWNLOADS=8

	sed -i "s/^#ParallelDownloads = [0-50]*/ParallelDownloads = $PARALLEL_DOWNLOADS/" "$PACMAN_CONF"
	sed -i "s/^#Color/Color/" "$PACMAN_CONF"
}



PARALLER_COUNT=6

install_packages() {
	local file=$1
	if [[ ! -f "$file" ]]; then
			echo "File $file not found!"
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


function create_directories() {
	#Base home dirictores
	cd "$HOME_PATH"
	mkdir programing app picture system
	cd picture
	mkdir wallpaper

	#git clone dwm and blocks
	#TODO remove to other function
	cd $HOME_PATH/system
	git clone https://git.suckless.org/dwm
  git clone https://github.com/torrinfail/dwmblocks.git

	$CONFIG_PATH/dwm.h $HOME_PATH/system/dwm/config.h
	$CONFIG_PATH/dwmblocks $HOME_PATH/system/dwmblocks/blocks.h
}

function dwm_installation() {

	#Install dwm
	cd $HOME_PATH/system/dwm
	sudo make install

	cd $HOME_PATH/system/dwmblocks
	sudo make install

	#startdwm copy
	cp $CONFIG_PATH/xinitrc $HOME_PATH/.xinitrc
	cp $CONFIG_PATH/startdwm.sh $HOME_PATH/.startdwm.sh

	cd $HOME_PATH
	chmod +x .startdwm.sh

}

function other_install() {
	#other configs copy
	#TODO make function
	mkdir -p $HOME_PATH/.config
	mkdir -p $HOME_PATH/.config/kitty
	mkdir -p $HOME_PATH/.config/nvim
	mkdir -p $HOME_PATH/.config/vifm
	mkdir -p $HOME_PATH/.config/cava

	cp -r $CONFIG_PATH/kitty.conf $HOME_PATH/.config/kitty/kitty.conf
	cp -r $CONFIG_PATH/music $HOME_PATH/.config/kitty/music
	cp -r $CONFIG_PATH/nvim $HOME_PATH/.config/nvim/init.vim
	cp -r $CONFIG_PATH/vifmrc $HOME_PATH/.config/vifm/vifmrc
	cp -r $CONFIG_PATH/cava $HOME_PATH/.config/cava/cava

	#Wallpaper install
	cd $CONFIG_PATH../other/wallpaper.sh
	chmod +x wallpaper.sh
	./$CONFIG_PATH../other/wallpaper.sh

	#ohmyzsh
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	#sudo -u $SUDO_USER yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function main() {
	set_pacman_conf

	sudo pacman -Sy

	install_packages "packs/base.packs"
	install_packages "packs/start.packs"
	#install_packages "packs/virtual.packs"
	
	create_directories
	dwm_installation
	other_install
}

main
