#!/bin/bash

# Проверка запуска от root
if [ "$(id -u)" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт от имени root."
  exit 1
fi

# Настройка
DISK="/dev/sda"    # Укажите ваш диск
HOSTNAME="archlinux"
USERNAME="user"
PASSWORD="password"
PACKAGES=(vim git base-devel networkmanager wget curl)

echo "Очищаем диск..."
wipefs -a $DISK
sgdisk -Z $DISK

echo "Создаем разделы..."
sgdisk -n 1:0:+500M -t 1:ef00 -c 1:"EFI" $DISK  # EFI раздел
sgdisk -n 2:0:0 -t 2:8300 -c 2:"Linux" $DISK    # Раздел под систему

echo "Форматируем разделы..."
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"

echo "Монтируем разделы..."
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

echo "Устанавливаем базовую систему..."
pacstrap /mnt base linux linux-firmware

echo "Настраиваем систему..."
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt bash -c "
  echo '$HOSTNAME' > /etc/hostname
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  hwclock --systohc
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
  echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
  locale-gen
  echo 'LANG=en_US.UTF-8' > /etc/locale.conf

  echo 'root:$PASSWORD' | chpasswd
  useradd -m -G wheel -s /bin/bash $USERNAME
  echo '$USERNAME:$PASSWORD' | chpasswd

  echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

  pacman -S --noconfirm grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  echo "Устанавливаем дополнительные пакеты..."
  pacman -S --noconfirm ${PACKAGES[@]}

  systemctl enable NetworkManager
"

echo "Завершаем установку..."
umount -R /mnt
echo "Установка завершена. Перезагрузите систему."
