# Neovim URL Handler

A macOS URL handler for `nvim://` URLs that intelligently opens files in existing Neovim instances running in kitty terminal windows.

## Features

- **Smart Instance Selection**: Automatically finds the best Neovim instance to open files in, based on matching current working directories
- **Fallback Strategy**: If no matching Neovim instance exists, opens a new tab in an existing kitty terminal, or launches a new kitty instance as a last resort
- **Line Number Support**: Opens files at specific line numbers using the `nvim://file/path/to/file.txt:42` syntax
- **URL Decoding**: Properly handles URL-encoded paths
- **Tilde Expansion**: Supports `~` for home directory paths

## How It Works

When you click a `nvim://` link or open such a URL:

1. The AppleScript handler receives the URL
2. It extracts the file path and optional line number
3. The bash script (`nvim_url_handler.sh`) analyzes all running kitty terminals and Neovim instances
4. It selects the best match based on:
   - Neovim instances with matching working directories
   - Kitty terminals with matching working directories
   - Falls back to any existing kitty instance
   - Creates a new kitty instance if none exist
5. Opens the file at the specified line number and focuses the window

## Installation

### Method 1: Download DMG (Recommended)

1. Download the latest `.dmg` file from the [Releases](https://github.com/kelvinst/nvim_url/releases) page
2. Open the DMG and drag `nvim_url` to your Applications folder
3. Right-click the app and select "Open" (required for first launch due to macOS Gatekeeper)
4. The app will now handle all `nvim://` URLs

### Method 2: Homebrew Cask

```bash
brew install --cask nvim-url-handler
```

### Method 3: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/kelvinst/nvim_url.git
   cd nvim_url
   ```

2. Build the app:
   ```bash
   ./build.sh
   ```

3. Install to Applications:
   ```bash
   cp -R build/nvim_url.app /Applications/
   ```

4. Open the app once to register the URL handler

## Usage

Once installed, you can open files in Neovim by clicking `nvim://` URLs or using them in other applications.

### URL Format

```
nvim://file/<path>:<line>
```

- `<path>`: Absolute or relative file path (supports `~` for home directory)
- `<line>`: Optional line number to jump to

### Examples

```
nvim://file/~/.zshrc
nvim://file/~/Developer/myproject/src/main.rs:42
nvim://file//Users/username/Documents/notes.md:10
```

### Testing

You can test the handler from the command line:

```bash
open "nvim://file/~/.zshrc:1"
```

## Requirements

- macOS 10.6 or later
- [kitty terminal](https://sw.kovidgoyal.net/kitty/)
- [Neovim](https://neovim.io/)
- `jq` (for JSON parsing) - install via `brew install jq`

### Neovim Configuration

For the handler to connect to existing Neovim instances, you need to start Neovim with a socket:

```bash
nvim --listen /tmp/nvim-$$.sock
```

Or configure your shell to always start Neovim with a listener. Add to your `.zshrc` or `.bashrc`:

```bash
alias nvim='nvim --listen /tmp/nvim-$$.sock'
```

## Troubleshooting

### Logs

The handler writes logs to `/tmp/nvim_url_handler.log`. Check this file if URLs aren't working as expected:

```bash
tail -f /tmp/nvim_url_handler.log
```

### Permissions

On first run, macOS may ask for permissions to control other applications. This is required for the handler to focus kitty windows and communicate with Neovim.

### URL Handler Not Working

If clicking `nvim://` URLs doesn't work:

1. Make sure the app is in your `/Applications` folder
2. Open the app manually once to register it as a URL handler
3. Restart your browser or application

## Development

### Project Structure

```
.
├── Contents/
│   ├── Info.plist              # App metadata and URL scheme registration
│   ├── MacOS/
│   │   └── applet              # AppleScript executable
│   ├── Resources/
│   │   ├── Scripts/
│   │   │   └── main.scpt       # AppleScript URL handler
│   │   └── nvim_url_handler.sh # Bash script for routing logic
│   └── _CodeSignature/
├── build.sh                     # Build script
├── package-dmg.sh              # DMG packaging script
└── README.md
```

### Building

Run the build script to compile the app:

```bash
./build.sh
```

### Creating a DMG

To create a distributable DMG:

```bash
./package-dmg.sh
```

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
