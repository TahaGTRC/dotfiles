#!/usr/bin/env sh

# Define the JSON file
. "$SCRIPTS/functions.sh"

JSON_FILE="$SCRIPTS/data/emojis.json"

menu_font="SF Mono"
menu_font_size="12.5"
menu_height="12"
set -- -i -fn "$menu_font-$menu_font_size" -l "$menu_height" -c

# Function to generate the list of emojis
show_emojis() {
	jq -r '.[] | to_entries[] | "\(.key) - \(.value)"' "$JSON_FILE"
}

selected=$(show_emojis | dmenu "$@")

if [ -z "$selected" ]; then
	exit 1
fi

# Extract only the emoji part (text before the ' - ')
emoji=$(echo "$selected" | cut -d ' ' -f 1)

printf "%s" "$emoji" | xclip -selection clipboard

unset selected menu_font menu_font_size menu_height
