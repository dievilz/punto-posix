#!/bin/zsh
#
# Z Shell Helper Script
# This script do everything related to ZSH configuration, including the installation of frameworks and plugin managers
#
# It's a shameless ripoff of the Oh-My-Zsh install script, and yes, I'm proud of it :v
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)


## Exporting PUNTO_SH location to source helper functions
PUNTO_SH="$(realpath "$0" | grep -Eo '^.*?\.punto-sh')" ## -o: only matching
. "$PUNTO_SH/src/functions/helpers.sh" || {
	printf "%b\n\n" "\033[38;31mError: helper functions not found! Aborting...\033[0m"
	echo; exit 1
}


usage() {
echo
echo "Z shell Helper Script"
echo "This script do everything related to ZSH configuration, including the installation of frameworks and plugin managers"
echo "It's a shameless ripoff of the Oh-My-Zsh install script, and I'm proud of it :v"
printf "Usage: ./%s <option> \n" "$(basename "$0")"
cat <<-'EOF'

Options:
    frameworks              Setup the Z shell with a ZSH framework. Choose between the following:
       --omz                    Install the Oh-My-Zsh framework
       --prezto                 Install the Prezto framework
    plgmanager              Setup the Z shell with a ZSH plugin manager. Choose between the following:
       --zgen                   Download ZGen to manage ZSH plugins
       --zplugin                Download ZPlugin to manage ZSH plugins
       --zplug                  Download ZPlug to manage ZSH plugins
    vanilla                 Setup the Z shell with a Pure/Vanilla ZSH experience
    zshrc                   Setup and manage the .zshrc file. Choose between the following options:
       --install                Remove a previous zshrc in $HOME and replace it for an available zshrc file in this dotfiles project
       --uninstall              Uninstall the current zshrc in $HOME and replace it for the previous one or a default one
     themes                  Choose from a variety of ZSH themes to use with Oh-My-Zsh or a Vanilla ZSH experience
        --omz                   Use this argument if you want to symlink the themes in the Oh-My-Zsh custom themes folder

    -h,--help          Show this menu

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

# Default settings
ZSH=${ZSH:-$HOME/.oh-my-zsh}
ZSH_CUSTOM=${ZSH_CUSTOM:-${ZSH}/custom}
REPO=${REPO:-robbyrussell/oh-my-zsh}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

# Other options
OHMYZSH=${OHMYZSH:-yes}
ZSHRC=${ZSHRC:-yes}
CHSH=${CHSH:-yes}
RUNZSH=${RUNZSH:-yes}


############################# OH-MY-ZSH FUNCTIONS ##############################

setup_ohmyzsh() {
	# Skip setup if the user wants
	if [ "$OHMYZSH" = no ]; then
		return
	fi

	# Prevent the cloned repository from having insecure permissions.
	umask g-w,o-w

	info "Cloning Oh-My-Zsh..."

	command -v git > /dev/null 2>&1 || {
		error "Git is not installed!"
		echo; exit 1
	}

	ostype=$(uname)
	if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -q msysgit; then
		error "Windows/MSYS Git is not supported on Cygwin!"
		error "Make sure the Cygwin git package is installed and is first on the \$PATH."
		echo; exit 1
	fi

	git clone -c core.eol=lf -c core.autocrlf=input \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch "$BRANCH" "$REMOTE" "$ZSH" || {
		error "Git clone of Oh-My-Zsh repo failed!"
		echo; exit 1
	}

	echo
}

process_zshrc() {
	# Must use this exact name so uninstall.sh can find it
	OLD_ZSHRC="$HOME/.zshrc.pre-oh-my-zsh"

	if [ -f "$OLD_ZSHRC" ] || [ -h "$OLD_ZSHRC" ]; then
		OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
		echo; warn "Found old ~/.zshrc.pre-oh-my-zsh. Renaming to ${OLD_OLD_ZSHRC}"

		success "Moving it to ~/Documents"
		mv -v "$OLD_ZSHRC" "$HOME/Documents/${OLD_OLD_ZSHRC}"

	elif [ -f "$HOME/.zshrc" ] || [ -h "$HOME/.zshrc" ]; then
		echo; warn "Found ~/.zshrc. Renaming to previous.zshrc"

		success "Moving it to ~/Documents"
		mv -v "$HOME/.zshrc" "$HOME/Documents/previous.zshrc"
	fi
	echo
}

setup_zshrc() {
	# Skip setup if the user wants or stdin is closed (not running interactively).
	if [ "$ZSHRC" = no ]; then
		return
	fi

	# Keep most recent old .zshrc at .zshrc.pre-oh-my-zsh, and older ones
	# with datestamp of installation that moved them aside, so we never actually
	# destroy a user's original zshrc
	info "Looking for an existing zsh config..."

	process_zshrc

	green "Installing the main file: .zshrc"

	echo; subopt "Which zshrc option do you want to use?"
	blue "${BB}Template: ${RE}${B}the OMZ zshrc template or ${BB}Custom: ${RE}${B}a personalized OMZ zshrc with my preferred plugins, themes and configs."
	read -r -p "${SOA} ['template','custom']: ${RE}" resp

	echo; zshrc_case "$resp"
}

setup_chsh() {
	# Skip setup if the user wants or stdin is closed (not running interactively).
	if [ "$CHSH" = no ]; then
		return
	fi

	# If this user's login shell is already "zsh", do not attempt to switch.
	if [ -z "$(ps -p $$ | egrep -m 1 -q '\b(zsh)')" ]; then
		echo; return
	fi

	# If this platform doesn't provide a "chsh" command, bail out.
	if ! command -v chsh > /dev/null 2>&1;
	then
		error "I can't change your shell automatically because this system does not have chsh!"
		warn "Please manually change your default shell to zsh."
		echo; return
	fi

	info "Time to change your default shell to zsh!"

	# Prompt for user choice on changing the default login shell
	read -r -p "${Y}Do you want to change your default shell to zsh? [Y/n]: ${RE}" opt
	echo
	case "$opt" in
		y*|Y*|"") green "Changing the shell..." ;;
		n*|N*|"skip") yellow "Shell change skipped."; return ;;
		*) red "Invalid choice! Shell change skipped."; return ;;
	esac

	# Test for the right location of the "shells" file
	if [ -f /etc/shells ]; then
		shells_file=/etc/shells
	elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
		shells_file=/usr/share/defaults/etc/shells
	else
		error "Could not find /etc/shells file! Change your default shell manually."
		echo; return
	fi

	# Get the path to the right zsh binary
	# 1. Use a Zsh downloaded at /usr/local/bin, i.e. Brew Zsh
	# 2. Use the most preceding one based on $PATH, then check that it's in the shells file
	# 3. If that fails, get a zsh path from the shells file, then check it actually exists
	if [ ! -e /usr/local/bin/zsh ]; then
		if ! zsh=$(command -v zsh) || ! grep -qx "$zsh" "$shells_file" ; then
			if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -1) || [ ! -f "$zsh" ]; then
				error "No zsh binary found or not present in '$shells_file'!"
				error "Change your default shell manually."
				echo; return
			fi
		fi
	else
		zsh="/usr/local/bin/zsh"
	fi

	# # We're going to change the default shell, so back up the current one
	# if [ -n "$SHELL" ]; then
	# 	echo "$SHELL" > "$HOME/.shell.pre-oh-my-zsh"
	# else
	# 	grep "^$USER:" /etc/passwd | awk -F: '{print $7}' > "$HOME/.shell.pre-oh-my-zsh"
	# fi

	# Actually change the default shell to zsh
	if ! chsh -s "$zsh" ; then
		error "Chsh command unsuccessful! Change your default shell manually."
	else
		export SHELL="$zsh"
		success "Shell successfully changed to '$zsh'!"
	fi

	echo
}


