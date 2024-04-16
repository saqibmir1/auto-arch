# AUTO ARCH INSTALLATION SCRIPT #
#part1

# set the script to exit on error
set -euo pipefail

# welcome message
clear
echo -ne "
-------------------------------------------------------------------------
                        WELCOME TO AUTO-ARCH
-------------------------------------------------------------------------
"

#confirm contuation
echo -e "\e[1;31m  Make sure you have partitioned the disk according to the requirements of arch installation. \e[0m"
read -p "Do you want to continue [y/n] " ans
[[ "$ans" != "y" ]] && { echo "Exiting script"; exit 1; }

# display disk partitions
lsblk

# User inputs
read -p "Enter your root partition: " root_partition
read -p "Enter your boot partition: " boot_partition
read -p "Enter your swap partition: " swap_partition

# Additional partition
read -p "Do you want to mount an additional partition? [y/n] " add_part_ans
if [[ "$add_part_ans" == "y" ]]; then
  read -p "Enter the additional partition name: " additional_partition
fi

#must dos
echo "Enabling NTP"
timedatectl set-ntp true
echo "Editing pacman.conf"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
clear

#reflector
echo "If your download speed was slow you can choose the fastest mirrors from reflecror"
read -p "Do you want to automatically select the fastest mirrors? [y/n]" reflecror_ans
if [[ $reflecror_ans = y ]] ; then
  echo "Selecting the fastest mirrors"
  reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --download-timeout 5
fi


# make filesystems
echo "Making filesystems"
mkfs.ext4 $rootpartition
mkswap $swappartition
mkfs.fat -F 32 $bootpartition

# mount filesystems
echo "Mounting FileSystems"
mount $rootpartition /mnt
swapon $swappartition
mkdir -p /mnt/boot/efi
mount $bootpartition /mnt/boot/efi

echo "Mounting additional partition"
if [[ add_part_ans = y ]]; then
  mkdir /mnt/personal
  mount $additionnalpartition /mnt/personal
fi

# pacstrap
echo "Installing Base And Other Packages"
pacstrap /mnt base linux linux-firmware grub efibootmgr networkmanager linux-headers sof-firmware base-devel nano amd-ucode archlinux-keyring || { echo "Pacstrap failed"; exit 1; }

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# arch-chroot
echo "Entering arch-chroot"
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
clear

# questions
read -p "Enter hostname: " hostname
read -p "Enter username: " username
read -p "Enter timezone e.g Asia/Kolkata: " timezone
read -p "Enter disk for grub installation: " grubdisk

# locale, timezone, host, user etc
echo "Configuring timezone, locale, vconsole and hostname"
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "$hostname" > /etc/hostname
clear
echo "Enter password for host: "
passwd

# user
echo "Adding user"
useradd -m -G wheel $username
clear
echo "Enter Password for user: "
passwd $username
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

#install grub
echo "Installing grub"
grub-install $grubdisk
grub-mkconfig -o /boot/grub/grub.cfg

# startup services
echo "Enabling startup services"
systemctl enable NetworkManager

# some postinstallation tweeks
echo "MAKING PACMAN FAST,COLORFULL AND MORE READABLE"
grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf
sudo sed -Ei "s/^#(ParallelDownloads).*/\1 = 5/;/^#Color$/s/#//" /etc/pacman.conf

# finalize
echo -e "\e[1;32m Congratulations auto-arch script was executed successfully. You may reboot now  \e[0m"
echo "umount -a now (recommended)"
echo -ne "
-------------------------------------------------------------------------
                             REBOOT NOW  
-------------------------------------------------------------------------
"
exit
