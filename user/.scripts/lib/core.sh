#!/usr/bin/env sh

. "$SCRIPTS/aliases.sh"

# Remove all - including hidden - files/folders
rma() (
	[ -n "$1" ] && [ "$1" != "--hidden" ] && [ "$1" != "--in-hidden" ] \
		&& stylize -f 159 -s italic -n "Place yourself into the folder you want to delete its content!" \
		&& return 1

	h_flag=""

	if [ "$1" = "--hidden" ]; then
		spec=" *HIDDEN*"
		h_flag="h"
	elif [ "$1" = "--in-hidden" ]; then
		spec=" *HIDDEN FILES (CURRENT & SUBDIRS)*"
		h_flag="ih"
	fi

	confirm="n"
	stylize -f 11 -s bold "THIS WILL REMOVE ALL$spec FILES IN: "
	stylize -f red -s bold -n "$(pwd)"
	stylize -f orange -s bold "Are you sure? (y/n): "
	read -r confirm

	case "$confirm" in
		n*)
			return 1
			;;
	esac

	if [ "$h_flag" = "ih" ]; then
		find "." -depth -name ".*" ! -name "." ! -name ".." -exec rm -rf {} \;
	elif [ "$h_flag" = "h" ]; then
		ls -a | grep -v "^\.\{1,2\}$" | grep "^\." | xargs rm -rf
	else
		find "." -depth ! -name "." ! -name ".." -exec rm -rf {} \;
	fi
)

# Verify if an array includes a val
# $1 delimeter used in stringified array to split elements
# $2 target to verify it's existance
# $3 array to look through

# Example: array_includes "|" "2" "1|2|3" # returns true
array_includes() (
	[ -z "$3" ] && echo "Usage: array_includes <delimiter> <target> <array>" && return 1
	target="$2"
	options="$3"
	old_ifs="$IFS"
	IFS="$1"
	for element in $options; do
		if [ "$element" = "$target" ]; then
			IFS="$old_ifs"
			return 0
		fi
	done
	IFS="$old_ifs"
	return 1
)

# Example: arr_to_list "|" "1|2|3" # returns an IFS seperated 'list'
arr_to_list() {
	[ -z "$2" ] && echo "Usage: arr_to_list <delimiter> <array>" && return 1

	delimiter="$1"
	array="$2"
	old_ifs="$IFS"
	IFS="$delimiter"

	list=""
	nline="\n"
	for element in $array; do
		[ -n "$list" ] && list="$list$nline$element"
		[ -z "$list" ] && list="$element"
	done

	IFS="$old_ifs"

	echo "$list"
}

stylize() (
	is_prompt=0
	nl=""
	style=""
	fgcolor=""
	bgcolor="-1"

	while getopts "pnf:s:b:" opt; do
		case "$opt" in
			p)
				is_prompt=1
				;;
			n)
				nl="\n"
				;;
			f)
				fgcolor="$OPTARG"
				;;
			s)
				style="$OPTARG"
				;;
			b)
				bgcolor="$OPTARG"
				;;
			*)
				echo "Invalid option: -$opt" >&2
				exit 1
				;;
		esac
	done

	shift $((OPTIND - 1))
	text="$1"

	get_color_code() {
		# Directly handle numeric values
		if [ "$1" -eq "$1" ] 2> /dev/null; then
			echo "$1"
			return
		fi

		case "$1" in
			red) echo "196" ;;
			green) echo "34" ;;
			yellow) echo "226" ;;
			blue) echo "21" ;;
			magenta) echo "127" ;;
			orange) echo "220" ;;
			cyan) echo "152" ;;
			white) echo "15" ;;
		esac
	}

	if [ -z "$fgcolor" ]; then
		echo "No color provided!"
		return 1
	fi

	fgcolor=$(get_color_code "$fgcolor")
	bgcolor=$(get_color_code "$bgcolor")

	case "$style" in
		"bold") style="\033[1" ;;
		"underline") style="\033[4" ;;
		"reverse") style="\033[7" ;;
		"italic") style="\033[3" ;;
		*) style="\033[0" ;;
	esac

	if [ "$is_prompt" -eq 1 ]; then
		# shellcheck disable=SC2059
		printf "\[${style}m\033[38;5;${fgcolor}m\033[48;5;${bgcolor}m\]${text}\[\033[0m\]"
	elif [ -t 1 ]; then
		# shellcheck disable=SC2059
		printf "${style}m\033[38;5;${fgcolor}m\033[48;5;${bgcolor}m${text}\033[0m${nl}"
	else
		# to file or pipe
		printf "%s" "$text"
	fi
)

notify() {
	# kill any previous notifications
	pkill -15 herbe

	# Wait for the process to terminate
	while pgrep -x "herbe" > /dev/null; do
		"$SCRIPTS/gnu.sh" sleep 0.1
	done

	herbe "$1"
}

fresh() {
	if ! command -v jq 1> /dev/null 2>&1; then
		stylize -f red -s bold -n "Install jq first!"
		return 1
	fi

	ppath="$OTHERS/packages.json"

	# shellcheck disable=SC2046
	i $(jq -r '[.user[], .base[]] | join(" ")' "$ppath")
}

xo() (
	if [ -z "$1" ]; then
		echo "Usage: xo command"
		return 1
	fi

	cmd="$1"

	if type "$cmd" | grep -q "alias"; then
		cmd=$(alias "$cmd" 2>/dev/null | awk -F"'" '{print $2}')
	fi

	shift

	(
		set +m
		if [ "$#" -eq 0 ] && [ -x "$(which $cmd)" ]; then
			setsid "$cmd" > /dev/null 2>&1 &
		else
			# BUG: sbase's xargs cant handle long paths
			echo "$@" | "$SCRIPTS/gnu.sh" xargs -I {} sh -c "setsid $cmd '{}' > /dev/null 2>&1 &"
		fi
	)
)

# fzyx [dir]
# uses fzy to discover the content of the current
# - or provided - directory
fzyx() {
	path="."

	if [ -n "$1" ]; then
		path="$1"
	fi

	selected=$(find "$path" | sed "s|^${path}||" | fzy -p "$(stylize -f yellow -s bold '> ')")

	if [ -n "$selected" ]; then
		full_path="${path}${selected}"
		echo "$full_path"
	fi

	unset path full_path selected
}

# Find which package provides a certain - local - bin/command
wpkg() {
	command="$1"
	path=$(which "$command")
	result=$(xbps-query -o "$path")
	echo "$result"
	unset path command result
}

# Make all directory tree and create a file
touchie() {
	mkdir -p "$(dirname "$1")" && touch "$1"
}

# Copy file content to clipboard
cpf() {
	[ -r "$1" ] && xclip -selection clipboard < "$1"
}

preview_colors() {
	c=0
	message="You, sir, are a fish!"
	while [ "$c" -lt 256 ]; do
		printf "%s: \033[0;38;5;%sm%s\033[0m\n" "$c" "$c" "$message"
		c=$((c + 1))
	done
	unset c message
}
