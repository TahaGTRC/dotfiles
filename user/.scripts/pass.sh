#!/usr/bin/env sh
. "$SCRIPTS/functions.sh"

temp_file=$(mktemp)
passes=$(ls ~/.password-store/)

# One level nesting is currently supported
for dir in $passes; do
	direct="$HOME/.password-store/$dir"
	elements=$(ls "$direct/")
	for element in $elements; do
		element=$(basename "$element" ".gpg")
		echo "$dir/$element" >> "$temp_file"
	done
done

menu_font="SF Mono"
menu_font_size="14.5"
menu_height="12"

set -- -i -fn "$menu_font-$menu_font_size" -l "$menu_height" -c
target=$(dmenu "$@" < "$temp_file")

if [ -n "$target" ]; then
	pass show -c "$target"
else
	exit 1
fi

# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
	notify "📋  Password copied successfully."
else
	notify "❌  Failed to copy password."
fi

unset target menu_font menu_font_size menu_height temp_file passes direct elements element
