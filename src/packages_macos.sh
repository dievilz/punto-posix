#!/bin/bash
#
# macOS Packages Install Script
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

HOMEBREW_NO_INSTALL_CLEANUP=1

############################## macOS INSTALLATION ##############################

install_in_macos() {
	case $1 in
		"fink")
			shift
			. "$PUNTO_SH"/src/fink.sh && main_fnk "$@"
		;;
		"homebrew")
			shift
			. "$PUNTO_SH"/src/homebrew.sh && main_homebrew "$@"
		;;
		"macports")
			shift
			. "$PUNTO_SH"/src/macports.sh && main_macports "$@"
		;;
		"pkgin")
			shift
			. "$PUNTO_SH"/src/pkgin.sh && main_pkgn "$@"
		;;
		*)
			error "$1 package manager not supported! Aborting..."
			echo; return
		;;
	esac
	echo
}
setup_macos_packagemanagers() {
	option "Installing Package Managers..."
	subopt "Choose one option [home'brew'|mac'ports'|'pkgin'|'fink']"
	suboptq "(to halt [type ${BO}'skip'${NBO}|${BO}'none'${NBO}] or" \
	"[press ${BO}Enter key${NBO}]): "
	read -r resp
	echo
	case "$resp" in
		"fink")
			install_in_macos fink --install
		;;
		"brew"|'homebrew')
			install_in_macos homebrew --install
		;;
		"ports"|"macports")
			install_in_macos macports --install
		;;
		"pkgin")
			install_in_macos pkgin --install
		;;
		"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; return
		;;
	esac
	echo
}
setup_macos_packages() {
	option "Installing Packages (binaries, libraries, etc)..."
	subopt "Choose one option [brew'bundle'|brew'csv'|mac'ports'|'pkgin'|'fink']"
	suboptq "(to halt [type ${BO}'skip'${NBO}|${BO}'none'${NBO}] or" \
	"[press ${BO}Enter key${NBO}]): "
	read -r resp
	echo
	case "$resp" in
		"fink")
			installationloop_macos fink P
		;;
		'bundle')
			install_in_macos homebrew --packages
		;;
		"csv")
			installationloop_macos homebrew P
		;;
		"ports"|"macports")
			installationloop_macos macports P
		;;
		"pkgin")
			installationloop_macos pkgin P
		;;
		"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; return
		;;
	esac
	echo
}
setup_macos_apps() {
	option "Installing GUI Apps..."
	subopt "Choose one option [home'brew'|'casks'|'appstore'|mac'ports'|'pkgin'|'fink']"
	suboptq "(to halt [type ${BO}'skip'${NBO}|${BO}'none'${NBO}] or" \
	"[press ${BO}Enter key${NBO}]): "
	read -r resp
	echo
	case "$resp" in
		"fink")
			installationloop_macos fink A
		;;
		"brew"|'homebrew')
			install_in_macos homebrew --apps
		;;
		"casks")
			install_in_macos homebrew --casks
		;;
		"appstore")
			install_in_macos homebrew --mas
		;;
		"ports"|"macports")
			installationloop_macos macports A
		;;
		"pkgin")
			installationloop_macos pkgin A
		;;
		"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; return
		;;
	esac

	setup_loginitems_macos "basic"
	echo
}
setup_macos_fonts() {
	option "Installing some nice Fonts..."
	subopt "Choose one option [home'brew'|mac'ports'|'pkgin'|'fink']"
	suboptq "(to halt [type ${BO}'skip'${NBO}|${BO}'none'${NBO}] or" \
	"[press ${BO}Enter key${NBO}]): "
	read -r resp
	echo
	case "$resp" in
		"fink")
			installationloop_macos fink F
		;;
		"brew"|'homebrew')
			install_in_macos homebrew --fonts
		;;
		"ports"|"macports")
			installationloop_macos macports F
		;;
		"pkgin")
			installationloop_macos pkgin F
		;;
		"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; return
		;;
	esac
	echo
}
setup_macos_services() {
	option "Installing some nice Fonts..."
	subopt "Choose one option [home'brew'|mac'ports'|'pkgin'|'fink']"
	suboptq "(to halt [type ${BO}'skip'${NBO}|${BO}'none'${NBO}] or" \
	"[press ${BO}Enter key${NBO}]): "
	read -r resp
	echo
	case "$resp" in
		"fink")
			start_services_fink_macos
		;;
		"brew"|'homebrew')
			command -v brew > /dev/null 2>&1 && sudo brew services restart --all
		;;
		"ports"|"macports")
			start_services_macports_macos
		;;
		"pkgin")
			start_services_pkgin_macos
		;;
		"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; return
		;;
	esac
	echo
}

