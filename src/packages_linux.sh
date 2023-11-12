#!/bin/bash
#
# Linux Packages Install Script
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

############################# LINUX-INSTALLATION ###############################

install_in_linux() {
	case "$DISTRO" in
		"Arch"|"Manjaro")
			source "$PUNTO_SH"/scripts/archlinux.sh && main_archlinux "$@"
		;;
		"Debian")
			source "$PUNTO_SH"/scripts/debian.sh && main_debian "$@"
		;;
		"Ubuntu")
			source "$PUNTO_SH"/scripts/ubuntu.sh && main_ubuntu "$@"
		;;
		*)
			error "${DISTRO} not supported! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}

setup_linux_repos() {
	option "Installing some Source code Repositories (GitHub, AUR-like, etc)"
	suboptq "Ready to install these main packages? [${BO}'Y'${NBO}|${BO}'n'" \
	"${NBO}|press ${BO}Enter key${NBO} to halt]: "
	read -r resp
	echo
	case "$resp" in
		y|Y|yes|Yes)
			install_in_linux --repos
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_packages() {
	option "Installing Packages from the Distro's package manager"
	suboptq "Ready to install these main packages? [${BO}'Y'${NBO}|${BO}'n'" \
	"${NBO}|press ${BO}Enter key${NBO} to halt]: "
	read -r resp
	echo
	case "$resp" in
		y|Y|yes|Yes)
			install_in_linux --packages
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_displayserver() {
	option "Installing a Display Server"
	suboptq "Choose one option ['xorg'|'wayland'|'all'|'none',press Enter key to halt]: "
	read -r resp
	echo
	case "$resp" in
		"xorg"|"wayland"|"all")
			install_in_linux --display-server
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_desktopenv() {
	option "Installing Desktop Environments & Display Manager"
	subopt "The choosen D.E. will be installed with their respective Display Manager"
	suboptq "Choose one option ['gnome'|'kde'|'xfce'|'all'|'none',press Enter key to halt]: "
	read -r resp
	echo
	case "$resp" in
		"gnome"|"kde"|"xfce"|"all"|"")
			install_in_linux --desktop-env
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_windowsmanager() {
	option "Installing Windows Managers"
	suboptq "Choose one option ['i3-gaps'|'dwm'|'awesome'|'all'|'none',press Enter key to halt]: "
	read -r resp
	echo
	case "$resp" in
		"i3-gaps"|"dwm"|"awesome"|"all")
			install_in_linux --windows-manager
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_texteditors() {
	option "Installing Text Editors"
	suboptq "Choose one option ['sublime'|'vscode'|'all'|'none',press Enter key to halt]: "
	read -r resp
	echo
	case "$resp" in
		"sublime"|"vscode"|"all"|"")
			install_in_linux --text-editors
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
uninstall_linux_undesired() {
	option "Uninstalling Undesired default packages"
	suboptq "Ready to uninstall these default packages? [${BO}'Y'${NBO}|${BO}'n'${NBO}|press ${BO}Enter key${NBO} to halt]: "
	read -r resp
	echo
	case "$resp" in
		y|Y|yes|Yes)
			install_in_linux --uninstall-undesired
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_community() {
	option "Setting up Community-mantained packages"
	suboptq "Ready to install these selected packages? [${BO}'Y'${NBO}|${BO}'n'${NBO}|press ${BO}Enter key${NBO} to halt]: "
	read -r resp
	echo
	case "$resp" in
		y|Y|yes|Yes)
			install_in_linux --community
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_fonts() {
	option "Installing some nice Fonts from the Package Manager"
	suboptq "Ready to install these selected fonts packages? [Y/n]"
	read -r resp
	echo
	case "$resp" in
		y|Y|yes|Yes)
			install_in_linux --fonts
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}
setup_linux_postinstall() {
	option "Setting up Post-Install actions..."
	subopt "The following packages may take a really long time to be installed."
	suboptq "So, are you ready to install them? [${BO}'Y'${NBO}|${BO}'n'${NBO}|press ${BO}Enter key${NBO} to halt]: "
	read -r resp
	echo
	case "$resp" in
		y|Y|yes|Yes)
			install_in_linux --post-install
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}


# ==============================================================================

usage_linuxpackages() {
echo
echo "Linux Packages Install Script"
echo "Parent script to install Linux Package Managers via other scripts."
echo
printf "SYNOPSIS: ./%s [options][-h] \n" "$(basename "$0")"
cat <<-'EOF'

OPTIONS:
    --repos                 Installing some Source code Repositories (GitHub, AUR, etc)
    --packages              Install packages from the respective package manager
    --display-server        Choose between XORG or Wayland with Weston
    --desktop-env           Choose between GNOME, KDE Plasma and XFCE
    --windows-manager       Choose between i3-gaps, DWM and Awesome
    --text-editors          Choose between Sublime Text and Visual Studio Code
    --uninstall-undesired   Uninstall some default packages you might not want
    --community             Download apps from a community-driven repository
    --fonts                 Install nice Fonts from the package manager
    --post-install          Any action you want to do after the reboot, goes here, i.e.
                            install apps that are very slow to compile

    -h,--help               Show this menu

If you need more help. refer to the usage menu of every package manager script.
(archlinux.sh)

Execute argument '--post-install' only when the Bootstrap Script have finished, by runnning the following command: 'bootstrap.sh final'. Go to the help section of bootstrap.sh for more information.

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

menu_linuxpackages() {
	case $1 in
		"-h"|"--help")
			usage_linuxpackages
			exit 0
		;;
		"--repos")
			echo; setup_linux_repos
		;;
		"--packages")
			echo; setup_linux_packages
		;;
		"--display-server")
			echo; setup_linux_displayserver
		;;
		"--desktop-env")
			echo; setup_linux_desktopenv
		;;
		"--windows-manager")
			echo; setup_linux_windowsmanager
		;;
		"--text-editors")
			echo; setup_linux_texteditors
		;;
		"--uninstall-undesired")
			echo; uninstall_linux_undesired
		;;
		"--community")
			echo; setup_linux_community
		;;
		"--fonts")
			echo; setup_linux_fonts
		;;
		"--post-install")
			echo; setup_linux_postinstall
		;;
		*)
			error "Unknown option! Use -h/--help"
			return 127
		;;
	esac
}

main_case_linuxpackages() {
	echo
	option "We are going to install a concept one by one."
	until false;
	do
		echo
		subopt "Below are the options:"
		usage_linuxpackages

		subopt "Choose one option from the usage..."
		subopt "[${BO}'skip'${NBO}|${BO}'none'${NBO}][press ${BO}Enter key${NBO}] to halt"
		suboptq "" && read -r conceptToInstall

		case "$conceptToInstall" in
			n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
				warn "Skipping this step!"
				return 1
				break
			;;
			*) menu_linuxpackages "$conceptToInstall"
			;;
		esac
	done
}

main_linuxpackages() {
	if [ "$#" -eq 0 ];
	then
		main_case_linuxpackages
	else
		menu_linuxpackages "$@"
	fi

	[ $? -eq 0 ] && success "${DISTRO} packages successfully installed!"
	[ $? -eq 0 ] && warn "Execute '--post-install' when you have finished Bootstrapping"
	echo
}

isDistro

## Exporting PUNTO_SH path and source helper functions so the script can work
PUNTO_SH="$(realpath "$0" | grep -Eo '^.*?punto-sh')" ## -o: only matching

if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi

main_linuxpackages "$@"; exit
