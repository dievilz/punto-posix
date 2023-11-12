#!/bin/bash
#
# Install Script of Punto Dotfiles Manager (ShellScript Version)
# Shameless ripoff of the Oh-My-Zsh install script ¯\_(ツ)_/¯
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)
#
#
# Before anything else, install the Xcode CLI Tools: xcode-select --install, then...
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/dievilz/punto.sh/master/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/dievilz/punto.sh/master/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o- https://raw.githubusercontent.com/dievilz/punto.sh/master/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   curl https://raw.githubusercontent.com/dievilz/punto.sh/master/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path of the Punto repository:
#   PUNTO_SH=~/.puntosh/ sh install.sh
#
# Respects the following environment variables:
#   PUNTO_SH - path to the Punto D.M. repository folder (default: $HOME/.punto-sh)
#   REPO     - name of the GitHub repo to install from (default: dievilz/punto.sh)
#   REMOTE   - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH   - branch to check out immediately after install (default: master)
#

set -e

## Track if $PUNTO_SH was provided
custom_punto_sh="${PUNTO_SH:+yes}"

## Default settings
PUNTO_SH=${PUNTO_SH:-"$HOME"/.punto-sh}
PUNTO_REPO="${PUNTO_REPO:-dievilz/punto.sh}"
PUNTO_REMOTE="${PUNTO_REMOTE:-https://github.com/${PUNTO_REPO}.git}"
PUNTO_BRANCH="${PUNTO_BRANCH:-master}"


## Track if $DOTFILES was provided
custom_dotfiles="${DOTFILES:+yes}"

## Default settings
DOTFILES=${DOTFILES:-"$HOME"/.dotfiles}
DOTFILES_REPO="${DOTFILES_REPO:-dievilz/dotfiles}"
DOTFILES_REMOTE="${DOTFILES_REMOTE:-https://github.com/${DOTFILES_REPO}.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-master}"




## The [ -t 1 ] check only works when the function is not called from
## a subshell (like in `$(...)` or `(...)`, so this hack redefines the
## function at the top level to always return false when stdout is not
## a tty.
if [ -t 1 ];
then
	is_tty() {
		true
	}
else
	is_tty() {
		false
	}
fi

setup_colors_puntoshinstaller() {
	## Only use colors if connected to a terminal
	if is_tty;
	then
			K='\033[38;30m'   ##  KEY (BLACK)
			R='\033[38;31m'   ##  RED
			G='\033[38;32m'   ##  GREEN
			Y='\033[38;33m'   ##  YELLOW
			B='\033[38;34m'   ##  BLUE
			M='\033[38;35m'   ##  MAGENTA
			C='\033[38;36m'   ##  CYAN
			W='\033[38;37m'   ##  WHITE
		  BK='\033[38;90m'   ##  BRIGHT KEY
		  BR='\033[38;91m'   ##  BRIGHT RED
		  BG='\033[38;92m'   ##  BRIGHT GREEN
		  BY='\033[38;93m'   ##  BRIGHT YELLOW
		  BB='\033[38;94m'   ##  BRIGHT BLUE
		  BM='\033[38;95m'   ##  BRIGHT MAGENTA
		  BC='\033[38;96m'   ##  BRIGHT CYAN
		  BW='\033[38;97m'   ##  BRIGHT WHITE
		  NB='\033[25m'      ##  NOT BLINKING
		  NU='\033[24m'      ##  NOT UNDERLINED
		  NI='\033[23m'      ##  NOT ITALIC/BLACKLETTER
		  NO='\033[22m'      ##  NORMAL, NOT BOLD/DIM
		  RB='\033[6m'       ##  RAPID BLINK
		  SB='\033[5m'       ##  SLOW BLINK
		  UL='\033[4m'       ##  UNDERLINED
		  IT='\033[3m'       ##  ITALIC
		  DM='\033[2m'       ##  DIM
		  BO='\033[1m'       ##  BOLD
		  RE='\033[0m'       ##  RESET ALL
	else
			K=''
			R=''
			G=''
			Y=''
			B=''
			M=''
			C=''
			W=''
		  BK=''
		  BR=''
		  BG=''
		  BY=''
		  BB=''
		  BM=''
		  BC=''
		  BW=''
		  NB=''
		  NU=''
		  NI=''
		  NO=''
		  RB=''
		  SB=''
		  UL=''
		  IT=''
		  DM=''
		  BO=''
		  RE=''
	fi

	 OA="${M}>${R}>${Y}>${B}"  ## Option Arrow
	SOA="${C}-->"              ## SubOption Arrow
	TOA="${BM}-->"             ## ThirdOption Arrow
}

