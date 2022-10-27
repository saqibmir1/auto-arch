#!/bin/sh

#variables
email=mirsaquib3737@gmail.com
downloadwalpapers=yes
deploydotfiles=yes

#performance tweaks and plasma customistion

echo -ne "
-------------------------------------------------------------------------
                      CUSTOMISING PLASMA DESKTOP
-------------------------------------------------------------------------
"

echo "DOING SOME PERFORMANCE TWEAKS"
balooctl suspend
balooctl disable
rm -rf ~/.local/share/baloo

#installing sddm theme
echo "INSTALLING SDDM THEME"
git clone https://github.com/totoro-ghost/sddm-astronaut.git ~/astronaut/
sudo mv ~/astronaut/ /usr/share/sddm/themes/

if [[ $downloadwallpapers = yes ]]
then
    echo "DOWNLOADING WALPAPERS (THIS IS GOING TO TAKE A WHILE)"
    git clone https://github.com/saqibmir1/walpapers.git ~/Pictures
    rm -rf ~/Pictures/walpapers/.git
    rm ~/Pictures/walpapers/README.md
    rm -rf ~/Pictures/walpapers/images
fi


#deploying dotfiles
echo -ne "
-------------------------------------------------------------------------
      		DEPLOYING DOTFILES/ CONFIGURING USER FILES
-------------------------------------------------------------------------
"

if [[ deploydotfiles =  yes ]]
then
    echo "CLONING MY DOTFILES FROM GITHUB"
    git clone https://github.com/saqibmir1/dotfiles.git

    #home folder
    v -f ~/dotfiles/.zshrc ~
    mv -f ~/dotfiles/.zprofile ~
    #mv -f ~/dotfiles/.gitconfig ~
    mv -f ~/dotfiles/kde_shortcuts.kksrc ~/.config

    #.config folder
    #mkdir -p ~/.config/nvim
    #mv -f ~/dotfiles/.config/nvim/init.vim ~/.config/nivm
    #touch ~/.config/nvim/shortcuts.vim

    #.local/bin folder
    mkdir -p ~/.local/bin
    mv ~/dotfiles/.local/bin/* ~/.local/bin

    #.local/share folder
    mkdir -p ~/.local/share/wall
    mv -f ~/dotfiles/.local/share/konsole/* ~/.local/share/konsole
    mv -f ~/dotfiles/.local/share/wall/* ~/.local/share/wall
fi

#change shell to zsh
echo "CHANGING SHELL TO ZSH"
chsh -s $(which zsh)
mkdir -p ~/.cache/zsh

#make new home dirs
mkdir ~/Code
mkdir ~/Git
mkdir ~/Projects

#cleaning
echo "CLEANING HOME DIRECTORY"
rm ~/.bash*
rm -rf ~/dotfiles
rm -rf ~/yay-bin
rm -rf ~/auto-arch
rmdir Templates
rmdir Public
sudo pacman -Rns discover

#generating ssh key for github
echo "GENERATING SSH KEY FOR GITHUB"
ssh-keygen -t ed25519 -C "$email"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "KEY GENERATED"

#finalize
clear
echo "------------------------ALL DONE-------------------------------"
echo "       YOU MAY WANT TO REBOOT BEFORE USING THE SYSTEM          "
echo "---------------------------------------------------------------"
