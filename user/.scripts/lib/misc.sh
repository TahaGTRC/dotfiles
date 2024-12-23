#!/usr/bin/env sh

. "$SCRIPTS/aliases.sh"

# This expands when defined, not when used. Consider escaping!!!!
# alias txt2regex="$SCRIPTS/txt2regex.sh"
txt2regex() {
	"$SCRIPTS/txt2regex.sh" "$@"
}

compress() {
	# Check if there is no input
	if [ -z "$1" ]; then
		echo "Usage: compress <file|directory> [<file|directory> ...] [-o=<output>] [--speed={fast|normal|slow}]]"
		return 1
	elif [ "$1" = "." ]; then
		stylize -f red -s bold -n "Error: You cannot run the command ON and FROM the current folder!"
		return 1
	fi

	# Default archive name and options
	archive="archive"
	speed="normal"
	compression_flags=""
	tape="cpio"
	compressor="xz"
	inputs=""

	while [ $# -gt 0 ]; do
		case "$1" in
			--speed=*)
				speeds="fast|normal|slow"
				speed="${1#*=}"
				if ! array_includes "|" "$speed" "$speeds"; then
					echo "Unknown value passed: --speed=<$speed>"
					echo "Possible values: $speeds"
					return 1
				fi
				case "$speed" in
					slow) compression_flags="-9 -e" ;;
					normal) compression_flags="-6" ;;
					fast) compression_flags="-0" ;;
				esac
				;;
			-o=*)
				archive="${1#*=}"
				;;
			*)
				if [ ! -e "$1" ]; then
					stylize -f red -s bold -n "Error: '$1' does not exist!"
					return 1
				fi
				[ -z "$inputs" ] && inputs="$1"
				[ -n "$inputs" ] && inputs="$inputs $1"
				;;
		esac
		shift
	done

	if [ -f "${archive}.${tape}.${compressor}" ]; then
		message=$(stylize -f orange -s bold "Warning: Archive ${archive}.${tape}.${compressor} already exists. Overwrite? (y/n): ")
		echo "$message"
		read -r choice
		case "$choice" in
			[Yy]*) ;;
			*)
				echo "Aborted."
				return 1
				;;
		esac
	fi

	stylize -f white -s italic "Compressing ⌛..."
	# shellcheck disable=SC2086
	find $inputs | cpio -o | xz -kf - $compression_flags > "${archive}.${tape}.${compressor}"
}

preview() {
	archive="$1"
	if [ -z "$1" ]; then
		echo "No archive name provided!"
		exit 1
	fi

	xz -cd "${archive}" | cpio -it 2> /dev/null | chajara
}

decompress() {
	if [ -z "$1" ]; then
		echo "Usage: decompress <archive> [<destination>]"
		return 1
	fi

	archive="$1"

	if [ ! -f "$archive" ]; then
		echo "Error: Archive '$archive' not found!"
		return 1
	fi

	dest="."

	if [ -n "$2" ]; then
		dest="$2"
		mkdir -p "$dest"
	fi

	xz -cdkf "${archive}" | cpio -idD "$dest"
}

record() {

# Rewrite later, to clean more, and add support for mic/sys audio choice
# and webcam record too
#        -f v4l2 -i /dev/video0 \
#        -f pulse -ac 1 -i default \
	if [ "$(xrandr --listactivemonitors | grep '[0-9]:' | wc -l)" -ne 1 ]; then
		stylize -f red -s bold -n "Only one active monitor is supported"
		return 0
	fi

	screen="$DISPLAY"     # -s
	resolution="1366x768" # -r
	v_enc="libvpx"        # -v
	a_enc="libvorbis"     # -a
	format="webm"         # -e (mustn't be infered from v_enc?)
	frames=60             # -f
	bitrate="2M"          # -b
	verbosity="error"
	aformat="pulse" # or alsa
	a_encodes="aac|mp3|libmp3lame|opus|libopus|flac|vorbis|libvorbis|eac3|ac3|alac|wavpack"
	v_encodes="libx264|libx265|libvpx|libvpx-vp9|h264_qsv|hevc_qsv|av1_qsv|av1_nvenc|h264_nvenc|hevc_nvenc|mpeg4|libxvid|h264_amf|hevc_amf|av1_amf|gif"
	v_formats="mp4|mkv|avi|mov|flv|wmv|webm|mpeg|ts|m4v|gif|3gp"

