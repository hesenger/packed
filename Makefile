.PHONY: setup build clean

TINYGO := ./bin/tinygo
OUTPUT_DIR := bin
ARCH := $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]')
OUTPUT := $(OUTPUT_DIR)/packed

setup:
	@chmod +x scripts/setup-tinygo.sh
	@./scripts/setup-tinygo.sh

build: $(TINYGO)
	@mkdir -p $(OUTPUT_DIR)
	$(TINYGO) build -o $(OUTPUT) ./src/main.go
	@echo "Built: $(OUTPUT)"

$(TINYGO):
	@echo "TinyGo not found. Run 'make setup' first."
	@exit 1

clean:
	rm -rf $(OUTPUT_DIR)

run: build
	@$(OUTPUT)
