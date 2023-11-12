#!/bin/bash
#
# Bootstrap Script.
# Main script for the correct management and deployment of this dotfiles project
# Influenced by @mavam's bootstrap script
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

############################################# BOOTSTRAP ############################################

################################ FRESH-INSTALL #################################

setup_defaults() \
{
	bold "${B}–--> Fresh Install: Setting up your Defaults..."

	case "$(uname -s)" in
		"Darwin")
			bash "$PUNTO_SH"/src/defaults_macos.sh --basic
		;;
		"Linux")
			case "$DISTRO" in
				"Arch"|"Manjaro")
					bash "$PUNTO_SH"/src/defaults_arch.sh --basic
				;;
				"Debian")
					bash "$PUNTO_SH"/src/defaults_debian.sh --basic
				;;
				"Ubuntu")
					bash "$PUNTO_SH"/src/defaults_ubuntu.sh --basic
				;;
			esac
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

setup_packages() \
{
	bold "${B}–--> Fresh Install: Setting up your Packages..."

	case "$(uname -s)" in
		"Darwin")
			bash "$PUNTO_SH"/src/packages_macos.sh
		;;
		"Linux")
			bash "$PUNTO_SH"/src/packages_linux.sh
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac

	echo
	[ $? -eq 0 ] && success "Packages successfully installed!"
	[ $? -eq 0 ] && warn "Execute '--post-install' when you have finished Bootstrapping"
	echo
	echo
}

sync_dotfiles() \
{
	verifyDotfilesFolder

	bold "${B}–--> Fresh Install: Setting up your Dotfiles..."
	echo

	option "Dotfiles: Syncing Files"
	bash "$DOTFILES"/sync.sh syml --dotfiles dirs
	bash "$DOTFILES"/sync.sh rsync --dotfiles bin
	bash "$DOTFILES"/sync.sh rsync --dotfiles etc
	bash "$DOTFILES"/sync.sh rsync --dotfiles pkg-etc
	bash "$DOTFILES"/sync.sh rsync --dotfiles opt
	bash "$DOTFILES"/sync.sh syml --dotfiles home
	bash "$DOTFILES"/sync.sh syml --dotfiles shell
	bash "$DOTFILES"/sync.sh syml --dotfiles config
	bash "$DOTFILES"/sync.sh rsync --dotfiles data
	bash "$DOTFILES"/sync.sh rsync --dotfiles homeopt

	[ $? -eq 0 ] && success "Dotfiles successfully synced!"

	bash "$DOTFILES"/sync.sh --text-editors stext-basic
	bash "$DOTFILES"/sync.sh --text-editors smerge
	bash "$DOTFILES"/sync.sh --text-editors vscodx
	bash "$DOTFILES"/sync.sh --preferences
	bash "$DOTFILES"/sync.sh --library

	echo
	[ $? -eq 0 ] && success "Dotfiles, basic Text Editors settings and Apps" \
	"preferences successfully synced!"
	[ $? -eq 0 ] && warn "Go Sync all your plugins and full settings on both" \
	"text editors if you use a plugin manager before executing the final part" \
	"of this Bootstrapping Installation"
	echo
}

setup_asdf() \
{
	bold "– Fresh Install: Setting up ASDF Version Manager for development" \
	"{tools, languages, etc}..."
	bash "$PUNTO_SH"/src/asdf.sh --install
}


############################### SHELL UTILITIES ################################

setup_git() \
{
	bash "$PUNTO_SH"/src/git.sh
}

setup_vim() \
{
	option "Setting up NeoVim Plugins via Vim-Plug"

	if [ ! -e "$XDG_CONFIG_HOME"/nvim/autoload/plug.vim ]; then
		subopt "Installing Vim-Plug plugin manager..."

		mkdir -pv "$XDG_CONFIG_HOME"/nvim/autoload/

		saferun curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || {
			error "Git clone of Vim-Plug failed! Aborting..."
			echo; exit 126
		}

		nvim +PlugUpdate +PlugClean! +qa
	else
		suboptq "Do you want to update NeoVim plugins? ['Y'|'n']: "
		read -r resp
		echo
		case "$resp" in
			y*|Y*|"")
				option "Upgrading NeoVim plugins"
				nvim -E -s +PlugUpgrade +qa ; nvim +PlugUpdate +PlugClean! +qa
			;;
			n*|N*|"skip")
				warn "Skipping this step!"
			;;
			*)
				error "Invalid choice! Aborting..."
				echo; exit 126
			;;
		esac
	fi
	echo
}

setup_emacs() \
{
	option "Setting up an Emacs \"${IT}bootloader${NBO}\" ${BO}with Chemacs2"

	if [ -f "$XDG_CONFIG_HOME"/emacs/chemacs.el ];
	then
		saferun curl -o "$XDG_CONFIG_HOME"/emacs/chemacs.el \
		https://raw.githubusercontent.com/plexus/chemacs2/master/chemacs.el
	fi
}

