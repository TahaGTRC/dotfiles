#!/usr/bin/env sh

: <<EOF
Add more options to forget, scan, or connect
https://wiki.archlinux.org/title/Iwd
TODO: Investigate why sbase's sed can't remove color control sequence
EOF

station=$(iwctl station list | awk 'NR==5 {print $2}')
iwctl station "$station" scan

networks=$(iwctl station "$station" get-networks | awk 'NR>4 {print $0}')
networks=$(echo "$networks" | "$SCRIPTS/gnu.sh" sed -E 's/\x1B\[[0-9;]*m//g')
networks=$(echo "$networks" | "$SCRIPTS/gnu.sh" sed -E '0,/>/s/( +)>( +)/\1\2/1')

menu_font="SF Mono"
menu_font_size="20"
menu_height="20"
set -- -i -fn "$menu_font-$menu_font_size" -l "$menu_height" -c

network=$(echo "$networks" | awk '{print $1}' | dmenu "$@")

if [ -z "$network" ]; then
	exit 1
fi

# why can't iwctl have a flag for no-damn-coloring
known_networks="$(iwctl known-networks list | /bin/sed -E 's/\x1B\[[0-9;]*m//g')"
known_networks="$(echo "$known_networks" | awk 'NR>4 {print $1}')"

# Check if the network is already saved, if so, connect
if echo "$known_networks" | grep -q "^$network$" ; then
    iwctl station "$station" connect "$network"
else
    pass=$(dialog --title "Network auth" --passwordbox "Enter <$network> password:" 8 39 3>&1 1>&2 2>&3)
    iwctl --passphrase "$pass" station "$station" connect "$network"    
fi

# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
   herbe "❌  Failed connecting to $network."
fi