dimcode_puntoinstaller() {   ## shellcheck disable=SC2016 # backtick in single-quote
		is_tty && printf '%b`%s%`%b\n' ${DM} "$*" "${NBO}" || printf '`%b`\n' "$*"
		# is_tty && printf '`%b%s%b`\n' ${DM} "$*" "${NBO}" || printf '`%b`\n' "$*"
		# is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%b`\n' "$*"
}

saferun_puntoinstaller() {
	typeset cmnd="$*"
	typeset ret_code

	eval  "$cmnd"
	ret_code=$?

	if [ "$ret_code" != 0 ];
	then
		printf "%b" "${UL}${R}==> Error: It looks like there was an issue " \
		"running:${NU} $*\nExit code: $ret_code${RE}" "\nExiting...\n\n"
		exit $?
	fi
}



install_puntoshinstaller() {
	## Prevent the cloned repository from having insecure permissions.
	umask g-w,o-w


	if [ $(uname -s) = "Darwin" ];
	then
		if [ ! -d /Applications/Xcode.app/Contents/Developer ] \
		|| [ ! -d /Library/Developer/CommandLineTools ];
		then
			printf "%b\n" "${OA} Install Xcode Command Line Developer Tools${RE}"
			xcode-select --install >/dev/null 2>&1 || {
				printf "%b\n" "${R}==> Error: The install couldn't be completed!${RE}" 1>&2
				echo; exit 1
			}
		fi
	fi

	command -v git > /dev/null 2>&1 || {
		printf "%b\n" "${R}==> Error: Git is not installed! Aborting...${RE}" 1>&2
		echo; exit 1
	}

	ostype=$(uname)
	if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -q msysgit;
	then
		printf "%b\n" "${R}==> Error: Windows/MSYS Git is not supported on Cygwin! Aborting..." 1>&2
		printf "%b\n" "Make sure the Cygwin git package is installed and is first on the \$PATH.${RE}" 1>&2
		echo; exit 1
	fi

	printf "%b\n" "${OA} Cloning @dievilz's Punto Dotfiles Manager (ShellScript Version)...${RE}"

	printf "%b\n" "${SOA} The installation folder will be: $PUNTO_SH."
	printf "%b\n" "${SOA} Do you want to change it to another path? ${RE}"
	printf "%b" "$SOA" " Choose one option ['Y'|'n']['skip'|press Enter to abort]: " "$RE"
	read -r resp
	case "$resp" in
		y|Y|yes|Yes)
			printf "%b" "$SOA" " Enter the full path [press Enter to abort]: " "$RE"
			read -r dots

			while false;
			do
				printf "%b" "$SOA" " Please enter again the full path [press Enter to abort]: " "$RE"
				read -r dots
				PUNTO_SH="$dots"

				if [ -n "$dots" ]; then
					printf "%b\n" "${Y}==> Skipping this step! Aborting installation...${RE}"
					echo; exit 1
				fi

				if [ ! -d "$(dirname "$PUNTO_SH")" ];
				then
					printf "%b\n" "${R}==> Error: The path entered is invalid! Aborting...${RE}" 1>&2
					continue

				elif [ -w "$(dirname "$PUNTO_SH")" ];
				then
					printf "%b\n" "${R}==> Error: The path entered is unwritable! Aborting...${RE}" 1>&2
					continue
				fi

				true
			done
		;;
		n|N|no|No)
			[ -d "$PUNTO_SH" ] && \
			printf "%b\n" "${G}==> Using $PUNTO_SH as the installation folder...${RE}"
			echo;
		;;
		"none"|"None"|"skip"|"Skip"|"")
			printf "%b\n" "${Y}==> Skipping this step! Aborting installation...${RE}"
			echo; exit 0
		;;
		*)
			printf "%b\n" "${R}==> Error: Invalid choice! Aborting...${RE}"
			echo
			printf "%b" "$SOA" " Enter a new prefix or press Enter to abort [Y/n/skip']: " "$RE"
		;;
	esac
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

	if [ -d "$PUNTO_SH" ]; then
		echo
		chmod -v 700 "$PUNTO_SH"
		printf "%b\n" "${G}==> Punto Dotfiles Manager has been successfully cloned!${RE}"
		echo
	fi
}

