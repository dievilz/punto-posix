#!/bin/bash
#
# Dievilz's GateKeeper Helper (enhanced from TNT's NMac GK Helper)


## Exporting PUNTO_SH location to source helper functions
if command -v fd > /dev/null 2>&1;
then
  PUNTO_SH="$(fd -g ".punto-sh" "$HOME" -HI --maxdepth 3 --type d -E "Library" --max-results 1)"
else
  PUNTO_SH="$(find "$HOME" -maxdepth 3 -name ".punto-sh" -type d -print0 -quit 2> /dev/null)"
fi
. "$PUNTO_SH/src/functions/helpers.sh" || {
	printf "%b\n\n" "\033[38;31mError: helper functions not found! Aborting...\033[0m"
	echo; exit 1
}


usage_gatekeeper() {
echo
echo "GateKeeper Helper Script"
echo "Brought to you by NMac.to and enhanced by @dievilz."
echo
printf "SYNOPSIS: ./%s [-b][-d][-e][-h][-s] \n" "$(basename "$0")"
cat <<-'EOF'

OPTIONS:
    -d, --disable     Disable GateKeeper (Good for Professional Users)
    -e, --enable      Enable GateKeeper (Good for New Users)
    -b, --bypass      If you don't want to completely disable GateKeeper,
                      then allow an individual app to pass it (Recommended
                      For All Users)
    -s, --self-sign     If you don't want to disable SIP and your app is quite
                      unexpectedly under the recent macOS, then try to self-
                      sign your app using this option
    -h,--help    Show this menu

EOF
}

main_gatekeeper() {
	case $1 in
		"-h"|"--help")
			usage_gatekeeper
			exit 0
		;;
		"-d"|"--disable")
			echo
			printf "%b\n" "${OA} Disable GateKeeper selected.${RE}"
			echo
			printf "%b\n" "${Y}--> Please insert your password to proceed:${RE}"
			saferun sudo spctl --master-disable
		;;
		"-e"|"--enable")
			echo
			printf "%b\n" "${OA} Enable GateKeeper selected.${RE}"
			echo
			printf "%b\n" "${Y}--> Please insert your password to proceed:${RE}"
			saferun sudo spctl --master-enable
		;;
		"-b"|"--bypass")
			echo
			printf "%b\n" "${OA} Allow Single-App to Bypass GateKeeper selected.${RE}"
			echo
			printf "%b" "${Y}--> Drag & drop the app here, then hit Return: ${RE}"
			read -r FILEPATH
			echo
			printf "%b\n" "${Y}--> Please insert your password to proceed:${RE}"
			saferun sudo xattr -rd com.apple.quarantine "${FILEPATH}"
		;;
		"-s"|"--self-sign")
			echo
			printf "%b\n" "${OA} Self-Sign an App selected${RE}"
			echo
			printf "%b" "${Y}--> Drag & drop the app here, then hit Return: ${RE}"
			read -r FILEPATH
			echo
			printf "%b\n" "${Y}--> Please insert your password to proceed:${RE}"

			if saferun sudo codesign -f -s - --deep "${FILEPATH}"; then
				echo; printf "%b\n" "${G}--> If you see \"Replacing existing signature\" means you are DONE!${RE}"
			else
				echo; printf "%b\n" "${R}--> There is something wrong with the app or its path.${RE}"
			fi
			echo
		;;
		*)
			usage_gatekeeper
			return 127
		;;
	esac
}

main_gatekeeper "$@"; exit