########################### macOS POST-INSTALLATION ############################

setup_macos_postinstall() {
	option "Setting up macOS Packages Post-Install actions..."

	setup_loginitems_macos "full"

	echo
}
setup_loginitems_macos() {
	subopt "Setting up Login Items for this user..."

	suboptq "Proceed? ['Y'|'n'|press Enter to halt]: "
	read -r resp
	echo
	case "$resp" in
		y|Y|yes|Yes)
			if [ "$1" = "basic" ];
			then
				osascript "$PUNTO_SH/src/tools/basic-login-items.applescript"

			elif [ "$1" = "full" ];
			then
				osascript "$PUNTO_SH/src/tools/full-login-items.applescript"
			fi
		;;
		n|N|no|No|"skip"|"Skip"|"none"|"None"|"")
			warn "Skipping this step!"
		;;
		*)
			error "Invalid choice! Aborting..."
			echo; exit 1
		;;
	esac
	echo
}



############################ INSTALLATION FUNCTIONS ############################

updatePkgManagerPath_macos() {
	subopt "Checking your \$PATH for $1..."

	case "$1" in
		"fink")
			binCmd=fink
			tmpFile=/tmp/fink_path
		;;
		"homebrew")
			binCmd=brew
			tmpFile=/tmp/homebrew_path
		;;
		"macports")
			binCmd=port
			tmpFile=/tmp/macports_path
		;;
		"pkgin")
			binCmd=pkgin
			tmpFile=/tmp/pkgin_path
		;;
	esac

	if ! command -v "$binCmd" > /dev/null 2>&1;
	then
		if [ -e "$tmpFile" ];
		then
			. "$tmpFile"
		else
			error "$(basename "$tmpFile") file int /tmp not found! Aborting..."
			return
		fi
	else
		success "$1 binary found!"
	fi
	echo
}

verifyprogsfile_macos() {
	subopt "Checking your Programs file..."

	PROGSFILE="$PUNTO_SH/programs/macos_progs.csv"

	if [ -e "$PROGSFILE" ];
	then
		cp -v "$PROGSFILE" /tmp/macos_progs.csv
		PROGSFILE=/tmp/macos_progs.csv

	elif [ ! -e "$PROGSFILE" ];
	then
		PROGSFILE="https://raw.githubusercontent.com/dievilz/punto.sh/master/programs/macos_progs.csv"
		([ -f "$PROGSFILE" ] && cp "$PROGSFILE" /tmp/macos_progs.csv) || saferun curl -Ls "$PROGSFILE" | sed '/^#/d' > /tmp/macos_progs.csv
		PROGSFILE=/tmp/macos_progs.csv
	else
		error "Program file not found or couldn't be fetched! Aborting..."
		return
	fi

	success "Programs file found!"
	echo
}

