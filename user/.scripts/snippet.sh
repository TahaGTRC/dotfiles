#!/usr/bin/env sh

j_file="$SCRIPTS/data/snippets.json"
data=$(jq -r '.[] | "\(.language) - \(.title)"' "$j_file")

menu_font="Fira Code"
menu_font_size="12.5"
menu_height="12"
set -- -i -fn "$menu_font-$menu_font_size" -l "$menu_height" -c

chosen=$(echo "$data" | dmenu "$@")

if [ -n "$chosen" ]; then
	# Extract the index of the chosen item
	index=$(echo "$data" | grep -nF "$chosen" | cut -d: -f1)
	value=$(jq -r ".[$((index - 1))].code" "$j_file")
	printf "%s" "$value" | xclip -selection clipboard
else
	echo "No selection made."
fi

unset menu_font menu_font_size menu_height data index value chosen j_file
