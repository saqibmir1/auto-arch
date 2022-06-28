 
#!/bin/sh
clear

variables
game=no
libreoffice=yes

echo -ne "
-------------------------------------------------------------------------
				WECLOME
		THIS SCRIPT WILL KDE AND ALL THE APPLICATIONS I USE
-------------------------------------------------------------------------
"

sleep 3
clear

echo "executing script in 3..."
sleep 1
clear
echo "executing script in 3  2..."
sleep 1
clear
echo "executing script in 3  2  1..."
sleep 1
clear


#preinstall tweeks
echo -ne "
-------------------------------------------------------------------------
                    ENABLING PREINSTALLIN TWEEKS
-------------------------------------------------------------------------
"
echo "MAKING PACMAN FAST,COLORFULL AND MORE READABLE"
sudo grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
echo "USING ALL CORES FOR COMPILATION"
sudo sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf


echo -ne "
-------------------------------------------------------------------------
                          UPDATING ARCH SYSTEM
-------------------------------------------------------------------------
"
#update system
sudo pacman -Syyu --noconfirm

#archlinux-keyring
sudo pacman -Sy archlinux-keyring --noconfirm


echo -ne "
-------------------------------------------------------------------------
                        INSTALLING PACKAGES FROM PACMAN
-------------------------------------------------------------------------
"
#installing packages from pacman
PKGS=(

	'android-tools' #useful programs
	'bleachbit'
	'firefox'
	'htop'
	'neovim'
	'mpv'
	'ranger'
	'telegram-desktop'
	'zsh'
	'zsh-syntax-highlighting'
	'partitionmanager'
	'discord'
	'jq'
	'fzf'
	'bluedevel'
	'bluez-utils'
	'git'
	'base-devel'
	'noto-fonts-emoji'
	'cmus'
	'yt-dlp'
	'wget'

	'ttf-nerd-fonts-symbols' #fonts
	'noto-fonts-emoji'

	'plasma' #kde
	'sddm'
	'konsole'

	'gwenview' #kde apps
	'okular'
	'ark'
	'spectacle'

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done


#gaming

if [ $game = "yes" ]; then
	sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
	PKGS=(

		'amd-ucode' #steam and lib32 packages
		'xf86-video-amdgpu'
		'vulkan-radeon'
		'vulkan-tools'
		'vulkan-headers'
		'vulkan-icd-loader'
		'mesa'
		'lib32-mesa'
		'lib32-vulkan-radeon'
		'steam'
		'ttf-liberation'
		'wqy-zenhei'

	)

	for PKG in "${PKGS[@]}"; do
		echo "INSTALLING: ${PKG}"
		sudo pacman -S "$PKG" --noconfirm --needed
	done

#office suite
if [ $libreoffice =  "yes" ]; then
	sudo pacman -S libreoffice-still --noconfirm
fi


#installing yay

echo -ne "
-------------------------------------------------------------------------
                   INSTALLING PACKAGES FROM THE AUR
-------------------------------------------------------------------------
"
echo "INSTALLING YAY, AN AUR HELPER"
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -frsi
cd ~

#installing packages from aur
echo "INSTALLING PACKAGES FROM THE AUR"
PKGS=(

	'spotify'
	'ytfzf'
	'auto-cpufreq'

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    yay -S "$PKG" --removemake
done


#enable/disable systemctl services

echo -ne "
-------------------------------------------------------------------------
                     ENABLING SOYSTEMD SERVICES
-------------------------------------------------------------------------
"
sudo systemctl enable bluetooth.service
sudo systemctl enable auto-cpufreq.service


#finalize and reboot
clear

echo -ne "
-------------------------------------------------------------------------
                 SCRIPT HAS BEEN EXECUTED SUCCESSFULLY
                 REBOOT NOW AND RUN POSTINSTALL.SH
-------------------------------------------------------------------------
"
read -p "Reboot now [y/n]: " rebootnow
if [ $rebootnow = "y" ]; then;
	reboot
fi
