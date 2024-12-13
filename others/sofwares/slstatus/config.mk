# slstatus version
VERSION = 1.0

# customize below to fit your system

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

# flags
CPPFLAGS = -I$(X11INC) -DALSA -D_DEFAULT_SOURCE -DVERSION=\"${VERSION}\" 
CFLAGS   = -std=c99 -pedantic -Wall -Wextra -Wno-unused-parameter -Os
CFLAGS += -D__MANZIL__="\"$$HOME\""
LDFLAGS  = -L$(X11LIB) -lasound -s
# OpenBSD: add -lsndio
# FreeBSD: add -lkvm -lsndio
LDLIBS   = -lX11

# compiler and linker
CC = cc
