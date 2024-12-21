#!/usr/bin/env sh

# A script to execute a command/script using GNU's base commands
# instead of sbase, since some utilities/tools depend on some
# specific flags only existing in GNU's variant

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