setup_binaries_puntoshinstaller() {
	if [ -d "$PUNTO_SH" ]; then
		printf "%b\n" "${OA} Installing realpath binary...${RE}"

		if [ ! -d /usr/local/bin/ ]; then
			printf "%b\n" "${C}==> Creating /usr/local/bin folder${RE}"
			mkdir -p /usr/local/bin
		fi
		if [ ! -d "$HOME/.local/bin" ]; then
			printf "%b" "${C}==> Creating $HOME/.local/bin folder!${RE}\n"
			mkdir -m 700 -v "$HOME"/.local
			mkdir -pv "$HOME"/.local/bin
		fi

		if [ ! -e /usr/local/bin/realpath ]; then
			printf "%b\n" "${C}==> Compiling the realpath binary${RE}"

			echo; printf "%b\n" "${C}==> Compiling the source code through the Makefile${RE}"
			make --directory "$PUNTO_SH"/src/realpath

			echo; printf "%b\n" "${C}==> Moving the compiled binary to \$PUNTO_SH/bin${RE}"
			mv -fv "$PUNTO_SH"/src/realpath/realpath "$PUNTO_SH/bin/realpath"
		else
			printf "%b\n" "${G}==> realpath is already installed!${RE}"
			echo
		fi

		printf "%b\n" "${OA} Downloading the other binaries...${RE}"
		curl -o "PUNTO_SH/bin/exa"
		curl -o "PUNTO_SH/bin/fd"
		curl -o "PUNTO_SH/bin/macos-trash"
		curl -o "PUNTO_SH/bin/shellcheck"


		printf "%b\n" "${OA} Moving the other binaries to /usr/local/bin...${RE}"
		mv -fv "$PUNTO_SH"/bin/exa "$PUNTO_SH/bin/exa"
		mv -fv "$PUNTO_SH"/bin/fd "$PUNTO_SH/bin/fd"
		mv -fv "$PUNTO_SH"/bin/macos-trash "$PUNTO_SH/bin/macos-trash"
		mv -fv "$PUNTO_SH"/bin/shellcheck "$PUNTO_SH/bin/shellcheck"

		export PATH="$PUNTO_SH/bin:${PATH}"
	else
		printf "%b\n" "${R}==> Error: Punto D.M. folder is missing! Aborting...${RE}" 1>&2
	fi
}

bootstrap_or_sync_puntoshinstaller() {
	. "$PUNTO_SH/scripts/functions/helpers.sh"

	# warn "Don't forget to plug all your external devices with your wallpapers" \
	# "and fonts to sync them, if that's your case"

	echo; option "Okay, we are ready to go!!!"

	subopt "Do you want to Bootstrap the system, just Sync the Dotfiles at" \
	"$HOME/*, or abort this installation?"
	printf "%b Choose one option [B/S/skip']: %b" "$SOA" "$RE"
	read -r resp

	if [ -n "$1" ] && [ "$1" = "-b" ] || [ "$1" = "-s" ]; then
		resp="$1"
	fi

	case "$resp" in
		"B"|"b") pushd "$PUNTO_SH"; ./bootstrap.sh -i; popd
		;;
		"S"|"s") pushd "$PUNTO_SH"; ./sync.sh; popd
		;;
		"skip"|*)
			red "Aborting..."
			echo
			blue '"Le saca? Nombre compa que le voy andar sacando alv"'
			blue "                                         - El Gusgri"
			echo; exit 1
		;;
	esac
}

