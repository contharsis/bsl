#!/bin/bash

ch() {
	declare file="$(echo "$1" | sed -n "s/.*\///p" | sed -n "s/.*/\U&/p")"
	declare default_choice="$2"
	declare result="$3"

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

	eval $result="'$user_choice'"
}

fch() {
	declare file="$1"
	declare filename="$(echo "$1" | sed -n "s/.*\///p")"
	declare type="$2"
	declare default_choice="$3"

	declare choice=''
	declare create_file=''

	if [ "$type" = 'f' ]; then
		if [ -f "$file" ]; then
			echo "WARNING: Found $filename with content:"
			echo "------- START -------"
			cat "$file"
			echo "-------  END  -------"

			ch "$file" "$default_choice" choice

			if [ "$choice" = 'y' ]; then
				rm "$file"
				echo "Deleted $filename at $file"
				create_file='y'
			fi
		else
			create_file='y'
		fi

		if [ "$create_file" = 'y' ]; then
			touch "$file"
			echo "Created $filename at $file"
		fi
	fi

	if [ "$type" = 'd' ]; then
		if [ ! -d "$file" ]; then
			mkdir -p "$file"
			echo "Created filepath at $file"
		fi
	fi
}


# WIP
ifch() {
	declare init_command="$1"
	declare missing_file='n'

	shift 1
	for arg in "$@"
	do
		if [ ! -f "$arg" ]; then
			missing_file='y'
			break
		fi
	done

	echo "Some config files don't exist, use $init_command to create them"
}

"$@"
