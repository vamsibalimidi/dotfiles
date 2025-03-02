#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# To install:
#   curl -o- https://raw.githubusercontent.com/vamsibalimidi/dotfiles/main/install_new_system.sh | /bin/bash
# Or:
#   wget -qO- https://raw.githubusercontent.com/vamsibalimidi/dotfiles/main/install_new_system.sh | /bin/bash
#
# To download without running:
#   curl -o install_new_system.sh https://raw.githubusercontent.com/vamsibalimidi/dotfiles/main/install_new_system.sh
#   chmod +x install_new_system.sh
#   ./install_new_system.sh

# Detect architecture
ARCH="$(uname -m)"
echo "$(date) - Setting up new macOS system..."
echo "$(date) - Detected architecture: $ARCH"

# Determine expected Homebrew binary location
BREW_BINARY="$([[ "$ARCH" == "arm64" ]] && echo "/opt/homebrew/bin/brew" || echo "/usr/local/bin/brew")"

# Check if Homebrew is installed
if [[ ! -x "$BREW_BINARY" ]]; then
    echo "$(date) - Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "$(date) - Homebrew is already installed at $BREW_BINARY, updating..."
    "$BREW_BINARY" update
fi

# Configure Homebrew environment
echo "$(date) - Configuring Homebrew environment..."
if ! grep -q "eval \$(\"$BREW_BINARY\" shellenv)" ~/.bashrc; then
  brew shellenv | tee -a ~/.bashrc
fi
source ~/.bashrc

# Verify installation
echo "$(date) - Verifying Homebrew installation..."
brew doctor

# Install and configure latest bash
echo "$(date) - Installing latest version of bash..."
brew install bash

# Set bash path using brew --prefix
BREW_PREFIX="$("$BREW_BINARY" --prefix)"
BASH_PATH="${BREW_PREFIX}/bin/bash"

# Add the new shell to the list of allowable shells if not already present
if ! grep -q "${BASH_PATH}" /etc/shells; then
    echo "$(date) - Adding bash to allowed shells..."
    echo "${BASH_PATH}" | sudo tee -a /etc/shells
fi

# Change the default shell to the new bash if not already set
if [[ "$SHELL" != "${BASH_PATH}" ]]; then
    echo "$(date) - Changing default shell to new bash version..."
    chsh -s "${BASH_PATH}" "$USER"
    echo "$(date) - Shell change will take effect after logging out and back in"
fi

# Display bash information
echo "$(date) - Bash installation details:"
echo "$(date) - Current shell: $SHELL"
echo "$(date) - New bash path: ${BASH_PATH}"
echo "$(date) - New bash version: $("${BASH_PATH}" --version)"

# Install additional tools
echo "$(date) - Installing additional tools..."
for tool in zoxide fzf oh-my-posh bat ripgrep neovim stow httpie jq goku; do
  if ! which "$tool" &> /dev/null; then
    echo "$(date) - Installing $tool..."
    brew install "$tool"
  else
    echo "$(date) - $tool already installed, skipping..."
  fi
done

# Create a backup of existing .bashrc if it exists
if [ -f ~/.bashrc ] && [ ! -f ~/.bashrc.backup ]; then
    echo "$(date) - Creating backup of existing .bashrc..."
    cp ~/.bashrc ~/.bashrc.backup
fi

# Configure all tools in .bashrc
echo "$(date) - Configuring tools in .bashrc..."
if ! grep -q "export EDITOR=\"nvim\"" ~/.bashrc || ! grep -q "export RIPGREP_CONFIG_PATH" ~/.bashrc || ! grep -q "export BAT_THEME" ~/.bashrc; then
cat << 'EOF' >> ~/.bashrc

# Environment variables
export EDITOR="nvim"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export BAT_THEME="GitHub"

# Tool initializations
eval "\$(zoxide init bash)"
eval "\$(oh-my-posh init bash)"

# FZF configuration
[ -f "${BREW_PREFIX}/opt/fzf/shell/completion.bash" ] && source "${BREW_PREFIX}/opt/fzf/shell/completion.bash"
[ -f "${BREW_PREFIX}/opt/fzf/shell/key-bindings.bash" ] && source "${BREW_PREFIX}/opt/fzf/shell/key-bindings.bash"

EOF
fi

# Run fzf installer
echo "$(date) - Configuring fzf..."
if [[ ! -d "${BREW_PREFIX}/opt/fzf" ]]; then
  $(brew --prefix)/opt/fzf/install --all
fi

echo "$(date) - Installation complete! Please restart your shell or source your .bashrc"
