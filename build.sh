#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building nvim_url.app...${NC}"

# Clean previous build
if [ -d "build" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf build
fi

# Create build directory
mkdir -p build/nvim_url.app

# Copy the Contents directory
echo -e "${YELLOW}Copying app contents...${NC}"
cp -R Contents build/nvim_url.app/

# Compile the AppleScript
echo -e "${YELLOW}Compiling AppleScript...${NC}"
mkdir -p build/nvim_url.app/Contents/Resources/Scripts
osacompile -o build/nvim_url.app/Contents/Resources/Scripts/main.scpt main.applescript

# Ensure the bash script is executable
chmod +x build/nvim_url.app/Contents/Resources/nvim_url.sh
chmod +x build/nvim_url.app/Contents/MacOS/applet

# Remove code signature (it will be invalid after copying)
if [ -d "build/nvim_url.app/Contents/_CodeSignature" ]; then
    echo -e "${YELLOW}Removing old code signature...${NC}"
    rm -rf build/nvim_url.app/Contents/_CodeSignature
fi

echo -e "${GREEN}Build complete!${NC}"
echo -e "App bundle created at: ${YELLOW}build/nvim_url.app${NC}"
echo ""
echo "To install:"
echo "  cp -R build/nvim_url.app /Applications/"
echo ""
echo "To test:"
echo "  open build/nvim_url.app"
echo "  open 'nvim://file/~/.zshrc:1'"
