#!/bin/bash
#
# ASDF Version Manager Script.
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

################################### INSTALL ####################################

install_homebrew() {
	ASDF_DIR="/opt/asdf-vm"
	ASDF_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/asdf"

	## Check for ASDF install
	if command -v asdf > /dev/null 2>&1;
	then
		success "Looks like you already have ASDF installed! Skipping" \
		"installation..."
		echo; return # 1
	fi

	## Check for curl install
	if ! command -v curl > /dev/null 2>&1;
	then
		error "curl not found! Aborting..."
		echo; return # 1
	fi

	## Check for git install
	if ! command -v git > /dev/null 2>&1;
	then
		error "git not found! Aborting..."
		echo; return # 1
	fi

	enter_sudo_mode

	option "Cloning Homebrew..."

	trdopt "Type the absolute path prefix (including final folder name) where" \
	"you want to place the binaries (i.e. $ASDF_DIR)."
	trdopt "Please don't use spaces in the path. ASDF itself can handle" \
	"them, but many build scripts cannot."
	trdoptq "(To halt, press Enter key): "

	until false;
	do
		read -r ASDF_DIR
		case $ASDF_DIR in
			"/"|"/tmp"|"/sw"|"/opt/local"|*"brew"*|"/opt/pkg"|"/usr/local")
				error "Invalid directory: it is used by another package manager" \
				"or I dont't want anyone to use them. Try again..."
				echo; frtoptq "Enter a new prefix: "
			;;
			"/"*)
				# if [ ! -d "$(dirname "$ASDF_DIR")" ];
				if [ ! -d "$ASDF_DIR" ];
				then
					if [ ! -d "$(dirname "$ASDF_DIR")" ];
					then
						mkdir -pv "$ASDF_DIR" || {
							error "The path entered is invalid! Try again..."
							echo; frtoptq "Enter a new prefix: "
							continue
						}
					fi

					if [ -w "$(dirname "$ASDF_DIR")" ];
					then
						drror "The path entered is unwritable! Try again..."
						echo; frtoptq "Enter a new prefix: "
						continue
					fi

					true

				else
					error "Invalid directory: it is used by another program. Try again..."
					echo; frtoptq "Enter a new prefix: "
					continue
				fi
				true
			;;
			"")
				error "Skipping installation..."
				echo; return 0
			;;
			*)
				error "Invalid choice! Aborting..."
				echo; return 1
			;;
		esac
	done
	echo

	saferun git clone -c core.eol=lf -c core.autocrlf=input \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		-c punto.sh.remote=origin \
		-c punto.sh.branch="$BRANCH" \
		--depth=1 --branch "$BRANCH" "$REMOTE" "$PUNTO_SH" || {
		printf "%b\n" "${R}==> Error: Git clone of Punto Dotfiles Manager failed! Aborting...${RE}" 1>&2
		echo; exit 1
	}

	git clone https://github.com/asdf-vm/asdf.git || {
		error "ASDF installation failed! Aborting..."
		echo; exit 1
	}

	success "Homebrew has been successfully installed!"
}


################################## UNINSTALL ###################################

uninstall() {
	bash "$PUNTO_SH"/uninstall.sh
}


# ==============================================================================