setup_zsh() \
{
	option "Setting up the Z-Shell"
	echo
	subopt "Installing a ZSH Framework/Plugin Manager..."
	blue "If you want a Pure/Vanilla ZSH experience, type 'vanilla'"
	blue "If you don't want to use the Z-Shell, type 'none'"
	echo
	suboptq "Choose one option ['omz','prezto','zgen','zplugin','zplug'," \
	"'vanilla','skip/none/Enter' to halt]: "
	read -r resp
	case "$resp" in
		"omz")
			echo; bash "$PUNTO_SH"/src/zshell.sh frameworks --omz
		;;
		"prezto")
			# echo; bash "$PUNTO_SH"/src/zshell.sh frameworks --prezto
		;;
		"zplugin")
			echo; bash "$PUNTO_SH"/src/zshell.sh plgmanager --zgen
		;;
		"zgen")
			echo; bash "$PUNTO_SH"/src/zshell.sh plgmanager --zplugin
		;;
		"zplug")
			echo; bash "$PUNTO_SH"/src/zshell.sh plgmanager --zplug
		;;
		"vanilla")
			echo; bash "$PUNTO_SH"/src/zshell.sh vanilla
		;;
		"skip"|"none"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 126
		;;
	esac
	echo
}


################################# AFTER-REBOOT #################################

setup_deno_install() \
{
	setup_asdf --plugin deno
}

setup_python_install() \
{
	setup_asdf --plugin python
}


################################## FINAL-PART ##################################

setup_defaults_postinstall() \
{
	case "$(uname -s)" in
		"Darwin")
			bash "$PUNTO_SH"/src/defaults_macos.sh --post-install
		;;
		"Linux")
			case "$DISTRO" in
				"Arch"|"Manjaro")
					bash "$PUNTO_SH"/src/defaults_arch.sh --post-install
				;;
				"Debian")
					bash "$PUNTO_SH"/src/defaults_debian.sh --post-install
				;;
				"Ubuntu")
					bash "$PUNTO_SH"/src/defaults_ubuntu.sh --post-install
				;;
			esac
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

setup_packages_postinstall() \
{
	case "$(uname -s)" in
		"Darwin")
			bash "$PUNTO_SH"/src/packages_macos.sh --post-install
		;;
		"Linux")
			bash "$PUNTO_SH"/src/packages_linux.sh --post-install
		;;
		*)
			error "$(uname -s) not supported! Skipping..."
			echo; exit 126
		;;
	esac
	echo
}

setup_sync_texteditors() \
{
	bash "$PUNTO_SH"/sync.sh --text-editors full stext
	bash "$PUNTO_SH"/sync.sh --text-editors full vscode

	[ $? -eq 0 ] && success "Custom text editors settings successfully synced"

	bash "$PUNTO_SH"/sync.sh --library
	bash "$PUNTO_SH"/sync.sh --wallpapers
	bash "$PUNTO_SH"/sync.sh --lyrics
	bash "$PUNTO_SH"/sync.sh --fonts

	echo
}

setup_frameworks() \
{
	setup_asdf --frameworks deno
	setup_asdf --frameworks python
	# bash "$PUNTO_SH"/src/frameworks.sh # "$@"
}

setup_localhost() \
{
	bash "$PUNTO_SH"/src/localhost.sh # "$@"
}


################################## UNINSTALL ###################################

uninstall() \
{
	bash "$PUNTO_SH"/uninstall.sh
}

######################################## VERIFY FUNCTIONS ##########################################

verifyRealpathUtility() \
{
	if ! command -v realpath > /dev/null 2>&1;
	then
		echo; printf "%b" "\n\033[38;31mError: <realpath> command not found! Aborting...\n"
		echo; return
	fi
}

verifyRsyncUtility() \
{
	if ! command -v rsync > /dev/null 2>&1;
	then
		error "<rsync> command not found! Aborting..."
		echo; return
	fi
}

verifyFdUtility() \
{
	if ! command -v fd > /dev/null 2>&1;
	then
		error "<fd> command not found! Aborting..."
		echo; return
	fi
}

verifyTrashUtility() \
{
	if command -v trash > /dev/null 2>&1;
	then : ;
	elif command -v macos-trash > /dev/null 2>&1;
	then : ;
	else
		error "<trash> command not found! Aborting..."
		echo; return
	fi
}

####################################################################################################



# ==============================================================================

