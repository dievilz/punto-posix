#!/bin/bash
#
# Arch Linux Packages Install Script
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)


setup_repos_archlinux() {
	if command -v yay > /dev/null 2>&1 || [ -d "$HOME"/Dev/Repos/yay ];
	then
		warn "You already have Yet-Another-Yaourt (Yay) downloaded!"
	else
		echo; subopt "Downloading Yet-Another-Yaourt (Yay)"

		git clone https://aur.archlinux.org/yay.git "$HOME"/Dev/Repos/yay || {
			error "Git clone of Yay failed! Aborting..."
			echo; exit 127
		}

		if [ -e "$HOME"/Dev/Repos/yay/PKGBUILD ]; then
			echo; subopt "Building Yay pkg"

			cd "$HOME"/Dev/Repos/yay && makepkg -si || {
				error "Yay PKGBUILD failed! Aborting..."
				echo; exit 1
			}
		fi
	fi
	echo
}

setup_packages_archlinux() {
	success "Using Pacman package manager"

	if [ -e "/var/lib/pacman/db.lck" ]; then
		sudo rm -rf /var/lib/pacman/db.lck
	fi

	echo; subopt "Installing LARBS libraries"             # No instales scrot, para eso es maim
	sudo pacman -S --noconfirm --needed atool arandr bc calcurse copyq conky docx2txt dosfstools dunst exfat-utils
	sudo pacman -S --noconfirm --needed flashplugin imagemagick maim mediainfo minizip mpd mpc mpv ncmpcpp
	sudo pacman -S --noconfirm --needed ntfs-3g pepper-flash pinta pulsemixer ranger sxiv sxhkd unclutter unrar
	sudo pacman -S --noconfirm --needed unzip vifm vlc xcape xclip xcompmgr xdotool youtube-dl w3m zathura

	echo; subopt "Installing Muh libraries B-)"
	sudo pacman -S --noconfirm --needed ack apache arduino composer cowsay dnsmasq dolphin
	sudo pacman -S --noconfirm --needed fd feh fortune-mod fzf go gparted highlight
	sudo pacman -S --noconfirm --needed lolcat mariadb neofetch neovim nnn php
	sudo pacman -S --noconfirm --needed php-apache phpmyadmin rsync the_silver_searcher
	sudo pacman -S --noconfirm --needed tree wireshark-qt zsh-syntax-highlighting tmux

	echo; subopt "Installing Terminals"
	sudo pacman -S --noconfirm --needed rxvt-unicode
	sudo pacman -S --noconfirm --needed terminator

	echo; subopt "Installing LibreOffice"
	sudo pacman -S --needed libreoffice-fresh
}

setup_displayserver_archlinux() {
	case "$resp" in
		"xorg")
			subopt "Installing XORG Server with Xinit"
			sudo pacman -S --noconfirm --needed xorg xorg-xinit
		;;
		"wayland")
			subopt "Installing Wayland with Weston compositor"
			sudo pacman -S --noconfirm --needed wayland weston
		;;
		"all" | "")
			subopt "Installing All of them B-)"
			sudo pacman -S --noconfirm --needed xorg xorg-xinit wayland weston
		;;
	esac
}

setup_desktopenv_archlinux() {
	case "$resp" in
		"gnome")
			subopt "Installing GNOME"
			sudo pacman -S --noconfirm --needed gnome gnome-tweaks chrome-gnome-shell

			echo; subopt "Installing GDM login screen"
			sudo pacman -S --noconfirm --needed gdm
			sudo systemctl enable gdm.service

			gnome_stuff
		;;
		"kde")
			subopt "Installing KDE Plasma"
			sudo pacman -S --noconfirm --needed plasma

			echo; subopt "Installing SDDM login screen"
			sudo pacman -S --noconfirm --needed sddm sddm-kcm
			sudo systemctl enable sddm.service
		;;
		"xfce")
			subopt "Installing XFCE 4"
			sudo pacman -S --noconfirm --needed xfce4

			echo; subopt "Installing LightDM login screen"
			sudo pacman -S --noconfirm --needed lightdm lightdm-webkit2-greeter

			echo; subopt "Reinstalling gdk-pixbuf2 for a LightDM bug"
			sudo pacman -S --noconfirm --needed gdk-pixbuf2

			echo; subopt "Installing LightDM Webkit2 Aether theme"
			yay -S --noconfirm --needed lightdm-webkit-theme-aether
			sudo systemctl enable lightdm.service
		;;
		"all" | "")
			subopt "Installing All of them B-)"

			echo; subopt "Installing GNOME"
			sudo pacman -S --noconfirm --needed gnome gnome-tweaks chrome-gnome-shell

			gnome_stuff

			echo; subopt "Installing KDE Plasma"
			sudo pacman -S --noconfirm --needed plasma

			echo; subopt "Installing XFCE 4"
			sudo pacman -S --noconfirm --needed plasma xfce

			echo; subopt "Installing Console Display Manager login screen (CDM)"
			yay -S --noconfirm --needed cdm-git
			sudo systemctl enable cdm.service
		;;
	esac
}

