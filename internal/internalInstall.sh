#!/bin/bash

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
		packs_choice="s"
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
	pacman -S --noconfirm TODO
else
	pacman -S --noconfirm TODO a + s
