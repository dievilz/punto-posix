#!/bin/sh

echo
echo "Welcome to Carbs Linux Chroot Bootstrapper by @dievilz"
echo

fstpart_chrootcarbs() \
{
	source "$HOME/.profile"

	[ ! -d /distro/cpt/repos ] && mkdir -pv /distro/cpt/repos

	git clone git://git.carbslinux.org/repository /distro/cpt/repos

	[ -z $CPT_PATH ] && export CPT_PATH="/distro/cpt/repos/core:/distro/cpt/repos/extra:/distro/cpt/repos/xorg:/distro/cpt/repos/community"

	cpt-update && cpt-update

	cpt b libelf ncurses grub carbs-init zsh

	echo "dievilzCarbs" > /etc/hostname

	adduser admin
	adduser dievilz

	addgroup admin wheel
	echo

	mv -v /etc/shells /etc/shells.bak
	echo /usr/bin/zsh > /etc/shells

	[ ! -d /etc/doas.conf ] && curl -o /etc/doas.conf https://raw.githubusercontent.com/dievilz/dotfiles/master/root/etc/doas-linux.conf
	echo

	echo "Now run zsh and source .profile, .aliases, .functions and zsh.prompt"
	echo 'And then "./chroot-carbs.sh 2"'
}

sndpart_chrootcarbs() \
{
	[ ! -d /usr/src ] && mkdir -pv /usr/src && cd /usr/src
	[ ! -e /usr/src/linux-5.10.157.tar.xz ] && \
	wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.157.tar.xz

	[ ! -d "/usr/src/linux-5.10.157" ] && tar xvJf linux-5.10.157.tar.xz
	cd linux-5.10.157

	[ ! -e "/usr/src/linux-5.10.157/kernel-no-perl.patch" ] && \
	wget https://dl.carbslinux.org/distfiles/kernel-no-perl.patch
	patch -p1 < kernel-no-perl.patch

	printf "%b" "Do you want to configure and compile the kernel? [Y|n,'Enter']: "
	read -r skipper

	case $skipper \
	in
		"y"|"Y"|"yes"|"Yes")
			make menuconfig
			make
			install -Dm755 $(make -s image_name) /boot/vmlinuz-linux
		;;
	esac
	echo

	# printf "%b" "Do you want to configure and install GRUB? [Y|n,'Enter']: "
	# read -r skipper

	# case $skipper \
	# in
	# 	"y"|"Y"|"yes"|"Yes")
	# 		case $(ls /sys/firmware/efi/efivars) \
	# 		in
	# 			"")
	# 				lsblk -af
	# 				printf "%b" "Type the complete device name to install GRUB (including the '/dev/' part): "
	# 				read -r devv

	# 				[ ! -e "$devv" ] && return
	# 				grub-install "$devv"
	# 			;;
	# 			*) grub-install --target=x86_64-efi --efi-directory=/boot/efi ;;
	# 		esac
	# 	;;
	# esac
	# echo

	# [ ! -e "/boot/grub/custom.cfg" ] && \
	# curl -o /boot/grub/custom.cfg https://raw.githubusercontent.com/dievilz/dotfiles/master/root/boot/grub/custom.cfg

	# grub-mkconfig -o /boot/grub/grub.cfg
}

main_chrootcarbs() \
{
	case "$1" \
	in
		"1"|"-1"|"--first")
			fstpart_chrootcarbs
		;;
		"2"|"-2"|"--second")
			sndpart_chrootcarbsinst
		;;
		*)
			echo "Unknown option! Use -h/--help"
			return 127
		;;
	esac
}

main_chrootcarbs "$@"; exit