	while [ $# -gt 0 ]; do
		case "$1" in
			-a=*)
				aencode="${1#*=}"
				if ! array_includes "|" "$aencode" "$a_encodes"; then
					echo "Unknown value passed: -a=<$aencode>"
					echo "Possible values: $a_encodes"
					return 1
				fi
				a_enc="$aencode"
				;;
			-v=*)
				vencode="${1#*=}"
				if ! array_includes "|" "$vencode" "$v_encodes"; then
					echo "Unknown value passed: -v=<$vencode>"
					echo "Possible values: $v_encodes"
					return 1
				fi
				v_enc="$vencode"
				;;
			-s=*)
				# 0.0+1366,0
				scrn="${1#*=}"
				if [ -n "$(echo "$scrn" | tr -d '0123456789:.,+')" ]; then
					echo "Unknown value passed: -s=<$scrn>"
					echo "Possible values: :0|:0.0+1366,0..."
					return 1
				fi
				screen="$scrn"
				;;
			-r=*)
				resol="${1#*=}"
				if ! echo "$resol" | grep "^[0-9]\{4\}x[0-9]\{3,\}"; then
					echo "Unknown value passed: -r=<$resol>"
					echo "Possible values: [0-9].+x[0-9].+"
					return 1
				fi
				resolution="$resol"
				;;
			-b=*)
				bitr="${1#*=}"
				if ! echo "$bitr" | grep "^[0-9]\+[Mk]"; then
					echo "Unknown value passed: -b=<$bitr>"
					echo "Possible values: [0-9].+[Mk]"
					return 1
				fi
				bitrate="$bitr"
				;;
			-f=*)
				framerate="${1#*=}"
				if [ -n "$(echo "$framerate" | tr -d '0-9')" ]; then
					echo "Unknown value passed: -f=<$framerate>"
					echo "Possible values: [0-9].+"
					return 2
				fi
				frames="$framerate"
				;;
			-e=*)
				frmt="${1#*=}"
				if ! array_includes "|" "$frmt" "$v_formats"; then
					echo "Unknown value passed: -e=<$frmt>"
					echo "Possible values: $v_formats"
					return 1
				fi
				format="$frmt"
				;;
			-log)
				verbosity=1
				verbosity="info"
				;;
			*)
				echo "Unknown parameter passed: <$1>"
				return 1
				;;
		esac
		shift
	done

	# add audio choices (sys audio/mic....)
	lock="/tmp/record.process"
	[ -e "$lock" ] && echo "Check existing recording process" && return 1
	# Using this in slstatus
	echo " REC 🔴 |" > "$REC_STATUS_FILE"

	cleanup() {
		rm -f "$lock"
		# silly workaround by using invisible char in slstatus
		echo "​" > "$REC_STATUS_FILE"
		echo "Lock file removed."
		return
	}

	trap cleanup INT EXIT

	output_dir="$HOME/Videos/Recordings"
	mkdir -p "$output_dir"
	now=$(date +"%Y-%m-%d_%H-%M-%S")

	echo "Recording 📹"
	echo "  Specs:"
	printf "\t * Bitrate: %s\n" "$bitrate"
	printf "\t * Screen: %s\n" "$screen"
	printf "\t * Resolution: %s\n" "$resolution"
	printf "\t * V Encode: %s\n" "$v_enc"
	printf "\t * A Encode: %s\n" "$a_enc"
	printf "\t * FPS: %s\n" "$frames"
	printf "\t * Format: %s\n" "$format"

	ffmpeg -framerate "$frames" \
		-video_size "$resolution" \
		-f x11grab -i :"$screen" \
		-f alsa -ac 1 -i default \
		-c:v "$v_enc" \
		-b:v "$bitrate" \
		-c:a "$a_enc" \
		"$output_dir/$now.$format" \
		-loglevel "$verbosity"
	# ffmpeg puts logs in stderr
	# > /dev/null 2>&$((verbosity == 2 ? 1 : 2))

	# Cleanup lock file when ffmpeg completes normally
	cleanup
}

