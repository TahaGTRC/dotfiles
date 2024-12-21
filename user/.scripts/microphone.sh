#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

increase_mic_volume() (
	amixer set Capture 5%+ 1> /dev/null
	value=$(amixer get Capture | awk -F'[][]' '/\[[0-9]+%\]/{print $2; exit}')
	notify "🎙️ Microphone volume increased: $value."
)

decrease_mic_volume() (
	amixer set Capture 5%- 1> /dev/null
	value=$(amixer get Capture | awk -F'[][]' '/\[[0-9]+%\]/{print $2; exit}')
	notify "🎙️ Microphone volume decreased: $value."
)

mute_mic() (
	amixer set Capture 0% 1> /dev/null
	echo "off" > "$MICROPHONE_STATUS_FILE"
	notify "🎙️ Microphone muted."
)

unmute_mic() (
	amixer set Capture 50% 1> /dev/null
	echo "on" > "$MICROPHONE_STATUS_FILE"
	notify "🎙️ Microphone unmuted."
)

if [ ! -d "$STATS_DIR" ]; then
	mkdir -p "$STATS_DIR"
fi

if [ ! -e "$MICROPHONE_STATUS_FILE" ]; then
	unmute_mic
fi

mic_status=$(cat "$MICROPHONE_STATUS_FILE")

case "$1" in
	increase)
		increase_mic_volume
		;;
	decrease)
		decrease_mic_volume
		;;
	toggle)
		if [ "$mic_status" = "on" ]; then
			mute_mic
		elif [ "$mic_status" = "off" ]; then
			unmute_mic
		fi
		;;
	*)
		echo "Usage: $0 {increase|decrease|toggle}"
		exit 1
		;;
esac

unset mic_status
