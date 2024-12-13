#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

dev1=$(xrandr | grep ' connected' | awk 'NR==1 {print $1}')
dev2=$(xrandr | grep ' connected' | awk 'NR==2 {print $1}')

if [ ! -d "$STATS_DIR" ]; then
	mkdir -p "$STATS_DIR"
fi

# Function to switch to a given display
switch_to_device() (
	dev="$1"
	resol=$(xrandr | sed -n "/$dev/{n;p}" | awk '{print $1}' | sort -t 'x' -k1,1n -k2,2n | tail -n 1)
	[ "$dev" ] && xrandr --output "$dev" --primary --mode "$resol" --scale 1x1 --auto
	others=$(xrandr | awk '/connected/ {print $1}' | grep -v "$dev")
	echo "$others" | xargs -I {} xrandr --output {} --off
	echo "$dev" > "$DISPLAY_STATUS_FILE"
	# shellcheck disable=SC2119
	set_wallpaper
)

extend() {
	switch_to_device "$dev1"
	xrandr --output "$dev1" --auto --output "$dev2" --auto --right-of "$dev1"
	rm "$DISPLAY_STATUS_FILE"
	# shellcheck disable=SC2119
	set_wallpaper
}

mirror() (
	INFOS=$(xrandr)
	DISPLAYS=$(echo "$INFOS" | awk '/ connected/{print $1}' | tr ' ' '\n')
	LAPTOP_DISPLAY=$(echo "$DISPLAYS" | head -1)
	EXTERNAL_DISPLAY=$(echo "$DISPLAYS" | tail -1)

	RESOLUTIONS=$(echo "$INFOS" | awk '/ connected/{getline; print $1}' | tr ' ' '\n')
	LAPTOP_RESOLUTION=$(echo "$RESOLUTIONS" | head -1)
	EXTERNAL_RESOLUTION=$(echo "$RESOLUTIONS" | tail -1)

	xrandr --fb "$EXTERNAL_RESOLUTION" \
		--output "$LAPTOP_DISPLAY" --mode "$LAPTOP_RESOLUTION" \
		--scale-from "$EXTERNAL_RESOLUTION" --output "$EXTERNAL_DISPLAY" \
		--mode "$EXTERNAL_RESOLUTION" --scale 1x1 --same-as "$LAPTOP_DISPLAY"

	echo "mirroring" > "$DISPLAY_STATUS_FILE"
	# shellcheck disable=SC2119
	set_wallpaper
)

if [ ! -e "$DISPLAY_STATUS_FILE" ]; then
	switch_to_device "$dev1" # Default to laptop if the file doesn't exist
fi

display_status=$(cat "$DISPLAY_STATUS_FILE")

# Handle the toggle command
case "$1" in
	toggle)
		# Check the current display status using grep
		# the wallpaper size doesn't auto increase when changing display
		# so I have to reset it
		if [ "$dev2" ] && echo "$display_status" | grep -q "$dev1"; then
			# If the current status is laptop
			switch_to_device "$dev2"
		else
			# If the current status is monitor
			switch_to_device "$dev1"
		fi
		;;
	extend)
		extend
		;;
	mirror)
		mirror
		;;
	reset)
		switch_to_device "$dev1"
		;;
	*)
		echo "Usage: $0 {toggle|extend|mirror|reset}"
		exit 1
		;;
esac

unset dev1 dev2
