# AUTO ARCH INSTALLATION SCRIPT #
#part1

# set the script to exit on error
set -e

printf '\033c'
echo -ne "
-------------------------------------------------------------------------
                        WELCOME TO AUTO-ARCH
-------------------------------------------------------------------------
"
echo "Make sure you have partitioned the disk according to the requirements of arch installation."


read -p "Do you want to continue [y/n] " ans

if [[ "$ans" == "y" ]]; then
    echo "LESS GOOOOOOOOOO"
    sleep 2
else
    echo "Exiting script"
    exit 1
fi

lsblk

# questions
read -p "Enter your root partition: " rootpartition
read -p "Enter your boot partition: " bootpartition
read -p "Enter your swap partition: " swappartition

#must dos
timedatectl set-ntp true
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
clear

#reflector
echo "If your download speed was slow you can choose the fastest mirrors from reflecror"
read -p "Do you want to automatically select the fastest mirrors? [y/n]" answer
if [[ $answer = y ]] ; then
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

# pacstrap
echo "Installing Base And Other Packages"
if ! pacstrap /mnt base linux linux-firmware grub efibootmgr networkmanager linux-headers sof-firmware base-devel nano amd-ucode archlinux-keyring; then
  exit 1
fi

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
printf '\033c'

# questions
read -p "Enter hostname: " hostname
read -p "Enter username: " username
read -p "Enter timezone eg Asia/Kolkata: " timezone
read -p "Enter disk for grub installation: " grubdisk

# locale, timezone etc
echo "Configuring timezone, Clock, Locale, Host, User etc"
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "$hostname" > /etc/hostname
printf '\033c'
echo "Enter password for host: "
passwd

# user
pacman -S zsh git --needed -y
useradd -m -G wheel -s /bin/zsh $username
printf '\033c'
echo "Enter Password for user: "
passwd $username
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

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
cd /home/$Username
git clone --depth 1 https://github.com/saqibmir1/hyprland-dotfiles.git

echo "Congratulations auto-arch script was executed successfully .You may reboot now "
echo "You can now run hyprlland installation script present in your home folder to install hyprland"
echo "umount -a now (recommended)"
echo -ne "
-------------------------------------------------------------------------
                             REBOOT NOW  
-------------------------------------------------------------------------
"
exit

