# Define variables
CC = tcc
CFLAGS = -lncurses # ncurses-devel in void
SRC = nsudoku.c
OUT = sudoku
BIN_DIR = /usr/local/bin

# Default target to build the program
all: $(OUT)

# Compile the program
$(OUT): $(SRC)
	$(CC) -o $(OUT) $(SRC) $(CFLAGS)

# Copy the compiled binary to the local bin directory
install: $(OUT)
	@mkdir -p $(BIN_DIR)
	@cp $(OUT) $(BIN_DIR)/

uninstall:
	@rm -f $(BIN_DIR)/$(OUT)

# Clean up generated files
clean:
	@rm -f $(OUT)

# Phony targets
.PHONY: all install clean

