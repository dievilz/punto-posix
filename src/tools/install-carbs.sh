#!/bin/sh

echo
echo "Welcome to Carbs Linux Bootstrapper by @dievilz"
echo

fstpart_installcarbs() \
{
	URL="https://dl.carbslinux.org/releases/x86_64"
	PUBKEY="carbslinux-2021.08.pub"

	       [ ! -e "$PWD/carbs-rootfs.tar.xz" ] && wget "$URL"/carbs-rootfs.tar.xz
	[ ! -e "$PWD/carbs-rootfs.tar.xz.sha256" ] && wget "$URL"/carbs-rootfs.tar.xz.sha256
	   [ ! -e "$PWD/carbs-rootfs.tar.xz.sig" ] && wget "$URL"/carbs-rootfs.tar.xz.sig
	                   [ ! -e "$PWD/$PUBKEY" ] && wget https://dl.carbslinux.org/keys/"$PUBKEY"

	echo "--- Verifying files ----------------"
	echo

	cat carbs-rootfs.tar.xz.sha256
	echo
	cat carbs-rootfs.tar.xz.sig
	#   untrusted comment: verify with carbslinux-2021.08.pub
	# RWTK4GFDD7JiohUHBeJXuKw+/P3K4ZRR8jQud0iOxNDbn7WCFxQsxt9FUNSEiXfLjkm1Ez8c3esRG8oydrsFUFpBGtekFt5obgo=
	echo

	sha256sum -c carbs-rootfs.tar.xz.sha256
	echo

	signify -V -m carbs-rootfs.tar.xz -p "$PUBKEY"
	echo
}

sndpart_installcarbs() \
{
	echo "Mkdir-ing /mnt/carbs"
	[ ! -d /mnt/carbs ] && mkdir -pv /mnt/carbs
	echo

	lsblk -af
	printf "%b" "Type the complete device name to mount rootfs (including the '/dev/' part): "
	read -r dev

	[ ! -e "$dev" ] && return
	mount -v "$dev" /mnt/carbs
	echo

	echo "Untar-ing rootfs to /mnt/carbs"
	tar xf carbs-rootfs.tar.xz -C /mnt/carbs
	echo

	[ ! -d /mnt/carbs/root ] && return
	[ ! -e /mnt/carbs/root/.aliases ] && curl -o "/mnt/carbs/root/.aliases" https://raw.githubusercontent.com/dievilz/dotfiles/master/root/home/aliases
	[ ! -e /mnt/carbs/root/.functions ] && curl -o "/mnt/carbs/root/.functions" https://raw.githubusercontent.com/dievilz/dotfiles/master/root/home/functions
	[ ! -e /mnt/carbs/root/.profile ] && curl -o "/mnt/carbs/root/.profile" https://raw.githubusercontent.com/dievilz/dotfiles/master/root/home/profile
	[ ! -e /mnt/carbs/root/zsh.prompt ] && curl -o "/mnt/carbs/root/zsh.prompt" https://raw.githubusercontent.com/dievilz/punto.sh/master/zsh.prompt
	[ ! -e /mnt/carbs/root/chroot-carbs.sh ] && curl -o "/mnt/carbs/root/chroot-carbs.sh" https://raw.githubusercontent.com/dievilz/punto.sh/master/chroot-carbs.sh
	echo

	echo 'Now do: "/mnt/carbs/bin/cpt-chroot /mnt"'
	echo 'then "./chroot-carbs.sh"'
}

main_installcarbs() \
{
	case "$1" \
	in
		"1"|"-1"|"--first")
			fstpart_installcarbs
		;;
		"2"|"-2"|"--second")
			sndpart_installcarbs
		;;
		*)
			echo "Unknown option! Use -h/--help"
			return 127
		;;
	esac
}

main_installcarbs "$@"; exit