############################### ZSHRC FUNCTIONS ################################

install_zshrc() {
	option "Installing Zshrc. Looking for an existing zsh config first..."
	process_zshrc

	subopt "Which zshrc option do you want to use?"

	info "The first three ones are for the plugin managers supported for this dotfiles."
	blue "${BB}OMZ Template: ${RE}${B}the OMZ zshrc template; ${BB}OMZ Custom: ${RE}${B}a personalized OMZ zshrc with my preferred plugins, themes and configs; ${BB}Default: ${RE}${B}a custom default zshrc for a Vanilla ZSH experience"
	read -r -p "${SOA} ['zgen','zplugin','zplug','omztemp','omzcustom','default']: ${RE}" resp

	echo; zshrc_case "$resp"
}

zshrc_case() {
	case "$1" in
		"omztemp" | "template" | "t")
			green "Using the Oh-My-Zsh template file as ~/.zshrc."
			echo
			cp "$ZSH/templates/zshrc.zsh-template" "$HOME/.zshrc"
			sed "/^export ZSH=/ c\\
			export ZSH=\"$ZSH\"
			\"$HOME\"/.zshrc" > "$HOME/.zshrc-omztemp"
			mv -f "$HOME/.zshrc"-omztemp "$HOME/.zshrc"
		;;
		"omzcustom" | "custom" | "omz")
			green "Using my own custom Oh-My-Zsh zshrc as ~/.zshrc."
			echo
			ln -fsv "$DOTFILES/home/config/zsh/plugin-managers/omz.zshrc" "$HOME/.zshrc"
		;;
		"zgen")
			green "Using a custom ZGen plugin manager zshrc as ~/.zshrc."
			echo
			ln -fsv "$DOTFILES/home/config/zsh/plugin-managers/zgen.zshrc" "$HOME/.zshrc"
		;;
		"zplugin")
			green "Using a custom ZPlugin plugin manager zshrc as ~/.zshrc."
			echo
			ln -fsv "$DOTFILES/home/config/zsh/plugin-managers/zplugin.zshrc" "$HOME/.zshrc"
		;;
		"zplug")
			green "Using a custom ZPlug plugin manager zshrc as ~/.zshrc."
			echo
			ln -fsv "$DOTFILES/home/config/zsh/plugin-managers/zplug.zshrc" "$HOME/.zshrc"
		;;
		"default")
			green "Using a custom default zshrc for a Vanilla ZSH experience as ~/.zshrc."
			case "$(id -u)" in
				0)
				ln -fsv "$DOTFILES/home/config/zsh/root.zshrc" "/root/.config/zsh/default.zshrc"
				;;
				*)
				ln -fsv "$DOTFILES/home/config/zsh/user.zshrc" "$ZDOTDIR/default.zshrc"
				;;
			esac
		;;
		"skip"|"none")   # ╭─❯ Pero lo dejaré por si las dudas :v
			warn "Skipping this step!"
		;;
		"" | *)   # Este paso no deberia saltarse, porque no se puede dejar $ZDOTDIR sin .zshrc
			error "You have to choose one zshrc to use with the Z shell"
			echo; install_zshrc
		;;
	esac
	echo
}

