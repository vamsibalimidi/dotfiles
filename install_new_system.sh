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

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "Setting up new system..."
echo "Detected OS: $OS"
echo "Detected architecture: $ARCH"

# Determine expected Homebrew binary location
if [[ "$OS" == "Darwin" ]]; then
    if [[ "$ARCH" == "arm64" ]]; then
        BREW_BINARY="/opt/homebrew/bin/brew"
    else
        BREW_BINARY="/usr/local/bin/brew"
    fi
else
    BREW_BINARY="$HOME/.homebrew/bin/brew"
fi

# Install Homebrew if the binary doesn't exist
if [[ ! -x "$BREW_BINARY" ]]; then
    echo "Installing Homebrew..."
    
    if [[ "$OS" == "Linux" ]]; then
        # Linux prerequisites
        sudo apt-get update
        sudo apt-get install -y build-essential curl file git
        
        # Set custom Homebrew location for Linux
        export HOMEBREW_PREFIX="$HOME/.homebrew"
    fi
    
    # Install Homebrew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed at $BREW_BINARY, updating..."
    "$BREW_BINARY" update
fi

# Configure Homebrew environment
if [[ "$OS" == "Linux" ]]; then
    echo "export HOMEBREW_PREFIX=\"$HOMEBREW_PREFIX\"" >> ~/.bashrc
else
    # Set up Homebrew in current shell and bashrc
    brew_init="eval \"\$($BREW_BINARY shellenv)\""
    eval "$brew_init"
    echo "$brew_init" >> ~/.bashrc
fi

source ~/.bashrc

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
brew install zoxide fzf oh-my-posh bat ripgrep neovim stow httpie jq

# Install cask applications
echo "Installing cask applications..."
brew install --cask goku

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
export BAT_THEME="$([ "$(uname -s)" = "Darwin" ] && echo 'GitHub' || echo 'OneHalfDark')"

# Tool initializations
eval "$(zoxide init bash)"
eval "$(oh-my-posh init bash)"

# Install fzf key bindings and completion
[ -f "${BREW_PREFIX}/opt/fzf/shell/completion.bash" ] && source "${BREW_PREFIX}/opt/fzf/shell/completion.bash"
[ -f "${BREW_PREFIX}/opt/fzf/shell/key-bindings.bash" ] && source "${BREW_PREFIX}/opt/fzf/shell/key-bindings.bash"

EOF

# Run fzf installer
echo "Configuring fzf..."
$(brew --prefix)/opt/fzf/install --all

echo "Installation complete! Please restart your shell or source your .bashrc"
