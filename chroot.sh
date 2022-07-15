#!/bin/sh

#variables
hostname=arch
username=saqib
timezone=Asia/Kolkata
grubdisk=/dev/nvme0n1

echo -ne "
-------------------------------------------------------------------------
                    CONFIGURING LOCALE, TIME ZIONE
-------------------------------------------------------------------------
"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$hostname" > /etc/hostname
passwd
useradd -m -G wheel -s /bin/bash $username
passwd $username
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


#install grub
echo -ne "
-------------------------------------------------------------------------
                            INSTALLING GRUB
-------------------------------------------------------------------------
"
grub-install $grubdisk
grub-mkconfig -o /boot/grub/grub.cfg

#enable systemctl services
echo "ENABLING STARTUP SERVICES"
systemctl enable NetworkManager.service


#finalize
curl -LO https://raw.githubusercontent.com/saqibmir1/auto-arch/master/kde.sh
mv kde.sh $HOME
echo "Congratulations auto-arch script was executed successfully .You may reboot now "
echo "NOW umount -a and reboot to start using newly installed system"
echo -ne "
-------------------------------------------------------------------------
                REBOOT NOW and login as user to run kde.sh
-------------------------------------------------------------------------
"
exit
