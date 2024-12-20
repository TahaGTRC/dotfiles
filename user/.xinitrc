#!/bin/sh

 . "$SCRIPTS/locations.sh"
 . "$SCRIPTS/functions.sh"
export XDG_RUNTIME_DIR=/run/user/1000
doas rm -rf $XDG_RUNTIME_DIR/*

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi
[ -f ~/.xprofile ] && . ~/.xprofile &

if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
    # if not found, launch a new one
    eval `dbus-launch --sh-syntax --exit-with-session`
    echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
fi

# cursor
xsetroot -cursor_name left_ptr


# status bar
slstatus &

# SXHKD STARTS BEFORE CHANGING LAYOUT, TAKING DEFAULT ONE (EN), MESSING UP KEYS 😡
setxkbmap fr

xrdb ~/.Xresources

set_wallpaper

sxhkd &

#exec dbus-run-session dwm
exec dwm


# exec dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) dwm > .log 2>&1

