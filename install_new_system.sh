#!/bin/bash

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
echo "Setting up new macOS system..."
echo "Detected architecture: $ARCH"

# Determine expected Homebrew binary location
BREW_BINARY="$([[ "$ARCH" == "arm64" ]] && echo "/opt/homebrew/bin/brew" || echo "/usr/local/bin/brew")"

# Install Homebrew if the binary doesn't exist
if [[ ! -x "$BREW_BINARY" ]]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed at $BREW_BINARY, updating..."
    "$BREW_BINARY" update
fi

# Configure Homebrew environment
brew_init="eval \"\$($BREW_BINARY shellenv)\""
eval "$brew_init"
echo "$brew_init" >> ~/.bashrc

# Verify installation
brew doctor

# Install and configure latest bash
echo "Installing latest version of bash..."
brew install bash

# Set bash path using brew --prefix
BREW_PREFIX=$(brew --prefix)
BASH_PATH="${BREW_PREFIX}/bin/bash"

# Add the new shell to the list of allowable shells if not already present
if ! grep -q "${BASH_PATH}" /etc/shells; then
    echo "Adding bash to allowed shells..."
    echo "${BASH_PATH}" | sudo tee -a /etc/shells
fi

# Change the default shell to the new bash if not already set
if [[ "$SHELL" != "${BASH_PATH}" ]]; then
    echo "Changing default shell to new bash version..."
    chsh -s "${BASH_PATH}" "$USER"
    echo "Shell change will take effect after logging out and back in"
fi

# Display bash information
echo "Bash installation details:"
echo "Current shell: $SHELL"
echo "New bash path: ${BASH_PATH}"
echo "New bash version: $("${BASH_PATH}" --version)"

# Install additional tools
echo "Installing additional tools..."
brew install zoxide fzf oh-my-posh bat ripgrep neovim stow httpie jq goku

# Create a backup of existing .bashrc if it exists
if [ -f ~/.bashrc ]; then
    echo "Creating backup of existing .bashrc..."
    cp ~/.bashrc ~/.bashrc.backup
fi

# Configure all tools in .bashrc
echo "Configuring tools in .bashrc..."
cat << 'EOF' >> ~/.bashrc

# Environment variables
export EDITOR="nvim"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export BAT_THEME="GitHub"

# Tool initializations
eval "$(zoxide init bash)"
eval "$(oh-my-posh init bash)"

# FZF configuration
[ -f "${BREW_PREFIX}/opt/fzf/shell/completion.bash" ] && source "${BREW_PREFIX}/opt/fzf/shell/completion.bash"
[ -f "${BREW_PREFIX}/opt/fzf/shell/key-bindings.bash" ] && source "${BREW_PREFIX}/opt/fzf/shell/key-bindings.bash"

EOF

# Run fzf installer
echo "Configuring fzf..."
$(brew --prefix)/opt/fzf/install --all

echo "Installation complete! Please restart your shell or source your .bashrc"
