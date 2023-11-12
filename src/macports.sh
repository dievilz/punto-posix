#!/bin/bash
#
# MacPorts Package Manager Install Script.
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)

download_macports() {
	## Check for MacPorts install
	if command -v port > /dev/null 2>&1;
	then
		success "Looks like you already have MacPorts installed! Skipping" \
		"installation..."
		echo; return # 1
	fi

	enter_sudo_mode

	subopt "Downloading MacPorts in \$HOME/.opt/..."

	local MPORTS_STABLE_RELEASE="2.7.1"

	local MPORTS_URL="https://distfiles.macports.org/MacPorts/"
	local MPORTS_TAR="MacPorts-${MPORTS_STABLE_RELEASE}.tar.gz"
	local MPORTS_TAR_IN_PATH="/tmp/${MPORTS_TAR}"

	local MPORTS_KEY="${MPORTS_TAR}.asc"

	local MPORTS_PUBKEY_URL="https://trac.macports.org/attachment/wiki/jmr/"
	local MPORTS_PUBKEY="jmr_at_macports_org-2013.pubkey"
	local MPORTS_PUBKEY_IN_PATH="/tmp/${MPORTS_PUBKEY}"


	################################ --1-- #####################################
	## DOWNLOAD SOURCE TARBALL

	trdopt "Downloading the source tarball (if it's not already downloaded)..."
	if [ ! -e "$MPORTS_TAR_IN_PATH" ];
	then
		frtopt "Fetching tarball from MacPorts' repo..."
		saferun curl -o "$MPORTS_TAR_IN_PATH" "${MPORTS_URL}/${MPORTS_TAR}"
	else
		success "Looks like you already have the MacPorts source tarball downloaded!"
	fi
	echo


	################################ --2-- #####################################
	## VERIFY PGP SIGNATURE. THIS REQUIRES GPG.
	trdopt "Verifying the tarball authenticity via PGP signature..."

	if ! command -v gpg > /dev/null 2>&1;
	then
		error "gpg not found. It's needed to check the signature of the" \
		"source tarball!"
		red "${BO}We suggest to download independently a GnuPG binary" \
		"release (may be from Sourceforge), check SHA integrity, install as" \
		"you wish, check PGP signature to verify the authenticity of the GnuPG" \
		"package itself and come back to continue the installation. Aborting.."
		echo; return 1
	fi

	if [ ! -f "$MPORTS_TAR_IN_PATH.asc" ];
	then
		frtopt "Fetching source tarball PGP key from MacPorts' repo..."
		saferun curl -o "${MPORTS_TAR_IN_PATH}.asc" "${MPORTS_URL}/${MPORTS_KEY}"
	else
		success "Looks like you already have downloaded the PGP key..."
	fi
	echo

	if [ ! -f "$MPORTS_PUBKEY_IN_PATH" ];
	then
		frtopt "Fetching MacPorts' project manager Joshua Root PGP public key" \
		"from MacPorts' wiki..."
		saferun curl -o "${MPORTS_PUBKEY_IN_PATH}" "${MPORTS_PUBKEY_URL}/${MPORTS_PUBKEY}"
	else
		success "Looks like you already have downloaded the PGP public key..."
	fi
	echo

	frtopt "Importing PGP public key..."
	saferun gpg --import "${MPORTS_PUBKEY_IN_PATH}"
	echo

	frtopt "Checking tarball signature..."
	saferun gpg --verify "${MPORTS_TAR_IN_PATH}{.asc,}"
	echo



	################################ --3-- #####################################
	## EXTRACTING MACPORTS IN $HOME/.opt
	trdopt "Extracting MacPorts in \$HOME/.opt..."
	if [ ! -e "$HOME/.opt/MacPorts-$MPORTS_STABLE_RELEASE/configure" ];
	then
		frtopt "Proceeding to extract the source tarball ..."
		saferun tar -zxpf "${MPORTS_TAR_IN_PATH}" -C "$HOME/.opt"
		chown -v "$(id -un)":"$(id -gn)" "$HOME/.opt/MacPorts-$MPORTS_STABLE_RELEASE"

		success "MacPorts extracted."
	else
		success "Looks like you already have extracted MacPorts in place..."
	fi
	echo



	################################ --4-- #####################################
	## INSTALLING MACPORTS
	subopt "Installing MacPorts..."

	trdopt "Type the absolute path prefix (including final folder name) where" \
	"you want to place the binaries (i.e. /opt/ports)."
	trdoptq "Please don't use spaces in the path. MacPorts itself can handle" \
	"them, but many build scripts cannot: "

	until false;
	do
		read -r macPortsPrefix
		case $macPortsPrefix in
			"/"|"/tmp"|"/sw"|"/opt/local"|*"brew"*|"/opt/pkg"|"/usr/local")
				error "Invalid directory: it is used by another package manager" \
				"or I dont't want anyone to use them. Try again..."
				echo; frtoptq "Enter a new prefix: "
			;;
			"/"*)
				if [ ! -d "$(dirname "$macPortsPrefix")" ];
				then
					mkdir -pv "$macPortsPrefix"
				fi

				if [ -d "$macPortsPrefix/config/macports_version" ];
				then
					error "Invalid directory: it is used by another MacPorts" \
					"instance. Try again..."
					echo; frtoptq "Enter a new prefix: "
					continue
				fi

				install_macports
				true
			;;
			""|*)
				error "Invalid choice! Aborting..."
				echo; return # 1
			;;
		esac
	done
}

install_macports() {
	echo
	cd "$HOME/.opt/MacPorts-$MPORTS_STABLE_RELEASE" || return

	## Temporarily removes any other binaries but the system ones
	OLD_PATH="$PATH"
	export PATH=/bin:/sbin:/usr/bin:/usr/sbin

	sudo ./configure --prefix="$macPortsPrefix" --with-applications-dir="$macPortsPrefix"/Applications
	sudo make install
	sudo make distclean

	## Recover the old PATH
	PATH="$OLD_PATH"

	if [ -e "$macPortsPrefix/bin/port" ];
	then
		frtopt "Changing the owner of $macPortsPrefix to root:wheel"
		sudo chown -v root:wheel "$macPortsPrefix"

		if [ ! -f /tmp/macports_path ];
		then
			touch /tmp/macports_path
		fi
	fi

	printf "%s\n" "export PATH=\"$macPortsPrefix/bin:\${PATH}\"" > /tmp/macports_path

	success "MacPorts has been successfully installed!"
}



# ==============================================================================

usage_macports() {
echo
echo "MacPorts Package Manager Install Script"
echo
printf "SYNOPSIS: ./%s [--install][-h] \n" "$(basename "$0")"
cat <<-'EOF'

OPTIONS:
    --install       Download MacPorts at any path

    -h,--help       Show this menu

For full documentation, see: https://github.com/dievilz/punto.sh#readme

EOF
}

main_macports() {
	case $1 in
		"-h"|"--help")
			usage_macports
		;;
		"--install")
			echo; download_macports
		;;
		*)
			usage_macports
		;;
	esac
}

isMacos

if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi
