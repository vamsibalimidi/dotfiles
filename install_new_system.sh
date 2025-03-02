#!/bin/bash

# To install:
#   curl -o- https://raw.githubusercontent.com/vamsibalimidi/dotfiles/main/install_new_system.sh | bash
# Or:
#   wget -qO- https://raw.githubusercontent.com/vamsibalimidi/dotfiles/main/install_new_system.sh | bash
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

# Install Homebrew if it's not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    
    if [[ "$OS" == "Darwin" ]]; then
        # macOS installation
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Configure Homebrew based on architecture
        if [[ "$ARCH" == "arm64" ]]; then
            echo "Configuring Homebrew for Apple Silicon..."
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo "Configuring Homebrew for Intel Mac..."
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    elif [[ "$OS" == "Linux" ]]; then
        # Linux installation in home directory
        HOMEBREW_PREFIX="$HOME/.homebrew"
        echo "Installing Homebrew in $HOMEBREW_PREFIX"
        
        # Install prerequisites
        sudo apt-get update
        sudo apt-get install -y build-essential curl file git

        # Install Homebrew in custom location
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Configure Homebrew environment
        echo "Configuring Homebrew environment..."
        echo "export HOMEBREW_PREFIX=\"$HOMEBREW_PREFIX\"" >> ~/.profile
        echo 'eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"' >> ~/.profile
        eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed, updating..."
    brew update
fi

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

# Configure fzf
echo "Configuring fzf..."
$(brew --prefix)/opt/fzf/install --all

# Configure zoxide
echo "Configuring zoxide..."
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc

# Configure oh-my-posh
echo "Configuring oh-my-posh..."
echo 'eval "$(oh-my-posh init bash)"' >> ~/.bashrc

# Configure bat
echo "Configuring bat..."
if [[ "$OS" == "Darwin" ]]; then
    # Use default macOS theme
    echo 'export BAT_THEME="GitHub"' >> ~/.bashrc
else
    # Use a dark theme for Linux
    echo 'export BAT_THEME="OneHalfDark"' >> ~/.bashrc
fi

# Configure ripgrep
echo "Configuring ripgrep..."
echo 'export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"' >> ~/.bashrc

# Configure simple nvim alias
echo 'export EDITOR="nvim"' >> ~/.bashrc

echo "Installation complete! Please restart your shell or source your .bashrc"
