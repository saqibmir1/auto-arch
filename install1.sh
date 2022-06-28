#!/bin/sh

#variables
rootpartition=/dev/nvme0n1p3
swappartition=/dev/nvme0n1p2
bootpartition=/dev/nvme0n1p1

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
mkfs.ext4 $rootpartition
mkswap $swappartition
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
chmod +x /mnt/chroot.sh

clear
echo "NOW RUN CHROOT.SH FOR FURTHER CONFIGURATION"
arch-chroot /mnt