usage_bootstrap() {
echo
echo "Punto Dotfiles Manager Bootstrap Script"
echo
printf "SYNOPSIS: ./%s [-a][-f][-h][-i][-n][-s] [--args] \n" "$(basename "$0")"
printf "./%s [--fresh-install [defaults|packages|dotfiles|asdf]] \n" "$(basename "$0")"
printf "./%s [--shell-utils [git|vim|emacs|zsh]] \n" "$(basename "$0")"
printf "./%s [--after-reboot [node|python|ruby]] \n" "$(basename "$0")"
printf "./%s [--final-part [text-editors|post-install|frameworks|localhost]] \n" "$(basename "$0")"
printf "./%s [--nuke] \n" "$(basename "$0")"
printf "./%s [--help] \n" "$(basename "$0")"
cat <<-'EOF'

OPTIONS:
	 -i,--install   Download ASDF Version Manager at any location
	 -p,--plugin

	 -n,--nuke      You'll only be warned one time before fucking this shit up (uninstall c:)
	 -h,--help      Show this menu

s
Note: all options are mutually exclusive, and the options run all of their arguments in the order listed above.

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

main_bootstrap() {
	case "$1" in
		"-h" |"--help")
			usage_bootstrap
			exit 0
		;;
		"-i"|"--fresh-install")
			case "$2" in
				"defaults")
					echo; setup_defaults --basic
				;;
				"packages")
					echo; setup_packages
				;;
				"dotfiles")
					echo; sync_dotfiles
				;;
				"asdf")
					echo; setup_asdf
				;;
				"")
					echo; bold "${B}–--> Welcome to the Fresh-Install part of the Bootstrap Script!"

					enter_sudo_mode

					setup_defaults --basic
					setup_packages
					sync_dotfiles
					setup_asdf

					[ $? -eq 0 ] && bold "Finished! Your machine now has installed some things for a little bit of own-customization"
					[ $? -eq 0 ] && bold "Open a new terminal, cd to $PUNTO_SH and execute './bootstrap.sh -s OR --shell-utils'"
					echo
				;;
				*)
					error "Unknown option! Use -h/--help"
					return 127
				;;
			esac
		;;
		"-s"|"--shell-utils")
			case "$2" in
				"git")
					echo; setup_git
				;;
				"vim")
					echo; setup_vim
				;;
				"emacs")
					echo; setup_emacs
				;;
				"zsh")
					echo; setup_zsh
				;;
				"")
					echo; bold "Welcome to the Shell Utilities Installation part of the Bootstrap Script!"

					enter_sudo_mode

					setup_git
					setup_vim
					setup_emacs
					setup_zsh

					[ $? -eq 0 ] && bold "Finished! Your machine's configuration is halfway done e.e"
					[ $? -eq 0 ] && bold "Reboot, Open a new terminal, cd to $PUNTO_SH and execute ./bootstrap.sh -a OR --after-reboot'"
					echo
				;;
				*)
					error "Unknown option! Use -h/--help"
					return 127
				;;
			esac
		;;
		"-a"|"--after-reboot")
			case "$2" in
				"deno")
					echo; setup_deno_install
				;;
				"python")
					echo; setup_python_install
				;;
				"")
					echo; bold "Welcome to the After-Reboot part of the Bootstrap Script"

					enter_sudo_mode

					setup_deno_install
					setup_python_install

					[ $? -eq 0 ] && bold "Finished! Your machine is almost ready to kick ass :D"
					[ $? -eq 0 ] && bold "Open a new terminal, cd to $PUNTO_SH and execute ./bootstrap.sh -f OR --final-part'"
					echo
				;;
				*)
					error "Unknown option! Use -h/--help"
					return 127
				;;
			esac
		;;
		"-f"|"--final-part")
			case "$2" in
				"defaults")
					echo; setup_defaults_postinstall
				;;
				"text-editors")
					echo; setup_sync_texteditors
				;;
				"post-install")
					echo; setup_packages_postinstall
				;;
				"frameworks")
					echo; setup_frameworks
				;;
				"localhost")
					echo; setup_localhost
				;;
				"")
					echo; bold "Welcome to the Final Part of the Bootstrap Script"

					enter_sudo_mode

					setup_defaults_postinstall
					setup_sync_texteditors
					setup_packages_postinstall
					setup_frameworks
					setup_localhost

					[ $? -eq 0 ] && bold "Finished! Now your machine is ready to go! A reboot never hurts anyone ;)"

					echo; fortune | cowsay | lolcat ;echo
				;;
				*)
					error "Unknown option! Use -h/--help"
					return 127
				;;
			esac
		;;
		"-n"|"--nuke")
			echo; uninstall
		;;
		*)
			error "Unknown option! Use -h/--help"
			return 127
		;;
	esac
}

if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi

main_bootstrap "$@"; exit
