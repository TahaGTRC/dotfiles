#!/usr/bin/env sh

. "$SCRIPTS/functions.sh"

usage() {
	echo "Usage: $0 shutdown|reboot|suspend"
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi

gpid="/tmp/guard.pid"
spid="/tmp/slock.pid"

lock() {
	slock &
	echo $! > "$spid"
	"$SCRIPTS/gnu.sh" sleep 0.5

	guard &
	echo $! > "$gpid"
	"$SCRIPTS/gnu.sh" sleep 0.5
}

unlock() {
	wait "$(cat "$spid")" \
	&& {
		pkill -15 -P "$(cat "$gpid")";
		kill -15 "$(cat "$gpid")";
		rm -f "$gpid" "$spid";
	}
}

case "$1" in
	"shutdown")
		doas shutdown -h now
		;;

	"reboot")
		doas reboot
		;;

	"suspend")
		# We need to pause anything playing, so we don't
		# get hit by it when resuming session out loud
		# however using playerctl isn't the best choice
		# since not all programs implement the mpris 
		# interface, instead muting is a better solution
		$DISPLAY_SCRIPT reset
		$VOLUME_SCRIPT mute no_notif

		lock
		doas zzz
		unlock
		;;

	"logout")
		$DISPLAY_SCRIPT reset
		$VOLUME_SCRIPT mute no_notif

		lock
		unlock
		;;

	*)
		usage
		;;
esac
