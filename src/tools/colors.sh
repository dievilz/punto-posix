#!/bin/bash
#
# Print colors


## Exporting PUNTO_SH location to source helper functions
PUNTO_SH="$(realpath "$0" | grep -Eo '^.*?\.punto-sh')" ## -o: only matching
. "$PUNTO_SH/src/functions/helpers.sh" || {
	printf "%b\n\n" "\033[38;31mError: helper functions not found! Aborting...\033[0m"
	echo; exit 1
}


usage() {
	echo
	echo "Print colors :P"
	printf "Usage: ./%s <option> \n" "$(basename "$0")"
	cat <<-'EOF'

	Commands:
		colors16          Display a lot of possible combination of ANSI attributes
		colors256         Display the 256 colors available
		truecolors        Display True Colors gamut
		-h,--help    Show this menu

	Without any arguments, all aspects will be executed (in the above order)

	EOF
}

colors16() {
	# Background
	for clbg in {40..47} {100..107} 49 ; do
		# Foreground
		for clfg in {30..37} {90..97} 39 ; do
			# Formatting
			for attr in 0 1 2 4 5 7 ; do
				# Print the result
				printf "\033[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \033[0m"
			done
			echo # New line
		done
	done
}

colors256() {
	for fgbg in 38 48 ; do # Foreground / Background
		for color in {0..255} ; do # Colors
			# Display the color
			printf "\033[${fgbg};5;%sm  %3s  \033[0m" "$color" "$color"
			# Display 6 colors per lines
			if [ $((($color + 1) % 6)) = 4 ] ; then
				echo # New line
			fi
		done
		echo # New line
	done
}

truecolors() {
	awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
	  s="/\\";
	  for (colnum = 0; colnum<term_cols; colnum++) {
	    r = 255-(colnum*255/term_cols);
	    g = (colnum*510/term_cols);
	    b = (colnum*255/term_cols);
	    if (g>255) g = 510-g;
	    printf "\033[48;2;%d;%d;%dm", r,g,b;
	    printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
	    printf "%s\033[0m", substr(s,colnum%2+1,1);
	  }
	  printf "\n";
	}'
}

main() {
	case $1 in
		"-h"|"--help")
			usage
			exit 0
		;;
		"colors16")
			echo; colors16
		;;
		"colors256")
			echo; colors256
		;;
		"truecolors")
			echo; truecolors
		;;
		"")
			echo; bold "${B}–-->  Showing colors..."

			echo
			colors16
			colors256
			truecolors

			echo
		;;
		*)
			usage
			return 127
		;;
	esac
}

main "$@"; exit
