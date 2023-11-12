#!/bin/zsh
#
# A streamlined bootstrapper for getting pkgsrc/pkgin up and running on macOS
# Originally based on @cmacrae's bootstrap script (www.github.com/cmacrae/savemacos/blob/master/bootstrap)
#
# Simplified version of @dievilz's pkgin4macos script (www.github.com/dievilz/pkgin4macos)
#
# Use of this source code is governed by an ISC
# license that can be found in the LICENSE file.

################################################################################

install_pkgn() \
{
	## Check for Pkgin install
	if command -v pkgin > /dev/null 2>&1;
	then
		success "Looks like you already have Pkgin installed! Skipping" \
		"installation..."
		echo; return # 1
	fi

	enter_sudo_mode

	## Pkgsrc site/bootstrap properties
	PKGSRC_SITE="https://pkgsrc.joyent.com/packages/Darwin"
	BOOTSTRAP_KEY_URL="${PKGSRC_SITE}/bootstrap"

	## OS release POSIX
	case "$(uname -r)" \
	in
	  "2"*)              ## Big Sur (11.*) or newer
	    case "$(uname -m)" in   ## machine POSIX
	      "x86_64"|"i386")
	         PKGSRC_QUARTER="macos11-trunk-x86_64"
	         BOOTSTRAP_TRUNK_RELEASE="20211207"
	         BOOTSTRAP_SHA="07e323065708223bbac225d556b6aa5921711e0a"
	         # BOOTSTRAP_TRUNK_RELEASE="20201112"
	         # BOOTSTRAP_SHA="b3c0c4286a2770bf5e3caeaf3fb747cb9f1bc93c"
	      ;;
	      "arm64")
	         PKGSRC_QUARTER="macos11-trunk-arm64"
	         BOOTSTRAP_TRUNK_RELEASE="20211207"
	         BOOTSTRAP_SHA="036b7345ebb217cb685e54c919c66350d55d819c"
	      ;;
	    esac
	  ;;
	  "18"*|"19"*)       ## Mojave (10.14) or Catalina (10.15)
	    PKGSRC_QUARTER="macos14-trunk-x86_64"
	    BOOTSTRAP_TRUNK_RELEASE="20210717"
	    BOOTSTRAP_SHA="a23fed860e7f515e7405fcfea9595049b9ea6634"
	    # BOOTSTRAP_TRUNK_RELEASE="20200716"
	    # BOOTSTRAP_SHA="395be93bf6b3ca5fbe8f0b248f1f33181b8225fe"
	  ;;
	  "16"*|"17"*)       ## Sierra (10.12) or High Sierra (10.13)
	    warn "Packages for Sierra and High Sierra are no longer updated!"
	          PKGSRC_SITE="https://us-east.manta.joyent.com/pkgsrc/public/packages/Darwin/10.12"
	    PKGSRC_QUARTER="trunk-x86_64"
	    BOOTSTRAP_TRUNK_RELEASE="20190524"
	    BOOTSTRAP_SHA="1c554a806fb41dcc382ef33e64841ace13988479"
	  ;;
	  "13"*|"14"*|"15"*) ## Mavericks (10.9) to El Capitan (10.11)
	    warn "Packages for Mavericks to El Capitan are no longer updated!"
	          PKGSRC_SITE="https://us-east.manta.joyent.com/pkgsrc/public/packages/Darwin/10.9"
	          BOOTSTRAP_KEY_URL="${PKGSRC_SITE}/bootstrap"
	    PKGSRC_QUARTER="trunk-x86_64"
	    BOOTSTRAP_TRUNK_RELEASE="20181001"
	    BOOTSTRAP_SHA="7209132a657582cf87897a2ad280c587e3d6bff0"
	  ;;
	  "10"*|"11"*|"12"*) ## Snow Leopard (10.6) to Mountain Lion (10.8)
	    warn "Packages for Snow Leopard to Mountain Lion are no longer updated!"
	    PKGSRC_QUARTER="trunk-i386"
	    BOOTSTRAP_TRUNK_RELEASE="20180812"
	    BOOTSTRAP_SHA="283b88b13c75e8f92de8376532ccf4f4b9443f9d"
	  ;;
	  *)
	    error "Unsupported macOS version! Aborting..."
	    echo; return 1
	  ;;
	esac

	BOOTSTRAP_URL="${PKGSRC_SITE}/bootstrap/"
	BOOTSTRAP_TAR="bootstrap-${PKGSRC_QUARTER}-${BOOTSTRAP_TRUNK_RELEASE}.tar.gz"
	BOOTSTRAP_TAR_IN_PATH="/tmp/${BOOTSTRAP_TAR}"

	BOOTSTRAP_KEY_URL="${BOOTSTRAP_KEY_URL}/${BOOTSTRAP_TAR}.asc"


	################################ --1-- #####################################
	## DOWNLOAD BOOTSTRAP KIT AND VERIFIY SHA INTEGRITY

	option "Downloading the bootstrap kit (if it's not already downloaded)..."
	if [ ! -f $BOOTSTRAP_TAR_IN_PATH ];
	then
		subopt "Fetching tarball from Joyent's Pkgsrc repo according to your" \
		"system's specifications..."
		saferun curl -o $BOOTSTRAP_TAR_IN_PATH "${BOOTSTRAP_URL}/${BOOTSTRAP_TAR}"
	else
		success "Looks like you already have the Pkgsrc bootstrap kit downloaded!"
	fi
	echo


	option "Verifying tarball integrity via SHA-1 checksum..."
	if echo "${BOOTSTRAP_SHA}  ${BOOTSTRAP_TAR_IN_PATH}" | shasum -c-;
	then
		success "Pkgsrc bootstrap kit retrieved successfully!"
		echo
	else
		error "The integrity couldn't be verified! Aborting..."
		echo; return 1
	fi


	################################ --2-- #####################################
	## VERIFY PGP SIGNATURE. THIS REQUIRES GPG.

	option "Verifying the tarball authenticity via PGP signature..."
	if ! command -v gpg > /dev/null 2>&1;
	then
		error "gpg not found. It's needed to check the signature of the" \
		"bootstrap kit!"
		red "${BO}We suggest to download independently a GnuPG binary" \
		"release (may be from Sourceforge), check SHA integrity, install as" \
		"you wish, check PGP signature to verify the authenticity of the GnuPG" \
		"package itself and come back to continue the installation. Aborting.."
		echo; return 1
	fi

	if [ ! -f "$BOOTSTRAP_TAR_IN_PATH.asc" ];
	then
		subopt "Fetching bootstrap kit PGP key from Joyent's repo..."
		saferun curl -o "${BOOTSTRAP_TAR_IN_PATH}.asc" "${BOOTSTRAP_KEY_URL}"
	else
		success "Looks like you already have downloaded the PGP key..."
	fi
	echo

	subopt "Importing Joyent's repo PGP key..."
	saferun curl -sS https://pkgsrc.joyent.com/pgp/1F32A9AD.asc | gpg --import
	echo

	subopt "Checking tarball signature..."
	saferun gpg --verify "${BOOTSTRAP_TAR_IN_PATH}{.asc,}"
	echo



	################################ --3-- #####################################
	## INSTALLING PKGIN IN /opt/pkg
	option "Installing pkgin in /opt/pkg..."
	if [ ! -f /opt/pkg/bin/pkgin ];
	then
		subopt "Proceeding to untar the bootstrap kit..."
		saferun sudo tar -zxpf ${BOOTSTRAP_TAR_IN_PATH} -C /

		success "Pkgsrc extracted."
	else
		success "Looks like you already have installed pkgin in place..."
	fi
	echo



	################################ --4-- #####################################
	## MODIFYING PATH AND MANPATH FILES SO THE SYSTEM CAN RECOGNIZE PKGIN
	option "Updating \$PATH so new binaries can be found..."

	case "$PATH" \
	in
		*/opt/pkg/bin:/opt/pkg/sbin:*) true
		;;
		*) export PATH="/opt/pkg/bin:/opt/pkg/sbin:$PATH"
		;;
	esac

	# if [ ! -f /etc/paths.d/pkgsrc ];
	# then
	# 	printf "%s\n" "/opt/pkg/bin" "/opt/pkg/sbin" | \
	# 	sudo tee -a /etc/paths.d/pkgsrc > /dev/null
	#
	# 	success "Your system's \$PATH has been updated."
	# else
	# 	success "Looks like you already have the Pkgsrc PATHS file in" \
	# 	"/etc/paths.d..."
	# fi
	# echo


	option "Updating \$MANPATH so new manpages can be found..."
	if [ ! -f /etc/manpaths.d/pkgsrc ];
	then
		printf "%s\n" "MANPATH /opt/pkg/man" "MANPATH /opt/pkg/share/man" \
		"MANPATH /opt/pkg/gnu/share/man" | \
		sudo tee -a /etc/manpaths.d/pkgsrc > /dev/null

		success "Your system's \$MANPATH has been updated."
	else
		success "Looks like you already have updated your \$MANPATH..."
	fi
	echo


	if [ -x /usr/libexec/path_helper ];
	then
		eval `/usr/libexec/path_helper -s`
	fi

	if [ -e "/opt/pkg/bin/pkgin" ];
	then
		if [ ! -f /tmp/pkgin_path ];
		then
			touch /tmp/pkgin_path
		fi
	fi

	printf "%s\n" "export PATH=\"/opt/pkg/bin:\${PATH}\"" > /tmp/pkgin_path

	success "NetBSD Pkgin has been successfully installed!"
}



