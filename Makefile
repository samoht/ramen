# Build the ramen binary
build:
	dune build bin/main.exe
	@echo "Ramen binary built at: _build/default/bin/main.exe"
	@echo "To install system-wide, run: dune install"

# Install the ramen binary
install:
	dune install

# Build example site (for testing)
example:
	mkdir -p site && dune exec -- extract/main.exe --root site

# Development build - watch for changes
dev:
	dune build -w bin/main.exe

# Clean build artifacts
clean:
	dune clean
	rm -rf site

.PHONY: build install example dev clean
