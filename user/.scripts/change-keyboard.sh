#!/usr/bin/env sh

if [ ! -d "$STATS_DIR" ]; then
	mkdir -p "$STATS_DIR"
fi

if [ ! -e "$LANG_STATUS_FILE" ]; then
	echo "fr" > "$LANG_STATUS_FILE"
fi

lang=$(cat "$LANG_STATUS_FILE")

if [ "$lang" = "fr" ]; then
	lang="ara"
	echo $lang > "$LANG_STATUS_FILE"
	setxkbmap $lang
else
	lang="fr"
	echo $lang > "$LANG_STATUS_FILE"
	setxkbmap $lang
fi

unset lang
