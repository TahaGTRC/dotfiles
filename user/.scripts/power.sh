#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

# Function to display usage information
usage() {
	echo "Usage: $0 [shutdown|reboot|suspend]"
	exit 1
}

# Check if argument is provided
if [ $# -ne 1 ]; then
	usage
fi
gpid="/tmp/guard.pid"
spid="/tmp/slock.pid"
# Perform action based on argument
case "$1" in
	"shutdown")
		doas shutdown -h now
		;;
	"reboot")
		doas reboot
		;;
	"suspend")
		# Seems like even after pause, cmus autoplays at relogin
		# muting is a temp solution
		$DISPLAY_SCRIPT reset
		$VOLUME_SCRIPT mute no_notif
		playerctl pause
		slock &
		echo $! > "$spid"
		"$SCRIPTS/gnu.sh" sleep 0.5
		guard &
		echo $! > "$gpid"
		"$SCRIPTS/gnu.sh" sleep 0.5
		doas zzz
		wait "$(cat "$spid")" \
			&& pkill -15 -P "$(cat "$gpid")" \
			&& kill -15 "$(cat "$gpid")" \
			&& rm -f "$gpid" "$spid"
		;;
	"logout")
		$DISPLAY_SCRIPT reset
		$VOLUME_SCRIPT mute no_notif
		playerctl pause
		slock &
		echo $! > "$spid"
		"$SCRIPTS/gnu.sh" sleep 0.5
		guard &
		echo $! > "$gpid"
		"$SCRIPTS/gnu.sh" sleep 0.5
		wait "$(cat "$spid")" \
			&& pkill -15 -P "$(cat "$gpid")" \
			&& kill -15 "$(cat "$gpid")" \
			&& rm -f "$gpid" "$spid"
		;;
	*)
		usage
		;;
esac
exit 0