setup_windowsmanager_archlinux() {
	case "$resp" in
		"i3-gaps")
			subopt "Installing i3-gaps"
			sudo pacman -S --noconfirm --needed community/i3-gaps
			yay -S --noconfirm --needed i3pystatus-git
		;;
		"dwm")
			subopt "Installing DWM"
			yay -S --noconfirm --needed dwm-git dwm-custom
		;;
		"awesome")
			subopt "Installing Awesome"
			sudo pacman -S --noconfirm --needed community/awesome
		;;
		"all" | "")
			subopt "Installing All of them B-)"
			sudo pacman -S --noconfirm --needed community/i3-gaps community/awesome
			yay -S --noconfirm --needed i3pystatus-git dwm-git dwm-custom
		;;
	esac
}

setup_texteditors_archlinux() {
	case "$resp" in
		"sublime")
			subopt "Installing Sublime Text 3"
			yay -S --noconfirm --needed aur/sublime-text-dev
		;;
		"vscode")
			subopt "Installing Visual Studio Code"
			yay -S --noconfirm --needed visual-studio-code-bin
		;;
		"all" | "")
			subopt "Installing All of them B-)"
			yay -S --noconfirm --needed aur/sublime-text-dev
			yay -S --noconfirm --needed visual-studio-code-bin
		;;
	esac
}

uninstall_undesired_archlinux() {
	case "$DISTRO" in
		"Arch")
			warn "Nothing to uninstall yet..."
		;;
		"Manjaro")
			subopt "Uninstalling KDE Plasma default apps that I don't like"
			sudo pacman -Rns --noconfirm yakuake kate falkon
		;;
	esac
}

setup_community_archlinux() {
	subopt "Installing PAMAC"
	yay -S --noconfirm --needed pamac-aur

	echo; subopt "Installing Luke Smith's version of Suckless Terminal (st)"
	yay -S --noconfirm --needed st-luke-git

	echo; subopt "Downloading Chrome and Firefox"
	yay -S --noconfirm --needed google-chrome
	yay -S --noconfirm --needed firefox-beta-bin

	subopt "Downloading i3-wm packages"
	yay -S --noconfirm --needed dmenu2
	yay -S --noconfirm --needed j4-dmenu-desktop-git
	yay -S --noconfirm --needed i3-layout-manager-git
	yay -S --noconfirm --needed i3lock-color-git
	yay -S --noconfirm --needed betterlockscreen-git

	echo; subopt "Downloading Ruby packages"
	yay -S --noconfirm --needed chruby-git
	yay -S --noconfirm --needed ruby-install-git

	echo; subopt "Downloading MongoDB and utilities"
	yay -S --noconfirm --needed mongodb-bin
	yay -S --noconfirm --needed mongodb-compass-community
}

setup_fonts_archlinux() {
	sudo pacman -S --noconfirm --needed ttf-opensans
	yay -S --noconfirm --needed ttf-input
	sudo pacman -S --noconfirm --needed otf-fira-code
	sudo pacman -S --noconfirm --needed ttf-roboto
	yay -S --noconfirm --needed ttf-roboto-mono
	yay -S --noconfirm --needed nerd-fonts-terminus
	# yay -s --noconfirm --needed ttf-ms-win10 #opcion 7
}

setup_postinstall_archlinux() {
	subopt "Downloading Status Bars, this gonna take some time... really"
	yay -S --noconfirm --needed polybar-git
	yay -S --noconfirm --needed lemonbar-xft-git

	echo; suboptq "Do you want to continue? [Enter to exit]: "
	read -r resp
	case "$resp" in
		"") return ;;
	esac

	echo; subopt "Downloading some Dev Apps, this gonna take some time... too"
	yay -S --noconfirm --needed mycli
	yay -S --noconfirm --needed postman-bin

	echo; suboptq "Do you want to continue? [Enter to exit]: "
	read -r resp
	case "$resp" in
		"") return ;;
	esac

	echo; subopt "Downloading some Productivity apps, this is gonna be slower..."
	yay -S --noconfirm --needed compton-tryone-blackcapcoder-git
	yay -S --noconfirm --needed overdue
	yay -S --noconfirm --needed peek-git
	yay -S --noconfirm --needed skb
	yay -S --noconfirm --needed urlscan-git
	yay -S --noconfirm --needed urxvt-resize-font-git

	echo; suboptq "Do you want to continue? [Enter to exit]: "
	read -r resp
	case "$resp" in
		"") return ;;
	esac

	# These takes a shitload of time
	echo; subopt "The slowest to download and build, behold..."
	yay -S --noconfirm --needed pick-colour-picker
	yay -S --noconfirm --needed shutter
	yay -S --noconfirm --needed python-ueberzug
	yay -S --noconfirm --needed simple-mtpfs
	# yay -S --noconfirm --needed htop-temperature-git # This failed the first time
}


