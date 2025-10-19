.PHONY: all build clean install uninstall install-cli uninstall-cli dmg
.SILENT:

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
RED := \033[0;31m
NC := \033[0m

# Build variables
APP_NAME := nvim_url.app
BUILD_DIR := build
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME)
CONTENTS_DIR := $(APP_BUNDLE)/Contents
RESOURCES_DIR := $(CONTENTS_DIR)/Resources
SCRIPTS_DIR := $(RESOURCES_DIR)/Scripts

# CLI variables
CLI_INSTALL_PATH := /usr/local/bin/nvim_url
CLI_SOURCE := Contents/Resources/nvim_url.sh

# DMG variables
VERSION := 0.1.0
DMG_NAME := nvim_url-$(VERSION)
VOLUME_NAME := Neovim URL Handler
DMG_TEMP := dmg_temp
DIST_DIR := dist
FINAL_DMG := $(DIST_DIR)/$(DMG_NAME).dmg

all: install-cli

build: clean
	echo "$(BLUE)Building $(APP_NAME)...$(NC)"
	echo "  Creating build directory...$(NC)"
	mkdir -p $(APP_BUNDLE)

	echo "  Copying app contents...$(NC)"
	cp -R Contents $(APP_BUNDLE)/

	echo "  Copying icon...$(NC)"
	if [ -f "Contents/Resources/applet.icns" ]; then \
		cp Contents/Resources/applet.icns $(RESOURCES_DIR)/applet.icns; \
	fi

	echo "  Compiling AppleScript...$(NC)"
	mkdir -p $(SCRIPTS_DIR)
	osacompile -o $(SCRIPTS_DIR)/main.scpt main.applescript

	echo "  Setting permissions...$(NC)"
	chmod +x $(RESOURCES_DIR)/nvim_url.sh
	chmod +x $(CONTENTS_DIR)/MacOS/applet

	if [ -d "$(CONTENTS_DIR)/_CodeSignature" ]; then \
		echo "  Removing old code signature...$(NC)"; \
		rm -rf $(CONTENTS_DIR)/_CodeSignature; \
	fi

	echo ""
	echo "  Finished! App bundle created at: $(BLUE)$(APP_BUNDLE)$(NC)"
	echo ""

clean:
	if [ -d "$(BUILD_DIR)" ]; then \
		echo "$(YELLOW)Cleaning previous build...$(NC)"; \
		echo "  Removing the build directory: $(YELLOW)$(BUILD_DIR)$(NC)"; \
		rm -rf $(BUILD_DIR); \
    \
		echo ""; \
		echo "  All cleaned up!"; \
		echo ""; \
	fi

install: uninstall build
	echo "$(GREEN)Installing $(APP_NAME) to /Applications...$(NC)"
	cp -R $(APP_BUNDLE) /Applications/

	echo ""
	echo "  Done! Installed to $(GREEN)/Applications/$(APP_NAME)$(NC)"
	echo ""
	echo "  Try it out by running, and it should open this project's README:"
	echo "    $(BLUE)open 'nvim://file/$(CURDIR)/README.md:10'$(NC)"
	echo ""

uninstall:
	echo "$(YELLOW)Uninstalling $(APP_NAME) from /Applications...$(NC)"

	echo ""
	if [ -d "/Applications/$(APP_NAME)" ]; then \
		echo "  Removing /Applications/$(APP_NAME)..."; \
		rm -rf "/Applications/$(APP_NAME)"; \
		\
		echo ""; \
		echo "  $(GREEN)Done!$(NC)"; \
	else \
		echo "  $(YELLOW)App not found in /Applications$(NC)"; \
	fi
	echo ""

install-cli: uninstall-cli install
	echo "$(GREEN)Installing nvim_url CLI...$(NC)"
	echo ""

	if [ ! -f "$(CLI_SOURCE)" ]; then \
		echo "$(RED)Error: $(CLI_SOURCE) not found$(NC)"; \
		echo "$(YELLOW)Make sure the source file exists$(NC)"; \
		exit 1; \
	fi

	echo "  Creating symlink at $(BLUE)$(CLI_INSTALL_PATH)$(NC)"
	echo "  $(YELLOW)This requires administrator privileges$(NC)"
	sudo ln -sf "$(CURDIR)/$(CLI_SOURCE)" "$(CLI_INSTALL_PATH)"
	sudo chmod +x "$(CLI_INSTALL_PATH)"
	echo ""

	echo "  $(GREEN)Done!$(NC) You can now use: $(BLUE)nvim_url <file>$(NC)"
	echo ""
	echo "  Examples:"
	echo "    $(BLUE)nvim_url README.md$(NC)"
	echo "    $(BLUE)nvim_url README.md:10$(NC)"
	echo ""

uninstall-cli:
	echo "$(YELLOW)Uninstalling nvim_url CLI...$(NC)"

	echo ""
	if [ -L "$(CLI_INSTALL_PATH)" ]; then \
		echo "  Removing symlink at $(BLUE)$(CLI_INSTALL_PATH)$(NC)"; \
		echo "  $(YELLOW)This requires administrator privileges$(NC)"; \
		sudo rm "$(CLI_INSTALL_PATH)"; \
		\
		echo ""; \
		echo "  $(GREEN)Done!$(NC)"; \
	else \
		echo "  $(YELLOW)CLI not found at $(CLI_INSTALL_PATH)$(NC)"; \
	fi
	echo ""

dmg: build
	echo "$(GREEN)Packaging $(APP_NAME) into DMG...$(NC)"

	if [ ! -d "$(APP_BUNDLE)" ]; then \
		echo "$(RED)Error: Build not found at $(APP_BUNDLE)$(NC)"; \
		echo "$(YELLOW)Run 'make build' first$(NC)"; \
		exit 1; \
	fi

	if [ -d "$(DMG_TEMP)" ]; then \
		echo "$(YELLOW)Cleaning previous DMG temp files...$(NC)"; \
		rm -rf $(DMG_TEMP); \
	fi

	echo "  Creating dist directory..."
	mkdir -p $(DIST_DIR)

	echo "$(YELLOW)Creating DMG contents...$(NC)"
	mkdir -p $(DMG_TEMP)

	echo "  Copying app to temp directory..."
	cp -R $(APP_BUNDLE) $(DMG_TEMP)/

	echo "  Creating Applications symlink..."
	ln -s /Applications $(DMG_TEMP)/Applications

	echo "$(YELLOW)Creating DMG image...$(NC)"
	if [ -f "$(FINAL_DMG)" ]; then \
		rm $(FINAL_DMG); \
	fi

	hdiutil create -volname "$(VOLUME_NAME)" \
		-srcfolder $(DMG_TEMP) \
		-ov \
		-format UDZO \
		$(FINAL_DMG)

	echo "$(YELLOW)Cleaning up...$(NC)"
	rm -rf $(DMG_TEMP)

	echo ""
	echo "$(GREEN)DMG created successfully!$(NC)"
	echo "Location: $(YELLOW)$(FINAL_DMG)$(NC)"
	echo ""
	echo "To test the DMG:"
	echo "  open $(FINAL_DMG)"
	echo ""
	echo "File size:"
	ls -lh $(FINAL_DMG) | awk '{print "  " $$5}'
	echo ""



