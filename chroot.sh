#!/bin/sh

echo -ne "
-------------------------------------------------------------------------
                        CONFIGURING SYSTEM
-------------------------------------------------------------------------
"
#questions and variables and passwords
read -p "enter hostname: " hostname
read -p "enter username: " username

echo "$hostname" > /etc/hostname
echo "enter passsword for host"
passwd
echo "enter password for user account"
passwd $username
lsblk
read -p "enter diskname for grub installation" disk

echo -ne "
-------------------------------------------------------------------------
                    CONFIGURING LOCALE, TIME ZIONE
-------------------------------------------------------------------------
"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
clear


#install grub
echo -ne "
-------------------------------------------------------------------------
                            INSTALLING GRUB
-------------------------------------------------------------------------
"
grub-install $disk
grub-mkconfig -o /boot/grub/grub.cfg

#enable systemctl services
echo "ENABLING STARTUP SERVICES"
systemctl enable NetworkManager.service

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
useradd -m -G wheel -s /bin/bash $username

#finalize
echo "Congratulations auto-arch script was executed successfully .You may reboot now "
echo "NOW umount -a and reboot to start using newly installed system"
echo -ne "
-------------------------------------------------------------------------
                REBOOT NOW and login as user to run kde.sh
-------------------------------------------------------------------------
"

exit