usage_bootstrap() \
{
echo
echo "Punto Dotfiles Manager Bootstrap Script"
echo "Main script for the correct management and deployment of this dotfiles project."
echo "Influenced by @mavam's bootstrap script."
echo
printf "SYNOPSIS: ./%s [-a][-f][-h][-i][-n][-s] [--args] \n" "$(basename "$0")"
printf "./%s [--fresh-install [defaults|packages|dotfiles|asdf]] \n" "$(basename "$0")"
printf "./%s [--shell-utils [git|vim|emacs|zsh]] \n" "$(basename "$0")"
printf "./%s [--after-reboot [node|python|ruby]] \n" "$(basename "$0")"
printf "./%s [--final-part [text-editors|post-install|frameworks|localhost]] \n" "$(basename "$0")"
printf "./%s [--nuke] \n" "$(basename "$0")"
printf "./%s [--help] \n" "$(basename "$0")"
# cat > output.txt <<'EOF'
cat <<-'EOF'

OPTIONS:
    -i,--fresh-install   Fresh-Install configuration for your new machine, this option runs:
       defaults             Adjust custom OS Settings for productivity, via defaults_<OS>.sh
       packages             Install Packages, via package_<OS>.sh file
       dotfiles             Sync your Dotfiles, via sync.sh file
       asdf                 Install ASDF Manager, via asdf.sh file

    -s,--shell-utils     Download some Shell Utilities, this option runs:
       git                  Setup Git configuration and SSH/GPG GitHub Authentication
       vim                  Download Vim-Plug to manage Vim plugins
       emacs                Download Chemacs2 to manage Emacs profiles
       zsh                  Download ZSH Plugin Managers to manage plugins/themes

    -a,--after-reboot    Setup after-reboot adjustments, this option runs:
       deno                 Install Deno for web development via ASDF V.Manager
       python               Install Python for programming via ASDF V.Manager

    -f,--final-part      Any action you want to do after the after-reboot, this option runs:
       defaults             Adjust final OS settings that need third party binaries
       post-install         Any action you want to do after the reboot, goes here
       text-editors         Symlink full-featured settings for Sublime Text & Visual Studio Code
       frameworks           Download some good libraries for NodeJS, Deno, Python and Ruby
       localhost            Setup an Apache, MySQL and PHP Stack Localhost Environment

    -n,--nuke            You'll only be warned one time before fucking this shit up (uninstall c:)
    -h,--help            Show this menu


Note: all options and their option-arguments are mutually exclusive, and the options run all of their arguments in the order listed above.

It is recommended that you reboot the system to effectively made the changes after finalizes the complete Bootstrapping process.

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

main_bootstrap() \
{
	case "$1" in
		"-h" |"--help")
			usage_bootstrap
			exit 0
		;;
		"-i"|"--fresh-install")
			case "$2" in
				"defaults")
					setup_defaults --basic
				;;
				"packages")
					setup_packages
				;;
				"dotfiles")
					sync_dotfiles
				;;
				"asdf")
					setup_asdf
				;;
				"")
					bold "- Welcome to the Fresh-Install part of the Bootstrap Script!"

					echo; enter_sudo_mode

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
					setup_git
				;;
				"vim")
					setup_vim
				;;
				"emacs")
					setup_emacs
				;;
				"zsh")
					setup_zsh
				;;
				"")
					bold "- Welcome to the Shell Utilities Installation part of the Bootstrap Script!"

					echo; enter_sudo_mode

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
					setup_deno_install
				;;
				"python")
					setup_python_install
				;;
				"")
					bold "- Welcome to the After-Reboot part of the Bootstrap Script"

					echo; enter_sudo_mode

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
					setup_defaults_postinstall
				;;
				"post-install")
					setup_packages_postinstall
				;;
				"text-editors")
					setup_sync_texteditors
				;;
				"frameworks")
					setup_frameworks
				;;
				"localhost")
					setup_localhost
				;;
				"")
					bold "- Welcome to the Final Part of the Bootstrap Script"

					echo; enter_sudo_mode

					# setup_defaults_postinstall
					setup_packages_postinstall
					setup_sync_texteditors
					# setup_frameworks
					# setup_localhost

					[ $? -eq 0 ] && bold "- Finished! Now your machine is ready to go! A reboot never hurts anyone ;)"
					[ $? -eq 0 ] && bold "- Thank you for using Punto Dotfiles Manager!!"

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

verifyRealpathUtility

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

verifyDotfilesFolder() \
{
	### Exporting DOTFILES path and source helper functions so the script can work
	unset DFILES ## unset is POSIX
	if [ -e "$HOME/.dotfiles/sync.sh" ]; then
		DFILES="$HOME/.dotfiles"
	else
		if command -v realpath > /dev/null 2>&1;
		then
			printf "%b" "\n\033[38;32mrealpath found!\033[0m\n"
		else
			printf "%b" "\n\033[38;31mError: realpath not found! Aborting...\033[0m\n"
			echo; exit 126
		fi
	fi

	export DOTFILES=${DFILES:-"$(realpath "$0" | grep -Eo '^.*?dotfiles')"} ## -o: only matching

	if [ -e "$HOME/.helpers" ];
	then
		. "$HOME/.helpers" && printf "%b" "\n\033[38;32mHelper script found!\033[0m\n"
	else
		if ! ln -fsv $DOTFILES/unix/home/helpers $HOME/.helpers;
		then
			. "$HOME/.helpers" && printf "%b" "\n\033[38;32mHelper script found!\033[0m\n"
		else
			printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
			echo; exit 1
		fi
	fi
}

## Verifying utilities
verifyRsyncUtility
verifyFdUtility
verifyTrashUtility

main_bootstrap "$@"; exit
