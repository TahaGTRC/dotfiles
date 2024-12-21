#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

no_notif="$2"

if [ ! -d "$STATS_DIR" ]; then
	mkdir -p "$STATS_DIR"
fi

if [ ! -e "$VOLUME_STATUS_FILE" ]; then
	pactl set-sink-volume @DEFAULT_SINK@ 50% 1> /dev/null
	echo "50" > "$VOLUME_STATUS_FILE"
fi

audio_status=$(cat "$VOLUME_STATUS_FILE")

increase_volume() (
	pactl set-sink-volume @DEFAULT_SINK@ +5% 1> /dev/null
	new_volume=$((audio_status + 5))
	echo "$new_volume" > "$VOLUME_STATUS_FILE"
	[ -n "$no_notif" ] && exit
	notify "🔊  Speaker volume increased: $new_volume."
)

decrease_volume() (
	new_volume=$((audio_status - 5))
	if [ "$new_volume" -lt 0 ]; then
		new_volume=0
		pactl set-sink-volume @DEFAULT_SINK@ 0% 1> /dev/null
	else
		pactl set-sink-volume @DEFAULT_SINK@ -5% 1> /dev/null
	fi
	echo "$new_volume" > "$VOLUME_STATUS_FILE"
	[ -n "$no_notif" ] && exit
	notify "🔊  Speaker volume decreased: $new_volume."
)

mute_volume() {
	pactl set-sink-volume @DEFAULT_SINK@ 0% 1> /dev/null
	echo "0" > "$VOLUME_STATUS_FILE"
	[ -n "$no_notif" ] && exit
	notify "🔊  Speaker volume muted."
}

unmute_volume() {
	pactl set-sink-volume @DEFAULT_SINK@ 50% 1> /dev/null
	echo "50" > "$VOLUME_STATUS_FILE"
	[ -n "$no_notif" ] && exit
	notify "🔊  Speaker volume unmuted."
}

case "$1" in
	increase)
		increase_volume
		;;
	decrease)
		decrease_volume
		;;
	mute)
		mute_volume
		;;
	unmute)
		unmute_volume
		;;
	toggle)
		if [ "$audio_status" -eq 0 ]; then
			unmute_volume
		else
			mute_volume
		fi
		;;
	*)
		echo "$audio_status"
		;;
esac
