#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "Exitst script with sudo!"
  exit 1
fi

echo "Add password for root (default: password):"
read -s PASSWORD
PASSWORD=${PASSWORD:-password}

DISK="/dev/sda"
HOSTNAME="archlinux"
USERNAME="user"

BASEPACKAGES_FILE="/mnt/data/packs/base.packs"
STARTPACKAGES_FILE="/mnt/data/packs/start.packs"

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

PACMAN_CONF="/etc/pacman.conf"
PARALLEL_DOWNLOADS=50

sed -i "s/^#ParallelDownloads = [0-9]*/ParallelDownloads = $PARALLEL_DOWNLOADS/" "$PACMAN_CONF"
sed -i "s/^#Color/Color/" "$PACMAN_CONF"

if grep -q "^ParallelDownloads = $PARALLEL_DOWNLOADS" "$PACMAN_CONF"; then
  echo "pacman succes"
else
  echo "Error pacman.conf"
  exit 1
fi

wipefs -a "$DISK"
sgdisk -Z "$DISK"

sgdisk -n 1:0:+500M -t 1:ef00 -c 1:"EFI" "$DISK"
sgdisk -n 2:0:0 -t 2:8300 -c 2:"Linux" "$DISK"

mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"

mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

pacstrap /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt bash -c "
  echo '$HOSTNAME' > /etc/hostname
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  hwclock --systohc
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
  locale-gen
  echo 'LANG=en_US.UTF-8' > /etc/locale.conf

  echo 'root:$PASSWORD' | chpasswd
  useradd -m -G wheel -s /bin/bash $USERNAME
  echo '$USERNAME:$PASSWORD' | chpasswd
  echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

  pacman -S --noconfirm grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  echo "Installing base packeges"
  pacman -S --noconfirm ${BASEPACKAGES[@]}

  echo "Installing start packeges"
  pacman -S --noconfirm ${STARTPACKAGES[@]}

  systemctl enable NetworkManager
"

umount -R /mnt
echo "Installation succes! Reboot in 3 sec"
sleep 3
reboot