sanity_puntoshinstaller() \
{
	setup_colors_puntoshinstaller

	if [ -d "$PUNTO_SH" ]; then
		printf "%b\n" "${Y}The \$PUNTO_SH folder already exists! (\"$PUNTO_SH\")${RE}"

		if [ "$custom_punto_sh" = yes ]; then
			cat <<EOF

You ran the installer with the \$PUNTO_SH setting activated or the \$PUNTO_SH variable is
exported. You have 3 options:

1. Unset the PUNTO_SH variable when calling the installer:
	$(dimcode_puntoinstaller "PUNTO_SH= sh install.sh")

2. Install Punto Dotfiles Manager to a directory that doesn't exist yet:
	$(dimcode_puntoinstaller "PUNTO_SH=/path/to/new/punto-sh/folder sh install.sh")

3. (Caution) If the folder doesn't contain important information,
	you can just remove it with: $(dimcode_puntoinstaller "rm -r "$PUNTO_SH"")

4. ...Just move the folder to another location or rename it:
	$(dimcode_puntoinstaller "cp -v "$PUNTO_SH" "/another/path/$PUNTO_SH"") or
	$(dimcode_puntoinstaller "mv -v "$PUNTO_SH" "$PUNTO_SH-old"")

EOF
		else
			printf "%b\n" "${Y}You'll need to remove it if you want to reinstall.${RE}"
		fi
		echo; exit 1
	else
		echo
	fi
}

sanity_dotfiles_puntoshinstaller() \
{
	setup_colors_puntoshinstaller

	if [ -d "$DOTFILES" ]; then
		printf "%b\n" "${Y}The \$DOTFILES folder already exists! (\"$DOTFILES\")${RE}"

		if [ "$custom_dotfiles" = yes ]; then
			cat <<EOF

You ran the installer with the \$DOTFILES setting activated or the \$DOTFILES variable is
exported. You have 3 options:

1. Unset the DOTFILES variable when calling the installer:
	$(dimcode_puntoinstaller "DOTFILES= sh install.sh")

2. Install your DOTFILES to a directory that doesn't exist yet:
	$(dimcode_puntoinstaller "DOTFILES=/path/to/new/dotfiles/folder sh install.sh")

3. (Caution) If the folder doesn't contain important information,
	you can just remove it with: $(dimcode_puntoinstaller "rm -r "$DOTFILES"")

4. ...Just rename the folder or move it to another location:
	$(dimcode_puntoinstaller "cp -v "$DOTFILES" "/another/path/$DOTFILES"") or
	$(dimcode_puntoinstaller "mv -v "$DOTFILES" "$DOTFILES-old"")

EOF
		else
			printf "%b\n" "${Y}You'll need to remove it if you want to reinstall.${RE}"
		fi
		echo; exit 1
	else
		echo
	fi
}



# ==============================================================================

usage_puntoshinstaller() {
echo
echo "Punto Dotfiles Manager Install Script (ShellScript version)"
echo "Shameless ripoff of the Oh-My-Zsh install script ¯\_(ツ)_/¯"
echo
printf "SYNOPSIS:\n./%s [options][-h] \n" "$(basename "$0")"
cat <<-'EOF'

OPTIONS:
	 --install        Download Punto GitHub repository
	 --binaries       Make and place the required binaries for proper Punto operation
	 --bootstrap      Jump direclty to Bootstrap your system
	 --sync           Jump direclty to Sync just your dotfiles

	 -h,--help        Show this menu

Running this script without arguments will execute all the options in the above order.

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

main_puntoshinstaller() \
{
	echo
	sanity_puntoshinstaller
	sanity_dotfiles_puntoshinstaller

	case $1 in
		"-h"|"--help")
			usage_puntoshinstaller
		;;
		"-i"|"--install")
			echo; install_puntoshinstaller
		;;
		"-x"|"--binaries")
			echo; setup_binaries_puntoshinstaller
		;;
		"-b"|"--bootstrap")
			echo; bootstrap_or_sync_puntoshinstaller "-b"
		;;
		"-s"|"--sync")
			echo; bootstrap_or_sync_puntoshinstaller "-s"
		;;
		"")
			install_puntoshinstaller
			setup_binaries_puntoshinstaller
			bootstrap_or_sync_puntoshinstaller "-b"
			bootstrap_or_sync_puntoshinstaller "-s"
		;;
		*)
			error "Unknown option! Use -h/--help"
			exit 127
		;;
	esac
}

main_puntoshinstaller "$@"
