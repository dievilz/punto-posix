#!/bin/bash
#
# Punto Dotfiles Manager Uninstall Script (ShellScript version)
# Shameless ripoff of the Oh-My-Zsh uninstall script ¯\_(ツ)_/¯
#
# By Diego Villarreal, @dievilz in GitHub (https://github.com/dievilz)


## Exporting PUNTO_SH location to source helper functions
PUNTO_SH="$(realpath "$0" | grep -Eo '^.*?\.punto-sh')" ## -o: only matching
. "$PUNTO_SH/src/functions/helpers.sh" || {
	printf "%b\n\n" "\033[38;31mError: helper functions not found! Aborting...\033[0m"
	echo; exit 1
}

echo
printf "%b" "\033[38;31m==> Are you sure you want to remove your Dotfiles? " \
"['Y'|'n'|'skip/none/Enter' to halt]: \033[0m"
read -r resp
echo
case $resp in
	y|Y|yes|Yes)
		printf "%b\n" "\033[38;31m==> Uninstall confirmed...\033[0m"
	;;
	n|N|no|No|"skip"|"none"|"")
		printf "%b\n" "\033[38;33m==> Uninstall cancelled.\033[0m"
		exit 0
	;;
	*)
		printf "%b\n" "\033[38;31m==> Invalid choice. Aborting...\033[0m"
		exit 126
	;;
esac

zsh "$PUNTO_SH"/sync.sh --remove

zsh "$PUNTO_SH"/zshell.sh zshrc --uninstall

printf "%b\n" "\033[1mRemoving ${PUNTO_SH}...\033[0m"
if [ -d "$PUNTO_SH" ]; then
	trash "$PUNTO_SH"
fi
echo
printf "%b\n" "\033[1mRemoving ${DOTFILES}...\033[0m"
if [ -d "$DOTFILES" ]; then
	trash "$DOTFILES"
fi

echo; printf "%b" "\033[38;32m==> Thanks for trying out Punto Dotfiles " \
"Manager (ShellScript Version) and @dievilz Dotfiles. They have been uninstalled.\033[0m\n"
printf "%b" "\033[38;32m==> Don't forget to restart your terminal!\033[0m\n"
echo
cd "$HOME"