screenshot() {
	mkdir -p "$HOME/Pictures"
	FILENAME="$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"
	case "$1" in
		window)
			FILENAME="$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S)_focused_window.png"
			WINDOW_ID=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $NF}')
			import -window "$WINDOW_ID" "$FILENAME"
			;;
		screen)
			FILENAME="$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"
			import -window root "$FILENAME"
			;;
		area)
			FILENAME="$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S)_area.png"
			import "$FILENAME"
			;;
		*)
			echo "Usage: screenshot screen|window|area"
			return 1
			;;
	esac

	menu_font="Fira Code"
	menu_font_size="14"
	menu_height="12"

	set -- -i -fn "$menu_font-$menu_font_size" -l "$menu_height" -c
	options="save ⏬|copy 📋"
	list=$(arr_to_list "|" "$options")
	chosen=$(echo "$list" | dmenu "$@")
	[ -z "$chosen" ] && rm "$FILENAME" && return 1
	if array_includes "|" "$chosen" "$options"; then
		case "$chosen" in
			save*) ;;
			copy*)
				xclip -selection clipboard -t image/png -i "$FILENAME"
				rm "$FILENAME"
				notify "📋  Copied successefully"
				;;
			*)
				rm "$FILENAME"
				;;
		esac
	fi

}

set_wallpaper() {
	if [ -z "$1" ]; then
		# shellcheck disable=SC2153
		wallpaper="$WALLPAPER"
	else
		wallpaper="$1"
	fi

	xwallpaper --maximize "$wallpaper"
}

backup() {
	SOURCE_DIR="/"
	BACKUP_DIR="/home/backup"
	TIMESTAMP=$(date +"%Y%m%d%H%M")
	BACKUP_NAME="backup-$TIMESTAMP"

	doas mkdir -p "$BACKUP_DIR/$BACKUP_NAME"

	# Using --exclude to specify patterns to exclude
	doas rsync -av \
		--exclude='/root' \
		--exclude='/mnt' \
		--exclude='/home' \
		--exclude='/proc' \
		--exclude='/sys' \
		--exclude='/dev' \
		--exclude='/run' \
		--exclude='/tmp' \
		--exclude='/var/tmp' \
		--exclude='/var/lib/libvirt/images' \
		--exclude='/var/cache' \
		--exclude='/lost+found' \
		"$SOURCE_DIR" "$BACKUP_DIR/$BACKUP_NAME"

	echo "Backup completed at $BACKUP_DIR/$BACKUP_NAME"
}

guard() (
	USB_LIST="/tmp/myports"
	CURR_LIST="/tmp/myports.curr"

	cleanup() {
		rm -f "$USB_LIST"
		rm -f "$CURR_LIST"
		exit 1
	}

	trap cleanup HUP INT TERM

	if [ ! -f "$USB_LIST" ]; then
		lsusb | sort > "$USB_LIST"
	fi

	while true; do
		CURR_USB=$(lsusb | sort)
		echo "$CURR_USB" > "$CURR_LIST"
		echo "Running"

		NEW_USB=$(comm -13 "$USB_LIST" "$CURR_LIST")

		if [ -n "$NEW_USB" ]; then
			doas poweroff && cleanup
		fi

		"$SCRIPTS/gnu.sh" sleep 0.5
	done
)

bluetooth() {
	doas sv start bluetoothd
	pulseaudio -k > /dev/null 2>&1 || true; pulseaudio --start > /dev/null 2>&1
}
