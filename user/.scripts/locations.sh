#!/usr/bin/env sh
# had SC2155 before
WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f | shuf | head -1)
export WALLPAPER

export EDITOR="vis"
export VISUAL="vis"
export TERMINAL="st"
export BROWSER="firefox"
export FM="nnn"
export CLIPBOARDER="xclip"

export DOTFILES="Dotfiles"
export OTHERS="$HOME/$DOTFILES/others"
export BACKUP="$OTHERS/backups"
export SCRIPTS="$HOME/.scripts"

export STATS_DIR="$HOME/.stats"
export LOGFILE="$HOME/.stats/log"
export LANG_STATUS_FILE="$STATS_DIR/lang"
export DISPLAY_STATUS_FILE="$STATS_DIR/display"
export VOLUME_STATUS_FILE="$STATS_DIR/audio"
export BRIGHTNESS_STATUS_FILE="$STATS_DIR/brightness"
export MICROPHONE_STATUS_FILE="$STATS_DIR/mic"
export REC_STATUS_FILE="$STATS_DIR/rec"

export VOLUME_SCRIPT="$SCRIPTS/volume.sh"
export DISPLAY_SCRIPT="$SCRIPTS/display.sh"
