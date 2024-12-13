#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

menu_font="SF Mono"
menu_font_size="20"
menu_height="20"
set -- -i -fn "$menu_font-$menu_font_size" -l "$menu_height" -c

# Function to confirm the action
confirm_action() (
	options="🟩 yes:🟥 no"
	sep=":"
	selected_option=$(arr_to_list "$sep" "$options" | dmenu "$@")
	[ "$selected_option" = "🟩 yes" ]
)

# Main menu options
options="🟢 suspend:🔴 shutdown:🟠 reboot:🔵 logout"
sep=":"
selected_option=$(arr_to_list "$sep" "$options" | dmenu "$@")

# Validating the selected option
if ! array_includes "$sep" "$selected_option" "$options"; then
	echo "Invalid option!"
	exit 1
else
	# Passing dmenu options
	if confirm_action "$@"; then
		selected_option=$(echo "$selected_option" | cut -d" " -f2)
		"$SCRIPTS/power.sh" "$selected_option"
	else
		exit 0
	fi
fi

unset options selected_option menu_font_size menu_height menu_font sep