installationloop_macos() {
	updatePkgManagerPath_macos "$1"
	verifyprogsfile_macos
	enter_sudo_mode

	if [ -e "$PROGSFILE" ];
	then
		total=$(grep -w -c "$1" "$PROGSFILE" | tr -d ' ')
		n=1

		while IFS=, read -r pkgmnger category program args comment <&9;
		do
			if [ ! "$pkgmnger" = "$1" ]; then
				continue
			fi

			if [ ! "$category" = "$2" ]; then
				continue
			fi

			if [ -z "$pkgmnger" ] || [ -z "$category" ] \
			|| [ -z "$program" ]; then
				continue
			fi

			echo "$comment" | grep -q "^\".*\"$" && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"

			case "$pkgmnger" in
				"fink")
					if [ "$category" = "$2" ];
					then
						fnkinstall_macos
					fi
				;;
				"homebrew")
					if [ "$category" = "$2" ];
					then
						brewinstall_macos
					fi
				;;
				"macports")
					if [ "$category" = "$2" ];
					then
						portinstall_macos
					fi
				;;
				"pkgin")
					if [ "$category" = "$2" ];
					then
						pkgninstall_macos
					fi
				;;
				"gitrepo")
					if [ "$category" = "$2" ];
					then
						gitmakeinstall_macos
					fi
				;;
			esac

			n=$((n+1))

		done 9< "$PROGSFILE"

	else
		error "/programs/macos_progs.csv not found! Aborting..."
		return
	fi
}

brewinstall_macos() {
	unset $proceed
	trdopt "Installing $program ($n of $total): $comment"

	if [ $PUNTO_SH_UNATTENDED_ENABLED -eq 0 ];
	then
		subopt "Do you wish to continue? [Type anything or press Enter key to skip]"
		suboptq "" && read -r proceed
	else
		proceed=y
	fi

	if brew search "$program" | grep -E '^.*?\Error: No formulae or casks found for';
	then
		error "$program is not in Brew! Skipping..."
	else
		case $proceed in
			"")
				warn "Skipping!"
			;;
			*)
				if [ -z "$args" ];
				then
					brew install "$program" || {
						error "$program Installation failed! Skipping..."
					}
				else
					brew install "$program $args" || {
						error "$program Installation failed! Skipping..."
					}
				fi
			;;
		esac
	fi
	echo
}

portinstall_macos() {
	unset $proceed
	trdopt "Installing $program ($n of $total): $comment"

	if [ $PUNTO_SH_UNATTENDED_ENABLED -eq 0 ];
	then
		subopt "Do you wish to continue? [Type anything or press Enter key to skip]"
		suboptq "" && read -r proceed
	else
		proceed=y
	fi

	if port search --case-sensitive --exact "$program" | grep -E '^.*?\No match for';
	then
		error "$program is not in MacPorts! Skipping..."
	else
		case $proceed in
			"")
				warn "Skipping!"
			;;
			*)
				if [ -z "$args" ];
				then
					sudo port install -bNqtv "$program" || {

						error "$program binary installation failed! Trying from source..."
						echo
						frtopt "Do you want to install $program from source?"
						frtoptq "Press Enter to skip: "
						read -r proceed

						case $proceed in
							"")
								warn "Skipping $program installation!..."
							;;
							*)
								sudo port install -Nqtv "$program" || {
									error "$program source installation failed! Cleaning..."
									sudo port clean "$program"
								}
							;;
						esac
					}
				else
					sudo port install -bNqtv "$program $args" || {

						error "$program binary installation failed! Trying from source..."
						echo
						frtopt "Do you want to install $program from source?"
						frtoptq "Press Enter to skip: "
						read -r proceed

						case $proceed in
							"")
								warn "Skipping $program installation!..."
							;;
							*)
								sudo port install -Nqtv "$program $args" || {
									error "$program source installation failed! Cleaning..."
									sudo port clean "$program"
								}
							;;
						esac
					}
				fi
			;;
		esac
	fi
	echo
}

pkgninstall_macos() {
	unset $proceed
	trdopt "Installing $program ($n of $total): $comment"

	if [ $PUNTO_SH_UNATTENDED_ENABLED -eq 0 ];
	then
		subopt "Do you wish to continue? [Type anything or press Enter key to skip]"
		suboptq "" && read -r proceed
	else
		proceed=y
	fi

	if pkgin search "^$program$" | grep -E '^.*?\No results found for';
	then
		error "$program is not in Pkgin! Skipping..."
	else
		case $proceed in
			"")
				warn "Skipping!"
			;;
			*)
				if [ -z "$args" ];
				then
					sudo pkgin -y install "$program" || {
						error "Installation failed! Skipping..."
					}
				else
					sudo pkgin -y install "$program $args" || {
						error "Installation failed! Skipping..."
					}
				fi
			;;
		esac
	fi
	echo
}

