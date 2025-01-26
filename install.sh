#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script with sudo!"
  exit 1
fi

read -p "Enter root password (default: password): " -s PASSWORD
PASSWORD=${PASSWORD:-password}
read -p "Enter disk to install on (default: /dev/sda): " DISK
DISK=${DISK:-/dev/sda}
read -p "Enter hostname (default: archlinux): " HOSTNAME
HOSTNAME=${HOSTNAME:-archlinux}
read -p "Enter username (default: user): " USERNAME
USERNAME=${USERNAME:-user}

PACMAN_CONF="/etc/pacman.conf"
PARALLEL_DOWNLOADS=30

sed -i "s/^#ParallelDownloads = [0-50]*/ParallelDownloads = $PARALLEL_DOWNLOADS/" "$PACMAN_CONF"
sed -i "s/^#Color/Color/" "$PACMAN_CONF"

if grep -q "^ParallelDownloads = $PARALLEL_DOWNLOADS" "$PACMAN_CONF"; then
  echo "Pacman configuration updated."
else
  echo "Error updating pacman configuration."
  exit 1
fi

wipefs -a "$DISK"
sgdisk -Z "$DISK"

echo "Detecting boot mode..."
if [[ -d /sys/firmware/efi ]]; then
  echo "EFI mode detected."
  sgdisk -n 1:0:+500M -t 1:ef00 -c 1:"EFI" "$DISK"
  sgdisk -n 2:0:0 -t 2:8300 -c 2:"Linux" "$DISK"

  mkfs.fat -F32 "${DISK}1"
  mkfs.ext4 "${DISK}2"

  mount "${DISK}2" /mnt
  mkdir -p /mnt/boot
  mount "${DISK}1" /mnt/boot
else
  echo "BIOS mode detected."
  sgdisk -n 1:0:0 -t 1:8300 -c 1:"Linux" "$DISK"

  mkfs.ext4 "${DISK}1"

  mount "${DISK}1" /mnt
fi

pacstrap /mnt base linux linux-firmware base-devel zsh networkmanager grub

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

  if [[ -d /sys/firmware/efi ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  else
    grub-install --target=i386-pc $DISK
  fi

  grub-mkconfig -o /boot/grub/grub.cfg
  systemctl enable NetworkManager
"

umount -R /mnt
echo "Installation complete! Reboot to enjoy your new system."
