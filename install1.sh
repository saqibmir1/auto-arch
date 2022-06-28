#!/bin/sh

echo -ne "
-------------------------------------------------------------------------
                        WELCOME TO AUTO-ARCH
-------------------------------------------------------------------------
"

#must do's


timedatectl set-ntp true
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
clear

#reflector
echo "If your download speed was slow you can choose the fastest mirrors from reflecror"
read -p "Do you want to automatically select the fastest mirrors? [y/n]" answer
if [[ $answer = y ]] ; then
  echo "Selecting the fastest mirrors"
  reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --download-timeout 5
fi

#make filesystems
echo -ne "
-------------------------------------------------------------------------
                      MAKING FILESYSTEMS
-------------------------------------------------------------------------
"
lsblk
read -p "enter root partition: " rootpartition
mkfs.ext4 $rootpartition
read -p "enter swap partition: " swappartition
mkswap $swappartition
read -p "enter boot partition: " bootpartition
mkfs.fat -F 32 $bootpartition

echo -ne "
-------------------------------------------------------------------------
                     MOUNTING FILESYSTEMS
-------------------------------------------------------------------------
"
#mount filesystems
mount $rootpartition /mnt
swapon $swappartition
mkdir -p /mnt/boot/efi
mount $bootpartition /mnt/boot/efi

#pacstrap and genfstab
echo -ne "
-------------------------------------------------------------------------
                    INSTALLING BASE AND OTHER CORE PACKAGES
-------------------------------------------------------------------------
"
pacstrap /mnt base linux linux-firmware grub efibootmgr networkmanager linux-headers sof-firmware base-devel nano amd-ucode archlinux-keyring
genfstab -U /mnt >> /mnt/etc/fstab

#prepare for chroot.sh
mv chroot.sh /mnt
mv kde.sh /mnt/home/$username
mv postinstall.sh /mnt/home/$username
chmod +x /mnt/chroot.sh
chmod +x /mnt/home/$username
chmod +x /mnt/home/$username

clear
echo "NOW RUN CHROOT.SH FOR FURTHER CONFIGURATION"
arch-chroot /mnt
