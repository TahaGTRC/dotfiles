#!/usr/bin/env sh

# A lil script to run some command w GNU utils instead of sbase (comp issues)
[ "$PATH" ] && ORIGINAL=":$PATH"
GNU="/bin:/usr/bin"
export PATH="${GNU}${ORIGINAL}"

if [ "$1" = "-term" ]; then
	shift
	"$TERMINAL" -e "$@"
else
	command "$@"
fi

export PATH="$ORIGINAL"

unset ORIGINAL GNU
