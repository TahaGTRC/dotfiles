#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

menu_font="SF Mono"
menu_font_size="20"
menu_height="20"
set -- -i -fn "$menu_font-$menu_font_size" -l "$menu_height" -c

confirm_action() (
	options="🟩 yes:🟥 no"
	sep=":"
	selected_option=$(arr_to_list "$sep" "$options" | dmenu "$@")
	[ "$selected_option" = "🟩 yes" ]
)

# These words are arguments for the power.sh file
# which is responsible for taking the correct action
# based on the provided argument
options="🟢 suspend:🔴 shutdown:🟠 reboot:🔵 logout"
sep=":"
selected_option=$(arr_to_list "$sep" "$options" | dmenu "$@")

if ! array_includes "$sep" "$selected_option" "$options"; then
	echo "Invalid option!"
	exit 1
else
	if confirm_action "$@"; then
		selected_option=$(echo "$selected_option" | cut -d" " -f2)
		"$SCRIPTS/power.sh" "$selected_option"
	else
		exit 0
	fi
fi

unset options selected_option menu_font_size menu_height menu_font sep