# ==============================================================================

usage_pkgn() \
{
echo
echo "NetBSD Pkgin Install Script"
echo "A streamlined bootstrapper for getting pkgsrc/pkgin up and running on macOS"
echo "Originally based on @cmacrae's savemacos bootstrap script (www.github.com/cmacrae/savemacos)"
echo "Simplified version of @dievilz's pkgin4macos script (www.github.com/dievilz/pkgin4macos)"
echo
printf "SYNOPSIS:\n./%s [--install][-h] \n" "$(basename "$0")"
cat <<-'EOF'

    OPTIONS:
        --install       Download Pkgin at /opt/pkg

        -h,--help       Show this menu

    For full documentation, see: https://github.com/dievilz/punto.sh#readme
    OR https://github.com/dievilz/pkgin4macos#readme

EOF
}

main_pkgn() \
{
	case $1 in
		"-h"|"--help")
			usage_pkgn
		;;
		"--install")
			echo
			install_pkgn
		;;
		*)
			usage_pkgn
		;;
	esac
}

isMacos
isSudo

## Source helper functions
if [ -e "$HOME/.helpers" ];
then
	. "$HOME/.helpers" && success "Helper script found!"
	echo
else
	printf "%b" "\n\033[38;31mError: helper functions not found! Aborting...\033[0m\n"
	echo; exit 1
fi
