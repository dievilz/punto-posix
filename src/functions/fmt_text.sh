#!/bin/bash
#
#===============================================================================
# FILE:         fmt_text.sh
#
# USAGE:        N/A (Helper script)
#
# DESCRIPTION:  Pretty-parse text streams.
#               Column-format text with ANSI formatting depending of the size of
#               the terminal at runtime.
#
# OPTIONS:      N/A (Helper script)
# REQUIREMENTS: ---
# BUGS:         ---
# NOTES:        ---
# AUTHOR(S)     Diego Villarreal, github.com/dievilz/dotfiles
# COMPANY:      ---
# VERSION:      1.0
# CREATED:      2021.11.24 - 11:22:23
# REVISION:     2021.11.24 - 11:22:23
#===============================================================================


PUNTO_SH="$(realpath "$0" | grep -Eo '^.*?\.punto-sh')" ## -o: only matching
. "$PUNTO_SH/src/functions/helpers.sh" || {
	printf "%b\n\n" "\033[38;31mError: helper functions not found! Aborting...\033[0m"
	echo; exit 1
}


print_text() {
	local txt

	## Set the current text from the original input in a temporary variable
	# txt="$1"

	## Notes: Every newline need to be next to the word before the newline!!!
	txt="${UL}${B}Welcome to pkgin4macOS!${RE}\n\n This project is an effort to make "
	# txt="pkgin4macOS!${RE}\n\n "
	txt="${txt}macOS a more comfortable system for hackers, developers & power users "
	txt="${txt}by providing fast, secure, 64-bit binary package management using the "
	txt="${txt}excellent pkgsrc from the ${UL}${B}NetBSD${RE} project!\n This script "
	txt="${txt}will set up your environment for you. It will automatically install "
	txt="${txt}pkgsrc & its associated binary package manager - pkgin, with signed "
	txt="${txt}packages, and set up your path environments so binaries and man-pages "
	txt="${txt}can be found.\n Please enter your password for sudo authentication."

	## Calculate the column size of the terminal at running time
	local COLUMNS=$(stty size | awk '{print $2}')
	echo "$COLUMNS"
	## Set the maximum spanning length for the text
	local MAXIMUM_TEXT_LENGTH=80

	#
		## Start tracking the current index of the char on the terminal
		## window. This is necessary because in the process of printing the
		## text's words, the program will know how not to span over the defined
		## maximum length or not to split words when hitting ${COLUMNS}
		local current_char_index=0

		## Divide the text to an array with the text's words as the array's
		## elements. This is necessary so the text can be printed without
		## spliting words
		IFS=' ' read -r -a text_words <<< "${txt}"

		## Start a loop for every word in the array
		for (( j = 0; j < ${#text_words[@]}; j++)); do

			local to_print="${text_words[j]}"
			local unfrmtd_word=""
			local newline_found=""
			local eol_count=
			local to_count=0

			## Look for formatting or newlines to remove it from the string
			if [[ "$to_print" == *"\033"* ]] \
			|| [[ "$to_print" == *"\x1b"* ]] \
			|| [[ "$to_print" == *"\e"* ]];
			then
				# printf "%s" "$to_print"      # nms
				unfrmtd_word="$(printf "%s" "$to_print" | sed 's/\\033\[[0-9;]*[a-zA-Z]//g')"
				# printf "%s" "$unfrmtd_word"  # nms
				unfrmtd_word="$(printf "%s" "$unfrmtd_word" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')"
				# printf "%s" "$unfrmtd_word"  # nms
				unfrmtd_word="$(printf "%s" "$unfrmtd_word" | sed 's/\e\[[0-9;]*[a-zA-Z]//g')"
				# printf "%s" "$unfrmtd_word " # nms

				# if [[ "$unfrmtd_word" == *"\n" ]]; then
				# 	# printf "%s" "$unfrmtd_word "  # nms
				# 	uneoled_word="$(printf "%s" "$unfrmtd_word" | sed 's/\\n//g')"
				# 	eol_count="$(printf "%s" "$unfrmtd_word" | grep -Fo '\n' | wc -l)"
				# 	# printf "%s" "$uneoled_word "  # nms
				# 	# printf "%s" "$eol_count "     # nms
				# fi
			fi

			if [[ "$to_print" == *"\n" ]] && [ -z "$eol_count" ];
			then
				# printf "%s" "$to_print "        # nms
				uneoled_word="$(printf "%s" "$to_print" | sed 's/\\n//g')"
				eol_count="$(printf "%s" "$to_print" | grep -Fo '\n' | wc -l)"
				# printf "%s" "$uneoled_word "    # nms
				# printf "%s" "$eol_count "       # nms
			fi

			if [ -n "$eol_count" ];
			then
				to_count="${#uneoled_word}"
				to_print="$uneoled_word"
				# printf "'%s'" "$uneoled_word" # nms
				# printf "%s" "$eol_count"      # nms
				# printf -- "%s a " "$to_count" # nmss
			elif [ -n "$unfrmtd_word" ];
			then
				to_count="${#unfrmtd_word}"
				# printf "%s" "$unfrmtd_word"   # nms
				# printf -- "%s b " "$to_count" # nmss
			else
				to_count="${#to_print}"
				# printf "%s" "$to_print"       # nms
				# printf -- "%s c " "$to_count" # nmss
			fi

			# printf -- "-%s-" "$to_count"

			## We update the current char index before actually printing the
			## next word in the text because of the condition right afterwards
			current_char_index=$((current_char_index + to_count))


			if [ "${current_char_index}" -le "${COLUMNS}" ] \
			&& [ "${current_char_index}" -le "${MAXIMUM_TEXT_LENGTH}" ];
			then
				printf -- "%b" "$to_print"
				# printf -- "%s" "$to_print"
				# printf -- "%s" "$to_count"

				# printf "$current_char_index" ## DEBUGGING PURPOSES

				current_char_index=$((current_char_index + 1))

				if [ -n "$eol_count" ];
				then
					for (( i = 0; i < eol_count; i++ )); do
						# printf -- "*%s" "$eol_count"
						printf -- '\n'
					done

					current_char_index=0

				elif [ "${current_char_index}" -lt "${COLUMNS}" ] \
				  && [ "${current_char_index}" -lt "${MAXIMUM_TEXT_LENGTH}" ];
				then
					printf -- " "
					true
				else
					printf -- '\n'

					printf -- '%b ' "$to_print"

					current_char_index=1
					true
				fi

			else
				printf -- '\n'

				printf -- '%b ' "$to_print"

				current_char_index=$((1 + to_count))
				true
			fi

			##
			## word isntall repeats itself two times
			##
			##


			## print a new line between every option and its text
			# printf "$current_char_index" ## DEBUGGING PURPOSES
		done
	#
	## Always print a new line at the end
	printf "%b\n" "${RE}"
}

print_text "$@"