gitmakeinstall_macos() {
	progname="$(basename "$program" .git)"

	trdopt "Installing $progname ($n of $total): $comment"
	trdopt "Via \`git\` and \`make\`."

	dir="$HOME/Dev/Repos/$progname"

	git clone --depth 1 "$program" "$dir" >/dev/null 2>&1 || {
		cd "$dir" || return
		git pull --force origin master;
	}
	echo

	# cd "$dir" || exit 1
	# make > /dev/null 2>&1
	# make install > /dev/null 2>&1
	# cd /tmp || return 1
	# echo
}

####################################################################################################



# ==============================================================================

usage_macospackages() {
echo
echo "macOS Package Managers Install Script"
echo "Parent script to install macOS Package Managers via other scripts."
echo
printf "SYNOPSIS: ./%s [-a][-f][-g][-h][-i][-o][-p][-s][-u] \n" "$(basename "$0")"
cat <<-'EOF'

ENVIRONMENT VARIABLES
    PUNTO_SH_UNATTENDED_ENABLED
                         For running unattended
OPTIONS:
    -U                   Enable unattended mode

ARGUMENTS:
    -i,--managers        Install macOS Package Managers
    -p,--packages        Install packages (binaries/libraries)
    -g,--git             Install Git repos (GitHub, GitLab, etc...)
    -a,--apps            Install GUI apps from their respective package manager
    -f,--fonts           Install nice Fonts from their respective package manager
    -s,--services        Start packages services from their respective package manager
    -o,--post-install    Any action you want to do after the reboot, goes here, i.e.
                         install apps that are very slow to compile

    -h,--help            Show this menu

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

menu_macospackages() {
	case $1 in
		"-h"|"--help")
			usage_macospackages
			exit 0
		;;
		"-U")
			PUNTO_SH_UNATTENDED_ENABLED=1
		;;
		"") true
		;;
		*)
			error "Unknown option! Use -h/--help"
			return 127
		;;
	esac
	shift
	case $1 in
		"-i"|"--managers")
			echo; setup_macos_packagemanagers
		;;
		"-p"|"--packages")
			echo; setup_macos_packages
		;;
		"-g"|"--git")
			echo; installationloop_macos gitrepo G
		;;
		"-a"|"--apps")
			echo; setup_macos_apps
		;;
		"-f"|"--fonts")
			echo; setup_macos_fonts
		;;
		"-s"|"--services")
			echo; setup_macos_services
		;;
		"-o"|"--post-install")
			echo; setup_macos_postinstall
		;;
		*)
			error "Unknown option! Use -h/--help"
			return 127
		;;
	esac
}

main_case_macospackages() {
	echo
	option "We are going to install a concept one by one."
	until false;
	do
		echo
		subopt "Below are the options:"
		usage_macospackages

		subopt "Choose one option from the usage..."
		subopt "[${BO}'skip'${NBO}|${BO}'none'${NBO}][press ${BO}Enter key${NBO}] to halt"
		suboptq "" && read -r pkgMan

		case "$pkgMan" in
			"none"|"None"|"skip"|"Skip"|"")
				warn "Skipping this step!"
				return 1
				break
			;;
			*) menu_macospackages $pkgMan
			;;
		esac
	done
}

main_macospackages() {
	if [ "$#" -eq 0 ];
	then
		main_case_macospackages
	else
		menu_macospackages "$@"
	fi

	[ $? -eq 0 ] && success "macOS packages successfully installed!"
	[ $? -eq 0 ] && warn "Execute '--post-install' when you have finished Bootstrapping"
	echo
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

main_macospackages "$@"; exit
