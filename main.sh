#!/bin/bash

if [ "$bsl_imported" = 'y' ]; then
	return 0
fi

declare bsl_terminal_output="$(tty)"

# output to terminal
# bsl_o <text>
bsl_o() {
	if [ "$2" = "space" ]; then
		echo > "$bsl_terminal_output"
	fi

	echo "$1" > "$bsl_terminal_output"

	if [ "$2" = "space" ]; then
		echo > "$bsl_terminal_output"
	fi
}

# get file name from file path
# bsl_gfn <reference> <full file path>
bsl_gfn() {
	declare -n reference="$1"
	
	reference="$(echo "$2" | sed "s/.*\///")"
}

# choice - user chooses whether to overwrite the current existing file with empty one
# bsl_ch <reference> <full file path> <default choice>
bsl_ch() {
	declare -n reference="$1"
	
	declare file_name=''
	bsl_gfn file_name "$2"

	declare default_choice="$3"
	declare choice=''

	while true; do
		read -p "Proceed with overwriting it? (DELETES CURRENT $file_name PERMANENTLY) [Y/n]: " choice

		if [ "$choice" = '' ]; then
			choice="$default_choice"
		fi

		if [ "$choice" = 'y' ] || [ "$choice" = 'n' ]; then
			break
		fi

		bsl_o "Invalid option, pick either yes or no" "space"
	done

	reference="$choice"
}

# !!!!!!!!!!!!!!!!!!!!!!! UNTIll HERE !!!!!!!!!!!!!!!!!!!!!!!

# file check - check whether 
# bsl_fch <file path> <type> <default choice>
bsl_fch() {
	declare file="$1"
	declare filename="$(echo "$1" | sed -n "s/.*\///p")"
	declare type="$2"
	declare default_choice="$3"

	declare choice=''
	declare create_file='n'

	if [ "$type" = 'f' ]; then
		if [ -f "$file" ]; then
			echo "WARNING: Found $filename with content:" > "$bsl_terminal_output"
			echo "------- START -------" > "$bsl_terminal_output"
			cat "$file"
			echo "-------  END  -------" > "$bsl_terminal_output"

			choice=$(bsl_ch "$file" "$default_choice")

			if [ "$choice" = 'y' ]; then
				rm "$file"
				echo "Deleted $filename file at $file" > "$bsl_terminal_output"
				create_file='y'
			fi
		else
			create_file='y'
		fi

		if [ "$create_file" = 'y' ]; then
			touch "$file"
			echo "Created $filename file at $file" > "$bsl_terminal_output"
		fi
	fi

	if [ "$type" = 'd' ]; then
		if [ ! -d "$file" ]; then
			mkdir -p "$file"
			echo "Created directory path at $file" > "$bsl_terminal_output"
		fi
	fi
}

# Invalid file check
# bsl_ifch <array of files> <array of file types> <init command> <current command>
bsl_ifch() {
	declare -a files=($1)
	declare -a file_types=($2)
	declare init_command="$3"
	declare current_command="$4"

	declare missing_file='n'
	declare -i counter=0

	if [ "$current_command" = "$init_command" ]; then
		echo "$missing_file"
		return 1
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
		echo "Some config files don't exist, use '$init_command' to create them"  > "$bsl_terminal_output"
	fi
	
	echo "$missing_file"
}

# Find string
# bsl_fstr <array of strings> <string>
bsl_fstr() {
	declare -a strings=($1)
	declare  searched_string="$2"

	declare found_string='n'
	
	if [[ " ${strings[*]} " =~ " $searched_string " ]]; then
        	found_string='y'
	fi

	echo "$found_string"
}

# Command not found message
# bsl_cmdnfm <command> <help command>
bsl_cmdnfm() {
	declare command="$1"
	declare help_command="$2"

	echo "ERROR: Command '$command' not found, use '$help_command' to list commands" > "$bsl_terminal_output"
}

declare bsl_imported='y'
