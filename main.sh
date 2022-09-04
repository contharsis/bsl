#!/bin/bash

declare terminal_output=$(tty)

# Choice
# bsl ch <file full path> <default choice>
ch() {
	declare file="$(echo "$1" | sed -n "s/.*\///p" | sed -n "s/.*/\U&/p")"
	declare default_choice="$2"

	declare user_choice=''

	while true; do
		read -p "Proceed with overwriting it? (DELETES CURRENT $file PERMANENTLY) (y/n, default is $default_choice): " user_choice

		if [ "$user_choice" = '' ]; then
			user_choice="$default_choice"
		fi

		if [ "$user_choice" = 'y' ] || [ "$user_choice" = 'n' ]; then
			break
		fi
	done

	echo "$user_choice"
}

# File check
# bsl fch <file path> <type> <default choice>
fch() {
	declare file="$1"
	declare filename="$(echo "$1" | sed -n "s/.*\///p")"
	declare type="$2"
	declare default_choice="$3"

	declare choice=''
	declare create_file='n'

	if [ "$type" = 'f' ]; then
		if [ -f "$file" ]; then
			echo "WARNING: Found $filename with content:" > "$terminal_output"
			echo "------- START -------" > "$terminal_output"
			cat "$file"
			echo "-------  END  -------" > "$terminal_output"

			choice=$(ch "$file" "$default_choice")

			if [ "$choice" = 'y' ]; then
				rm "$file"
				echo "Deleted $filename at $file" > "$terminal_output"
				create_file='y'
			fi
		else
			create_file='y'
		fi

		if [ "$create_file" = 'y' ]; then
			touch "$file"
			echo "Created $filename at $file" > "$terminal_output"
		fi
	fi

	if [ "$type" = 'd' ]; then
		if [ ! -d "$file" ]; then
			mkdir -p "$file"
			echo "Created filepath at $file" > "$terminal_output"
		fi
	fi
}

# Invalid file check
# bsl ifch <array of files> <array of file types> <init command> <current command>
ifch() {
	declare -a files=($1)
	declare -a file_types=($2)
	declare init_command="$3"
	declare current_command="$4"

	declare missing_file='n'
	declare -i counter=0

	if [ "$current_command" = "$init_command" ]; then
		echo "$missing_file"
		return 0
	fi
	
	for file in "${files[@]}"; do
		if [ "${file_types[$counter]}" = 'f' ]; then
			if [ ! -f "$file" ]; then
				missing_file='y'
				break
			fi
		fi

		if [ "${file_types[$counter]}" = 'd' ]; then
			if [ ! -d "$file" ]; then
				missing_file='y'
				break
			fi
		fi

		counter=$(( counter + 1 ))
	done
	
	if [ "$missing_file" = 'y' ]; then
		echo "Some config files don't exist, use '$init_command' to create them"  > "$terminal_output"
	fi
	
	echo "$missing_file"
}

# Find string
# bsl fstr <array of strings> <string>
fstr() {
	declare -a strings=($1)
	declare  searched_string="$2"

	declare found_string='n'
	
	if [[ " ${strings[*]} " =~ " $searched_string " ]]; then
        	found_string='y'
	fi

	echo "$found_string"
}

# Command not found message
# bsl cmdnfm <command> <help command>
cmdnfm() {
	declare command="$1"
	declare help_command="$2"

	echo "ERROR: Command '$command' not found, use '$help_command' to list commands" > "$terminal_output"
}

"$@"
