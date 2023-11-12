#!/bin/bash
#
# Homebrew Package Managee Install Script
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

install_homebrew() {
	## Check for Homebrew install
	if command -v brew > /dev/null 2>&1;
	then
		success "Looks like you already have Homebrew installed! Skipping" \
		"installation..."
		echo; return # 1
	fi

	## Check for Ruby install
	if ! command -v ruby > /dev/null 2>&1;
	then
		error "Ruby not found! Aborting..."
		echo; return
	fi

	enter_sudo_mode

	subopt "Installing Homebrew..."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
		error "Homebrew installation failed! Aborting..."
		echo; exit 1
	}

	success "Homebrew has been successfully installed!"
}

setup_brewfile_homebrew() {
	subopt "Installing your Packages (binaries, libraries) with Homebrew..."
	echo
	brew bundle -v "--file=$PUNTO_SH/programs/brew/Brewfile"
}

setup_appfile_homebrew() {
	subopt "Installing your Casks and MacAppStore apps with Homebrew..."

	echo; brew bundle -v "--file=$PUNTO_SH/programs/brew/Appfile"
}

setup_caskfile_homebrew() {
	subopt "Installing your Casks with Homebrew..."

	echo; brew bundle -v "--file=$PUNTO_SH/programs/brew/Caskfile"
}

setup_masfile_homebrew() {
	subopt "Installing your Mac App Store apps with MAS-CLI..."
	echo
	trdoptq "Before proceeding to install the Mac App Store apps, go to the app" \
	"store and sign in to your Apple account, when you finish, press anything" \
	"to proceed: "
	read -r proceed

	if [ -n $proceed ];
	then
		case "$(uname -r)" in
			2*)
				echo; brew bundle -v "--file=$PUNTO_SH/programs/brew/Masfile_macos11"
			;;
		esac

		echo; brew bundle -v "--file=$PUNTO_SH/programs/brew/Masfile"
	fi
}

setup_fontfile_homebrew() {
	subopt "Installing some nice Fonts with Homebrew..."
	echo
	brew bundle -v "--file=$PUNTO_SH/programs/brew/Fontfile"
}



# ==============================================================================

usage_homebrew() {
echo
echo "Homebrew Package Manager Install Script"
echo
printf "SYNOPSIS: ./%s [-a][-c][-f][-h][-i][-m][-p][-u] \n" "$(basename "$0")"
cat <<-'EOF'

OPTIONS:
    -i,--install       Download Homebrew at /<any_path>/homebrew
    -u,--update-path   Source file at PUNTO_SH/bin with the Homebrew prefix to keep
                       installing options at running time
    -p,--packages      Install Kegs (binaries, libraries)
    -a,--apps          Install Casks and Mac App Store apps (GUI apps)
    -c,--casks         Install only Casks (GUI apps)
    -m,--mas           Install only from Mac App Store (GUI apps)
    -f,--fonts         Install nice Fonts

    -h,--help          Show this menu

Note: all option-arguments are mutually exclusive.

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

main_homebrew() {
	case $1 in
		"-h"|"--help")
			usage_homebrew
		;;
		"-i"|"--install")
			echo; install_homebrew
		;;
		"-u"|"--update-path")
			echo; updatepath_homebrew
		;;
		"-p"|"--packages")
			echo
			setup_brewfile_homebrew

			brew cleanup
		;;
		"-a"|"--apps")
			echo
			setup_appfile_homebrew

			brew cleanup
		;;
		"-c"|"--casks")
			echo
			setup_caskfile_homebrew

			brew cleanup
		;;
		"-m"|"--mas")
			echo
			setup_masfile_homebrew

			brew cleanup
		;;
		"-f"|"--fonts")
			echo
			setup_fontfile_homebrew

			brew cleanup
		;;
		*)
			usage_homebrew
		;;
	esac
}

isMacos

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

main_homebrew "$@"