gnome_stuff() {
	if [ "${DISTRO}" = "Manjaro" ]; then
		echo; subopt "Confirm to install Manjaro GNOME Theme for GNOME Display Manager (GDM)?"
		sudo pacman -S --needed manjaro-gdm-theme
	fi

	echo; suboptq "Do you want to install GNOME-Wallpaper-Changer? ['Y'|'n']: "
	read -r resp
	case "$resp" in
		y*|Y*|"")
			if [ ! -d "$HOME"/Dev/Repos/gnome-wallpaper-changer ]; then
				echo
				subopt "Downloading GNOME-Wallpaper-Changer"

				git clone https://github.com/dirkgroenen/gnome-wallpaper-changer.git "$HOME"/Dev/Repos/gnome-wallpaper-changer || {
					error "Git clone of GNOME-Wallpaper-Changer failed! Aborting..."
					echo; exit 127
				}

				if [ -e "$HOME"/Dev/Repos/gnome-wallpaper-changer/install.sh ]; then
					echo; subopt "Installing GNOME-Wallpaper-Changer"

					cd "$HOME"/Dev/Repos/gnome-wallpaper-changer/ && ./install.sh || {
						error "GNOME-Wallpaper-Changer installation failed! Aborting..."
						echo; exit 1
					}
				fi
			else
				warn "You already have GNOME-Wallpaper-Changer downloaded!"
			fi
		;;
		n*|N*|"skip")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
}


main_archlinux() {
	case $1 in
		"-h"|"--help")
			usage_archlinux
			exit 0
		;;
		"--repos")
			echo; setup_repos_archlinux
		;;
		"--packages")
			echo; setup_packages_archlinux
		;;
		"--display-server")
			echo; setup_displayserver_archlinux
		;;
		"--desktop-env")
			echo; setup_desktopenv_archlinux
		;;
		"--windows-manager")
			echo; setup_windowsmanager_archlinux
		;;
		"--text-editors")
			echo; setup_texteditors_archlinux
		;;
		"--uninstall-undesired")
			echo; uninstall_undesired_archlinux
		;;
		"--community")
			echo; setup_community_archlinux
		;;
		"--fonts")
			echo; setup_fonts_archlinux
		;;
		"--post-install")
			echo; setup_postinstall_archlinux
		;;
		*)
			usage_archlinux
			return 127
		;;
	esac
}

usage_archlinux() {
echo
echo "Arch Linux Packages Install Script"
printf "SYNOPSIS: ./%s [options][-h] \n" "$(basename "$0")"
cat <<-'EOF'

Options:
    --repos                 Installing some Source code Repositories (GitHub, AUR, etc)
    --packages              Install a set of selected main packages you might want
    --display-server        Choose between XORG or Wayland with Weston
    --desktop-env           Choose between GNOME, KDE Plasma and XFCE
    --windows-manager       Choose between i3-gaps, DWM and Awesome
    --text-editors          Choose between Sublime Text and Visual Studio Code
    --uninstall-undesired   Uninstall some default packages you might not want
    --community             Download apps from a community-driven repository like TWMs,
                            DevApps, Browsers, etc
    --fonts                 Install nice Fonts from the package manager
    --post-install          Any action you want to do after the reboot, goes here, i.e.
                            install apps that are very slow to compile

    -h,--help               Show this menu

Execute '-post-install' when you have plenty of time to install this packages, because
they are slow as hell to compile.

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

isSudo

if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi



# ,xorg-server,"is the graphical server."
# ,xorg-xwininfo,"allows querying information about windows."
# ,xorg-xinit,"starts the graphical server."
# ,xorg-xprop,"is a tool for detecting window properties."
# ,xorg-xdpyinfo,"aids with resolution determination and screen recording."
# ,xorg-xbacklight,"enables changing screen brightness levels."
# ,xcompmgr,"is for transparency and removing screen-tearing."
# ,arandr,"visual front-end for xrandr. allows the user to customize monitor arrangements."

# ,xclip,"allows for copying and pasting from the command line."
# ,xcape,"gives the special escape/super mappings of LARBS."
# ,xwallpaper,"sets the wallpaper."
# ,maim,"can take quick screenshots at your request."
# ,slock,"allows you to lock your computer, and quickly unlock with your password."
# ,xdotool,"provides X window action utilities on the command line."
# ,sxiv,"is a minimalist X image viewer."
# ,unclutter-xfixes,"hides an inactive X mouse cursor."
