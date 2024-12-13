# Variables
BINARY_NAME = chajara
INSTALL_PATH = /usr/local/bin/$(BINARY_NAME)

# Build the binary
build:
	GCO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w -extldflags '-static'" -o $(BINARY_NAME) main.go

# Install the binary
install: build
	 cp $(BINARY_NAME) $(INSTALL_PATH)
	 chmod +x $(INSTALL_PATH)

# Uninstall the binary
uninstall:
	 rm -f $(INSTALL_PATH)

# Clean up the binary
clean:
	rm -f $(BINARY_NAME)

# Phony targets
.PHONY: build install uninstall clean

