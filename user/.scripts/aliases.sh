#!/usr/bin/env sh

# Networking
alias openports='doas netstat -tulanp | grep LISTEN'
alias netcons='netstat -tulpan'
alias myip='curl icanhazip.com'

# misc
alias fs="du -sh"
alias history='history | less'
alias ll='ls -lAh'
alias la='ls -A'
alias l='ls -1F'
alias less='less -R'

# run in GNU env
alias nnn='$SCRIPTS/gnu.sh nnn' # nnn depend on some specific flags that sbase doesn't have
alias pass='$SCRIPTS/gnu.sh pass'

# XBPS
alias i='doas xbps-install'      # Install package (without updating repos)
alias q="xbps-query -R"          # Detailed query about some package
alias u='doas xbps-install -Syu' # Update all packages
alias ui='doas xbps-install -Sy' # Update repos [and install/update package]
alias il='xbps-install -f'       # Install local package
alias r='doas xbps-remove -Ro'   # Remove package
alias s='xbps-query -Rs'         # Search
# Search (w/ regex)
# sr ".*lib.*dev.*|.*dev.*lib.*"
# sr '^linux[0-9.]+-[0-9._]+'
alias sr='xbps-query --regex -Rs'
alias si='xbps-query -s'  # Search installed
alias li='xbps-query -l'  # list installed
alias lei='xbps-query -m' # list explicitly installed

# Source functions to use xo
export ROVER_OPEN=". $SCRIPTS/functions.sh && xo xdg-open"
