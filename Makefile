.PHONY: all build clean install test

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Build variables
APP_NAME := nvim_url.app
BUILD_DIR := build
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME)
CONTENTS_DIR := $(APP_BUNDLE)/Contents
RESOURCES_DIR := $(CONTENTS_DIR)/Resources
SCRIPTS_DIR := $(RESOURCES_DIR)/Scripts

all: install

build: clean
	@echo "$(BLUE)Building $(APP_NAME)...$(NC)"
	@echo "  Creating build directory...$(NC)"
	@mkdir -p $(APP_BUNDLE)

	@echo "  Copying app contents...$(NC)"
	@cp -R Contents $(APP_BUNDLE)/

	@echo "  Compiling AppleScript...$(NC)"
	@mkdir -p $(SCRIPTS_DIR)
	@osacompile -o $(SCRIPTS_DIR)/main.scpt main.applescript

	@echo "  Setting permissions...$(NC)"
	@chmod +x $(RESOURCES_DIR)/nvim_url.sh
	@chmod +x $(CONTENTS_DIR)/MacOS/applet

	@if [ -d "$(CONTENTS_DIR)/_CodeSignature" ]; then \
		echo "  Removing old code signature...$(NC)"; \
		rm -rf $(CONTENTS_DIR)/_CodeSignature; \
	fi

	@echo ""
	@echo "  Finished! App bundle created at: $(BLUE)$(APP_BUNDLE)$(NC)"
	@echo ""

clean:
	@if [ -d "$(BUILD_DIR)" ]; then \
		echo "$(YELLOW)Cleaning previous build...$(NC)"; \
		echo "  Removing the build directory: $(YELLOW)$(BUILD_DIR)$(NC)"; \
		rm -rf $(BUILD_DIR); \
		echo ""; \
		echo "  All cleaned up!"; \
		echo ""; \
	fi

install: build
	@echo "$(GREEN)Installing $(APP_NAME) to /Applications...$(NC)"
	@cp -R $(APP_BUNDLE) /Applications/
	@echo ""
	@echo "  Done! Installed to $(GREEN)/Applications/$(APP_NAME)$(NC)"
	@echo ""
	@echo "  Try it out by running, and it should open this project's README:"
	@echo "    $(BLUE)open 'nvim://file/$(CURDIR)/README.md:10'$(NC)"
	@echo ""