uninstall_zshrc() {
	info "Looking for original zsh config..."

	unset -v ORIG_ZSHRC
	for zshrc in $(find "$HOME/Documents" -maxdepth 1 -name "*zshrc*" -type f); do
		if [ -z "$ORIG_ZSHRC" ] || [ "$zshrc" -nt "$ORIG_ZSHRC" ]; then
			ORIG_ZSHRC=$zshrc
		fi
	done
	echo "$ORIG_ZSHRC"

	if [ -n "$ORIG_ZSHRC" ]; then
		warn "Found $ORIG_ZSHRC -- Restoring to ~/.zshrc"

	elif [ -d /etc/skel ]; then
		warn "Don't found an original .zshrc at ~/Documents -- Restoring from /etc/skel/"

		ORIG_ZSHRC=/etc/skel/.zshrc

	elif [ -f "$DOTFILES/home/config/zsh/default.zshrc" ]; then
		warn "Don't found an original .zshrc at ~/Documents -- Restoring from $DOTFILES/home/config/zsh/default.zshrc"

		ORIG_ZSHRC="$DOTFILES/home/config/zsh/default.zshrc"
	else
		error "${RE}Original .zshrc at ~/Documents not found -- Other possible options not found either. Process failed successfully xD"
		echo; exit 1
	fi

	if [ -e "$HOME/.zshrc" ]; then
		ZSHRC_SAVE="$HOME/.zshrc.dievilz-dotfiles-uninstalled-$(date +%Y-%m-%d_%H-%M-%S)"
		echo; warn "Found zshrc at $HOME -- Renaming to ${ZSHRC_SAVE}"
		mv "$HOME/.zshrc" "${ZSHRC_SAVE}"
	fi

	mv "$ORIG_ZSHRC" "$HOME/.zshrc"

	echo; success "Your original zsh config was restored. Or at least, a default zsh config was restored xD"

	echo
}


