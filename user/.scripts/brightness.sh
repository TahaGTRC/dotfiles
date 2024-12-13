#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

no_notif="$2"

if [ ! -d "$STATS_DIR" ]; then
	mkdir -p "$STATS_DIR"
fi

if [ ! -e "$BRIGHTNESS_STATUS_FILE" ]; then
	doas brightnessctl s 50
	echo "50" > "$BRIGHTNESS_STATUS_FILE"
fi

brightness_status=$(cat "$BRIGHTNESS_STATUS_FILE")

increase_brightness() (
	new_brightness=$((brightness_status + 5))
	if [ "$new_brightness" -le 100 ]; then
		doas brightnessctl s "$new_brightness%"
		echo "$new_brightness" > "$BRIGHTNESS_STATUS_FILE"
		[ -n "$no_notif" ] && exit
		notify "🌻  Brightness increased: $new_brightness."
	fi
)

decrease_brightness() (
	new_brightness=$((brightness_status - 5))
	if [ "$new_brightness" -ge 5 ]; then
		doas brightnessctl s "$new_brightness%"
		echo "$new_brightness" > "$BRIGHTNESS_STATUS_FILE"
		[ -n "$no_notif" ] && exit
		notify "🌻  Brightness decreased: $new_brightness."
	fi
)

case "$1" in
	increase)
		increase_brightness
		;;
	decrease)
		decrease_brightness
		;;
	*)
		echo "Usage: $0 {increase|decrease}"
		;;
esac
