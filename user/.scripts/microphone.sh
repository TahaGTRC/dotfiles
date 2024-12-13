#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

# Function to increase microphone volume
increase_mic_volume() (
	amixer set Capture 5%+ 1> /dev/null
	value=$(amixer get Capture | awk -F'[][]' '/\[[0-9]+%\]/{print $2; exit}')
	notify "🎙️ Microphone volume increased: $value."
)

# Function to decrease microphone volume
decrease_mic_volume() (
	amixer set Capture 5%- 1> /dev/null
	value=$(amixer get Capture | awk -F'[][]' '/\[[0-9]+%\]/{print $2; exit}')
	notify "🎙️ Microphone volume decreased: $value."
)

# Function to mute microphone
mute_mic() (
	amixer set Capture 0% 1> /dev/null
	echo "off" > "$MICROPHONE_STATUS_FILE"
	notify "🎙️ Microphone muted."
)

# Function to unmute microphone
unmute_mic() (
	amixer set Capture 5% 1> /dev/null
	echo "on" > "$MICROPHONE_STATUS_FILE"
	notify "🎙️ Microphone unmuted."
)

# Check if the directory exists, if not, create it
if [ ! -d "$STATS_DIR" ]; then
	mkdir -p "$STATS_DIR"
fi

# Check if microphone status file exists, if not, create one with default status
if [ ! -e "$MICROPHONE_STATUS_FILE" ]; then
	unmute_mic
fi

# Get the current mute status
mic_status=$(cat "$MICROPHONE_STATUS_FILE")

# Main script
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
