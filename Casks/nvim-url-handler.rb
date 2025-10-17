cask "nvim-url-handler" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/YOUR_USERNAME/nvim_url.app/releases/download/v#{version}/nvim_url-#{version}.dmg"
  name "Neovim URL Handler"
  desc "macOS URL handler for nvim:// URLs"
  homepage "https://github.com/YOUR_USERNAME/nvim_url.app"

  depends_on formula: "jq"
  depends_on cask: "kitty"

  app "nvim_url.app"

  postflight do
    system_command "/usr/bin/open",
                   args: ["-a", "#{appdir}/nvim_url.app"],
                   print_stderr: false
  end

  zap trash: [
    "/tmp/nvim_url_handler.log",
  ]

  caveats <<~EOS
    nvim-url-handler has been installed!

    The app has been opened once to register the nvim:// URL handler.

    Usage:
      nvim://file/<path>:<line>

    Example:
      open "nvim://file/~/.zshrc:1"

    For Neovim to work with this handler, you need to start it with a socket:
      nvim --listen /tmp/nvim-$$.sock

    Or add this alias to your shell config:
      alias nvim='nvim --listen /tmp/nvim-$$.sock'

    Logs are written to: /tmp/nvim_url_handler.log
  EOS
end
