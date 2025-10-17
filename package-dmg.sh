#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="nvim_url"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
VOLUME_NAME="Neovim URL Handler"
SOURCE_APP="build/${APP_NAME}.app"
DMG_TEMP="dmg_temp"
FINAL_DMG="dist/${DMG_NAME}.dmg"

echo -e "${GREEN}Packaging ${APP_NAME}.app into DMG...${NC}"

# Check if build exists
if [ ! -d "$SOURCE_APP" ]; then
    echo -e "${RED}Error: Build not found at $SOURCE_APP${NC}"
    echo -e "${YELLOW}Run ./build.sh first${NC}"
    exit 1
fi

# Clean previous packaging
if [ -d "$DMG_TEMP" ]; then
    echo -e "${YELLOW}Cleaning previous DMG temp files...${NC}"
    rm -rf "$DMG_TEMP"
fi

# Create dist directory
mkdir -p dist

# Create temporary DMG directory
echo -e "${YELLOW}Creating DMG contents...${NC}"
mkdir -p "$DMG_TEMP"

# Copy app to temp directory
cp -R "$SOURCE_APP" "$DMG_TEMP/"

# Create Applications symlink for easy installation
ln -s /Applications "$DMG_TEMP/Applications"

# Create a README for the DMG
cat > "$DMG_TEMP/README.txt" << 'EOL'
Neovim URL Handler Installation
================================

To install:
1. Drag "nvim_url.app" to the "Applications" folder
2. Open the app once to register the URL handler
3. You can now use nvim:// URLs to open files in Neovim

Usage:
  nvim://file/<path>:<line>

Example:
  nvim://file/~/.zshrc:1

For more information, visit:
  https://github.com/YOUR_USERNAME/nvim_url.app

Requirements:
- kitty terminal
- Neovim
- jq (install via: brew install jq)
EOL

# Create the DMG
echo -e "${YELLOW}Creating DMG image...${NC}"

# Remove old DMG if it exists
if [ -f "$FINAL_DMG" ]; then
    rm "$FINAL_DMG"
fi

# Create DMG using hdiutil
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$DMG_TEMP" \
    -ov \
    -format UDZO \
    "$FINAL_DMG"

# Clean up temp directory
echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "$DMG_TEMP"

echo -e "${GREEN}DMG created successfully!${NC}"
echo -e "Location: ${YELLOW}$FINAL_DMG${NC}"
echo ""
echo "To test the DMG:"
echo "  open $FINAL_DMG"
echo ""
echo "File size:"
ls -lh "$FINAL_DMG" | awk '{print "  " $5}'
