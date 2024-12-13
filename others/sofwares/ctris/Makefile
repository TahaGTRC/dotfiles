MANDIR=$(DESTDIR)/usr/share/man/man6
BINDIR=$(DESTDIR)/usr/local/bin

CC=tcc
MKDIR=mkdir -p
INSTALL=install

CFLAGS=-Wall -fomit-frame-pointer -O3
LIBS=-lm -lncurses

OBJS=ctris.o game.o screen.o brick.o highscore.o
OUTPUT=tetris
MANS=ctris.6.gz

# Default target to build the program
all:
	make config
	make build
	
# Configure the build
config:	
	./create_config.sh

# Build the program
build: $(OUTPUT)

# Compile the program
$(OUTPUT): $(OBJS)
	$(CC) $(CFLAGS) -o $(OUTPUT) $(OBJS) $(LIBS)

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) -c $<

# Clean the build artifacts
clean:
	$(RM) $(OBJS) $(OUTPUT) config.h

# Install the binary and man page
install: config build
	$(MKDIR) $(BINDIR) $(MANDIR)
	$(INSTALL) $(OUTPUT) $(BINDIR)
	$(INSTALL) -m 644 $(MANS) $(MANDIR)

# Uninstall the binary and man page
uninstall:
	$(RM) $(BINDIR)/$(OUTPUT)
	$(RM) $(MANDIR)/$(MANS)

# Phony targets to prevent conflicts with file names
.PHONY: all config build clean install uninstall