############################## ZSH CUSTOM THEMES ###############################

download_zsh_themes() {
	local T_ZSH=${T_ZSH:-$HOME/.zsh/themes}
	local T_REPO
	local T_REMOTE
	local T_BRANCH=${T_BRANCH:-master}
	info "Installing ZSH custom themes"
	read -r -p "${SOA} Choose one option ['powerlevel9k','powerlevel10k','spaceship','geometry','hyperzsh','all','none']: ${RE}" theme
	echo

	case "$theme" in
		"powerlevel9k" | "powerlevel10k" | "spaceship" | "hyperzsh" | "geometry")
			if [ ! -d "$T_ZSH/$theme" ]; then
				info "Installing the $theme ZSH theme"

				case "$theme" in
					"powerlevel9k") T_REPO="Powerlevel9k/${theme}";;
					"powerlevel10k") T_REPO="romkatv/${theme}";;
					"spaceship") T_REPO="denysdovhan/${theme}-prompt";;
					"geometry") T_REPO="${theme}-zsh/${theme}";;
					"hyperzsh") T_REPO="tylerreckart/${theme}";;
				esac

				# T_REMOTE=${T_REMOTE:-https://github.com/${T_REPO}.git}
				T_REMOTE=${T_REMOTE:-git@github.com:${T_REPO}.git}

				yellow "The remote repository is: $T_REMOTE"

				git clone --depth=1 --branch "$T_BRANCH" "$T_REMOTE" "$T_ZSH/${theme}" || {
					error "Git clone of ${T_REPO} theme failed!"
					echo; exit 1
				}

				success "$theme ZSH custom theme succesfully installed!"
			else
				warn "You already have the $theme ZSH theme installed!"
			fi

			if [ "$1" = "omz" ]; then
				if [ ! -d "$ZSH_CUSTOM/themes/$theme" ]; then
					mkdir "$ZSH_CUSTOM/themes/$theme"
				fi
				echo; info "Linking $theme ZSH theme into the Oh-My-Zsh custom/themes folder"
				ln -fsv "$T_ZSH/$theme/$theme.zsh-theme" "$ZSH_CUSTOM/themes/$theme/$theme.zsh-theme"
			fi
		;;
		"all")
			## declare an array variable
			declare -a themeArr=("Powerlevel9k/powerlevel9k" "romkatv/powerlevel10k" "denysdovhan/spaceship-prompt" "geometry-zsh/geometry" "tylerreckart/hyperzsh")

			## now loop through the above array
			for T_REPO in "${themeArr[@]}"; do

				themeName=$(echo $T_REPO | cut -d'/' -f 2)
				if [ "$themeName" = "spaceship-prompt" ]; then
					themeName="spaceship"
				fi

				if [ ! -d "$T_ZSH/$themeName" ]; then

					info "Installing the $T_REPO ZSH theme"

					# T_REMOTE=${T_REMOTE:-https://github.com/${T_REPO}.git}
					T_REMOTE=${T_REMOTE:-git@github.com:${T_REPO}.git}

					yellow "The remote repository is: $T_REMOTE"

					git clone --depth=1 --branch "$T_BRANCH" "$T_REMOTE" "$T_ZSH/${themeName}" || {
						error "Git clone of ${T_REPO} theme failed!"
						echo; exit 1
					}

					themeName=
					T_REPO=
					T_REMOTE=
					themesInstalled=true
				else
					warn "You already have the $themeName ZSH theme installed!"
					themesInstalled=false
				fi

				if [ "$1" = "omz" ]; then
					if [ ! -d "$ZSH_CUSTOM/themes/$themeName" ]; then
						mkdir "$ZSH_CUSTOM/themes/$themeName"
					fi
					echo; info "Linking $themeName ZSH theme into the Oh-My-Zsh custom/themes folder"
					ln -fsv "$T_ZSH/$themeName/$themeName.zsh-theme" "$ZSH_CUSTOM/themes/$themeName/$themeName.zsh-theme"
				fi
				echo
			done

			if [ "$themesInstalled" = "true" ]; then
				success "ZSH custom themes succesfully installed!"
			fi

			themesInstalled=
		;;
		n*|N*|"skip")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}


############################### PLUGIN MANAGERS ################################

