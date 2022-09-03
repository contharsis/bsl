#!/bin/bash

bsl() {
	declare cmd="$1"
	
	# bsl ch config n choice 
	if [ "$cmd" = 'ch' ]; then
		declare file="$(echo "$2" | sed -n "s/.*\///p" | sed -n "s/.*/\U&/p")"
		declare default_choice="$3"
		declare result="$4"
		
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
	fi

	# bsl fch <file, full path, /home/jordan/.config/gpt/config> <type, f:d> <default_choice, y or n>
	if [ "$cmd" = 'fch' ]; then
		declare file="$2"
		declare filename="$(echo "$2" | sed -n "s/.*\///p")"
		declare type="$3"
		declare default_choice="$4"
		
		declare choice=''
		declare create_file=''

		if [ "$type" = 'f' ]; then
			if [ -f "$file" ]; then
				echo "WARNING: Found $filename with content:"
                        	echo "------- START -------"
                        	cat "$file"
                        	echo "-------  END  -------"
				
				bsl ch "$file" "$default_choice" choice
				
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
	fi
}
