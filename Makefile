.PHONY: setup build clean

TINYGO := $(CURDIR)/bin/tinygo
OUTPUT_DIR := bin
ARCH := $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]')
OUTPUT := $(OUTPUT_DIR)/packed-$(PLATFORM)-$(ARCH)

setup:
	@chmod +x scripts/setup-tinygo.sh
	@./scripts/setup-tinygo.sh

build: $(TINYGO)
	@if [ ! -d "src" ]; then echo "Error: src/ directory not found"; exit 1; fi
	@mkdir -p $(OUTPUT_DIR)
	cd src && $(TINYGO) build -no-debug -panic=trap -opt=z -o ../$(OUTPUT) .
	@echo "Built: $(OUTPUT)"

$(TINYGO):
	@echo "TinyGo not found. Run 'make setup' first."
	@exit 1

clean:
	rm -rf $(OUTPUT_DIR)

run: build
	@$(OUTPUT)
