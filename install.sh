#!/bin/bash

#root check
if [ "$(id -u)" -ne 0 ]; then
  echo "Please start the script with sudo"
  exit 1
fi

#TODO user name hostname editable and other

echo "New password for user:"
read -s PASSWORD

if [[ -z "$PASSWORD" ]]; then
	PASSWORD="password"
fi

DISK="/dev/sda"
HOSTNAME="archlinux"
USERNAME="user"

BASEPACKGES=(vim git base-devel networkmanager wget curl)

#TODO add support other packs files

base_packges_path="packs/base.packs"
mapfile -t BASEPACKGES < "$base_packges_path"

start_packges_path="packs/start.packs"
mapfile -t STARTPACKGES < "$start_packges_path"

PACMAN_CONF="/etc/pacman.conf"
PARALLELDOWNLOADSCOUNT=50

sed -i 's/^#ParallelDownloads = [0-9]*/ParallelDownloads = $PARALLELDOWNLOADSCOUNT/' "$PACMAN_CONF"
sed -i 's/^#Color*/Color' "$PACMAN_CONF"

if grep -q '^ParallelDownloads = PARALLELDOWNLOADSCOUNT' "$PACMAN_CONF"; then
  echo "pacman.conf insert succes"
else
  echo "insert error"
  exit 1
fi


echo "Disk cleaning"
wipefs -a $DISK
sgdisk -Z $DISK

echo "Creating partision"
sgdisk -n 1:0:+500M -t 1:ef00 -c 1:"EFI" $DISK 
sgdisk -n 2:0:0 -t 2:8300 -c 2:"Linux" $DISK  

echo "Formating the partitions..."
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"

echo "Mount the partitions..."
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

echo "Installing base system..."
pacstrap /mnt base linux linux-firmware

echo "Customizing the system..."
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt bash -c "
  echo '$HOSTNAME' > /etc/hostname
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  hwclock --systohc
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
  #echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
  locale-gen
  echo 'LANG=en_US.UTF-8' > /etc/locale.conf

  echo 'root:$PASSWORD' | chpasswd
  useradd -m -G wheel -s /bin/bash $USERNAME
  echo '$USERNAME:$PASSWORD' | chpasswd

  echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

  pacman -S --noconfirm grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  echo "Download and Install base packages.."
  pacman -S --noconfirm ${BASEPACKGES[@]}

  echo "Download and Install start packages..."
  pacman -S --noconfirm ${STARTPACKGES[@]}

  systemctl enable NetworkManager
"

echo "Ending the installation"
umount -R /mnt
echo "Installation complete. Reboot system by 3 seconds"

sleep 3
reboot
