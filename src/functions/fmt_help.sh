#!/bin/bash
#
#===============================================================================
# FILE:         fmt_help.sh
#
# USAGE:        N/A (Helper script)
#
# DESCRIPTION:  Pretty-parse command help section.
#               Column-format options and their descriptions depending of the
#               size of the terminal at runtime.
#
# OPTIONS:      N/A (Helper script)
# REQUIREMENTS: ---
# BUGS:         ---
# NOTES:        ---
# AUTHOR(S)     Doron Behar, stackoverflow.com/a/50452281/14019137
#               Adapted by Diego Villarreal, github.com/dievilz/dotfiles
# COMPANY:      ---
# VERSION:      1.0
# CREATED:      2020.12.17 - 00:24:??
# REVISION:     2020.12.17 - 00:24:??
#===============================================================================


PUNTO_SH="$(realpath "$0" | grep -Eo '^.*?\.punto-sh')" ## -o: only matching
. "$PUNTO_SH/src/functions/helpers.sh" || {
	printf "%b\n\n" "\033[38;31mError: helper functions not found! Aborting...\033[0m"
	echo; exit 1
}


print_help() {
	# local title
	# local usage
	# local options
	# local descriptions

	# ## Set the original input in a temporary variable
	# title="$1"
	# usage="$2"
	# options="$3"
	# descriptions="$4"

	## Set the options
	local options=(
		'-c,--config <FILE>'
		'-l,--list'
		'-r,--run'
		'-v,--verbose'
		'-n,--dry-run'
		'-h,--help'
	)
	## Set the corresponding descriptions for every option
	local descriptions=(
		"Use the given configuration file instead of the default one"
		"List all program related files. if used with \`--verbose\`, the full contents are printed"
		"Try to process all the files"
		"Turn on verbose output"
		"Don't store files like always but show only what actions would have been taken if $(basename "$0") would have run normally (with or without --run), implies --verbose"
		"Display help"
	)

	## Calculate the column size of the terminal at running time
	local COLUMNS=$(stty size | awk '{print $2}')
	## Set the offset (whitespace printed) for the options
	local OPTIONS_OFFSET=4
	## Set the offset (whitespace printed) for the descriptions
	local DESCRIPTIONS_OFFSET=5
	## Set the maximum spanning length for the descriptions
	local MAXIMUM_DESCRIPTIONS_LENGTH=80

	## =================== Here finishes the configuration ======================

	## In the next loop, the length of the option with most words is saved
	## in $max_option_length. This way, the offset can be calculated when
	## printing long descriptions that should span over several lines.
	local max_option_length=1
	for (( i = 0; i < ${#options[@]}; i++));
	do
		if [ "$max_option_length" -lt ${#options[$i]} ]; then
			max_option_length=${#options[$i]}   # -c,--config <FILE>' with 18chr
		fi
	done

	## Set the total offset of descriptions after new-lines.
	local newline_descriptions_offset=$((${max_option_length} + \
		OPTIONS_OFFSET + DESCRIPTIONS_OFFSET))
	## In this case, 26 chars

	## The next loop is where the options with their
	## corresponding descriptions are actually printed
	for (( i = 0; i < ${#options[@]}; i++));
	do
		## First, print the offset chosen and the option
		printf -- '%*s' ${OPTIONS_OFFSET}
		printf -- '%s' "${options[$i]}"

		## Start tracking the current index of the char on the terminal
		## window. This is necessary because in the process of printing the
		## text's words, the program will know how not to span over the defined
		## maximum length or not to split words when hitting ${COLUMNS}
		local current_char_index=$((OPTIONS_OFFSET + ${#options[$i]}))

		## Calculate the offset which should be given between the current
		## option and the start of its description. This is different for every
		## option because every option has a different length but they all must
		## be aligned according to the longest option length and the offsets
		local current_description_offset=$((${max_option_length} - \
			${#options[$i]} + DESCRIPTIONS_OFFSET))

		## Print this offset before printing the description
		printf -- '%*s' ${current_description_offset}

		## Updating the current_char_index
		current_char_index=$((current_char_index + current_description_offset))

		## Put the current text from the original var in a temporary variable
		local current_description="${descriptions[$i]}"

		## Divide $current_description to an array with the description's words
		## as the array's elements. This is necessary so the text can be printed
		## without spliting words
		IFS=' ' read -r -a description_words <<< "${current_description}"

		## Start a loop for every word in the array
		for (( j = 0; j < ${#description_words[@]}; j++));
		do
			## Update the current char index before actually printing the next
			## word in the description because of the condition right afterwards
			current_char_index=$((current_char_index + ${#description_words[$j]} + 1))

			## Check if the index to be reached will hit the number of ${COLUMNS}
			## in the terminal or the defined maximum limit
			if [ "${current_char_index}" -lt "${COLUMNS}" ] \
			&& [ "${current_char_index}" -lt "${MAXIMUM_DESCRIPTIONS_LENGTH}" ];
			then
				## If we don't hit our limit, print the current word
				printf -- '%s ' "${description_words[$j]}"

			else
				## If we've hit our limit, print a new line
				printf -- '\n'

				## Print a number of spaces equals to the offset we need to give
				## according to longest option we have and the other offsets we
				## defined above
				printf -- '%*s' ${newline_descriptions_offset}

				## Print the next word in the new line
				printf -- '%s ' "${description_words[$j]}"

				## Update the current char index
				current_char_index=$((newline_descriptions_offset + ${#description_words[$j]}))
			fi
		done
		## print a new line between every option and its description
		printf '\n'
	done
	## Always print a new line at the end
	printf "%b\n" "${RE}"
}

print_help "$@"
