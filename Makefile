# Makefile

# Variables
AGENT_DIR=./agent
UI_DIR=./ui
API_DIR=./api

# Targets
all: build-agent build-ui build-api

build-agent:
	@echo "Building Rust agent..."
	cd $(AGENT_DIR) && cargo build --release

build-ui:
	@echo "Building UI..."
	cd $(UI_DIR) && npm install && npm run build

build-api:
	@echo "Setting up API..."
	cd $(API_DIR) && npm install

clean:
	@echo "Cleaning up..."
	cd $(AGENT_DIR) && cargo clean
	cd $(UI_DIR) && rm -rf node_modules dist
	cd $(API_DIR) && rm -rf node_modules

.PHONY: all build-agent build-ui build-api clean