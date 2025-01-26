#!/bin/bash
# Only Efi install

if [ "$(id -u)" -ne 0 ]; then
  echo "Exitst script with sudo!"
  exit 1
fi

echo -n "Add password for root (default: password):"
read -s PASSWORD
PASSWORD=${PASSWORD:-password}

DISK="/dev/sda"
HOSTNAME="archlinux"
USERNAME="user"

BASEPACKAGES_FILE="packs/base.packs"
STARTPACKAGES_FILE="packs/start.packs"

PACMAN_CONF="/etc/pacman.conf"
PARALLEL_DOWNLOADS=30

sed -i "s/^#ParallelDownloads = [0-50]*/ParallelDownloads = $PARALLEL_DOWNLOADS/" "$PACMAN_CONF"
sed -i "s/^#Color/Color/" "$PACMAN_CONF"

if grep -q "^ParallelDownloads = $PARALLEL_DOWNLOADS" "$PACMAN_CONF"; then
  echo "Pacman edited"
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

pacstrap /mnt base linux linux-firmware base-devel zsh networkmanager grub efibootmgr

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

  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  systemctl enable NetworkManager
"

#umount -R /mnt
echo "Installation succes!"

arch-chroot /mnt bash