install_zgen() {
	if [ ! -d "$HOME"/.zgen ]; then
		option "Downloading ZGen plugin manager"

		git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen" || {
			error "Git clone of ZGen failed! Aborting..."
			echo; exit 126
		}

		zshrc_case zgen

		setup_chsh
	else
		warn "You already have ZGen installed!"
	fi
	echo
}

install_zinit() {
	if [ ! -d "$HOME"/.zplugin ]; then
		option "Downloading ZPlugin plugin manager"

		zsh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)" || {
			error "Git clone of ZPlugin failed! Aborting..."
			echo; exit 126
		}

		zshrc_case zplugin

		setup_chsh
	else
		warn "You already have ZPlugin installed!"
	fi
	echo
}

install_zplug() {
	if [ ! -d "$HOME"/.zplug ]; then
		option "Downloading ZPlug plugin manager"

		curl -sL --proto-redir -all, \
		https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh || {
			error "Git clone of ZPlug failed! Aborting..."
			echo; exit 126
		}

		zshrc_case zplug

		setup_chsh
	else
		warn "You already have ZPlug installed!"
	fi
	echo
}

install_omz() {
	echo

	if ! command -v zsh > /dev/null 2>&1; then
		error "Zsh is not installed! Please install zsh first."
		echo; exit 1
	fi

	if [ -d "$ZSH" ]; then
		error "You already have Oh My Zsh installed!"
		warn "You'll need to remove '$ZSH' if you want to reinstall."
		echo; exit 1
	fi

	# Run as unattended if stdin is closed
	if [ ! -t 0 ]; then
		CHSH=no
		RUNZSH=no
	fi

	# Parse arguments
	while [ "$#" -gt 0 ]; do
		case $1 in
			"--unattended") CHSH=no; RUNZSH=no
			;;
			"--skip-chsh") CHSH=no
			;;
		esac
		shift
	done

	setup_ohmyzsh
	setup_zshrc
	setup_chsh
	download_zsh_themes omz

	printf "%s" "$G"
	cat <<-'EOF'
		         __                                     __
		  ____  / /_     ____ ___  __  __   ____  _____/ /_
		 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
		/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
		\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
		                        /____/                       ....is now installed!

		Please look over the $HOME/.zshrc file to select plugins, themes, and options.

		p.s. Follow us on https://twitter.com/ohmyzsh

		p.p.s. Get stickers, shirts, and coffee mugs at https://shop.planetargon.com/collections/oh-my-zsh

	EOF
	printf "%s" "$RE"

	# if [ "$RUNZSH" = no ]; then
		success "When you have finished your Shell-Utils Install, run a new Terminal window to try OMZ out!"
	# 	echo; return
	# fi

	# exec zsh -l
}

main() {
	case $1 in
		"-h"|"--help")
			usage
			exit 0
		;;
		"frameworks")
			case $2 in
				"--omz")
					echo; install_omz
				;;
				"--prezto")
					# echo; install_prezto
				;;
				*)
					usage
					return 127
				;;
			esac
		;;
		"plgmanager")
			case $2 in
				"--zgen")
					echo; install_zgen
				;;
				"--zplugin")
					echo; install_zinit
				;;
				"--zplug")
					echo; install_zplug
				;;
				*)
					usage
					return 127
				;;
			esac
		;;
		"vanilla")
			case $2 in
				"")
					echo
					zshrc_case default
					setup_chsh
					download_zsh_themes
				;;
				*)
					usage
					return 127
				;;
			esac
		;;
		"zshrc")
			case $2 in
				"--install" | "")
					echo; install_zshrc
				;;
				"--uninstall")
					echo; uninstall_zshrc
				;;
				*)
					usage
					return 127
				;;
			esac
		;;
		"themes")
			case $2 in
				"omz")
					echo; download_zsh_themes omz
				;;
				"")
					echo; download_zsh_themes
				;;
				*)
					usage
					return 127
				;;
			esac
		;;
		*)
			usage
			return 127
		;;
	esac
}

main "$@"; exit


# git clone https://github.com/zdharma-continuum/fast-syntax-highlighting /opt/zsh/plugins/fast-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-history-substring-search /opt/zsh/plugins/zsh-history-substring-search
# git clone https://github.com/zsh-users/zsh-autosuggestions /opt/zsh/plugins/zsh-autosuggestions
