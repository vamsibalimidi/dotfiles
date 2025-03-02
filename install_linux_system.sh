#!/bin/bash

# To install:
#   curl -o- https://raw.githubusercontent.com/vamsibalimidi/dotfiles/main/install_linux_system.sh | /bin/bash
# Or:
#   wget -qO- https://raw.githubusercontent.com/vamsibalimidi/dotfiles/main/install_linux_system.sh | /bin/bash

echo "Setting up new Linux system (non-root installation)..."

# Set up local installation directory
LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
mkdir -p "$LOCAL_BIN" "$LOCAL_OPT"

# Add local bin to PATH if not already there
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$LOCAL_BIN:$PATH"
fi

# Backup existing .bashrc
if [ -f ~/.bashrc ]; then
    echo "Creating backup of existing .bashrc..."
    cp ~/.bashrc ~/.bashrc.backup
fi

# Install modern bash from source
echo "Installing bash from source..."
cd "$LOCAL_OPT"
curl -O https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
tar xf bash-5.2.tar.gz
cd bash-5.2
./configure --prefix="$HOME/.local"
make && make install
BASH_PATH="$LOCAL_BIN/bash"

# Install fzf
echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git "$LOCAL_OPT/fzf"
"$LOCAL_OPT/fzf/install" --bin
ln -sf "$LOCAL_OPT/fzf/bin/fzf" "$LOCAL_BIN/fzf"

# Install bat
echo "Installing bat..."
cd "$LOCAL_OPT"
BAT_VERSION="0.24.0"
curl -LO "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
tar xf "bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
ln -sf "$LOCAL_OPT/bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu/bat" "$LOCAL_BIN/bat"

# Install ripgrep
echo "Installing ripgrep..."
cd "$LOCAL_OPT"
RG_VERSION="13.0.0"
curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xf "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
ln -sf "$LOCAL_OPT/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg" "$LOCAL_BIN/rg"

# Install neovim
echo "Installing neovim from source..."
cd "$LOCAL_OPT"
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$HOME/.local"
make install
ln -sf "$LOCAL_BIN/nvim" "$LOCAL_BIN/vi"
ln -sf "$LOCAL_BIN/nvim" "$LOCAL_BIN/vim"

# Install zoxide
echo "Installing zoxide..."
cd "$LOCAL_OPT"
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- -b "$LOCAL_BIN"

# Install oh-my-posh
echo "Installing oh-my-posh..."
cd "$LOCAL_OPT"
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$LOCAL_BIN"

# Configure tools in .bashrc
echo "Configuring tools in .bashrc..."
cat << 'EOF' >> ~/.bashrc

# Environment variables
export EDITOR="nvim"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export BAT_THEME="OneHalfDark"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

# Tool initializations
eval "$(zoxide init bash)"
eval "$(oh-my-posh init bash)"

# FZF configuration
[ -f "$HOME/.local/opt/fzf/shell/completion.bash" ] && source "$HOME/.local/opt/fzf/shell/completion.bash"
[ -f "$HOME/.local/opt/fzf/shell/key-bindings.bash" ] && source "$HOME/.local/opt/fzf/shell/key-bindings.bash"

EOF

# Clean up unnecessary files
echo "Cleaning up..."
cd "$LOCAL_OPT"
# Remove archives and extracted directories
rm -rf bash-5.2.tar.gz bash-5.2/
rm -rf "bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
rm -rf "bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu"
rm -rf "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
rm -rf "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl"

# Keep only necessary directories
echo "Keeping only required files..."
echo "Note: fzf and neovim directories are kept for updates and shell integration"

echo "Installation complete! Please run: exec $BASH_PATH"
echo "Note: Some tools might require additional dependencies. If they don't work, please install required system libraries using your package manager when you have sudo access."
