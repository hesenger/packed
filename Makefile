.PHONY: setup build clean run

OUTPUT_DIR := bin
ARCH := $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]')
OUTPUT := $(OUTPUT_DIR)/packed-$(PLATFORM)-$(ARCH)

build:
	@if [ ! -d "src" ]; then echo "Error: src/ directory not found"; exit 1; fi
	@mkdir -p $(OUTPUT_DIR)
	cd src && go build -ldflags="-s -w" -o ../$(OUTPUT) .
	@echo "Built: $(OUTPUT)"

clean:
	rm -rf $(OUTPUT_DIR)

run: 
	cd src && go run .
