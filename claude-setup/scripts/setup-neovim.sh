#!/bin/bash

# Neovim Python IDE Setup Script
# Installs and configures Neovim as a complete Python development environment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE} Setting up Neovim Python IDE${NC}"

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${YELLOW}  Neovim not found. Installing...${NC}"
    
    # Install on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install neovim
        else
            echo "Please install Homebrew first or install Neovim manually"
            exit 1
        fi
    # Install on Linux
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y neovim
        elif command -v yum &> /dev/null; then
            sudo yum install -y neovim
        else
            echo "Please install Neovim manually for your Linux distribution"
            exit 1
        fi
    fi
fi

echo -e "${GREEN} Neovim found${NC}"

# Create Neovim config directory
echo -e "${BLUE} Creating Neovim configuration directory${NC}"
mkdir -p ~/.config/nvim
mkdir -p ~/.config/nvim/backup
mkdir -p ~/.config/nvim/swap
mkdir -p ~/.config/nvim/undo

# Install vim-plug
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    echo -e "${BLUE} Installing vim-plug plugin manager${NC}"
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo -e "${GREEN} vim-plug installed${NC}"
fi

# Copy Neovim configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/configs"

if [ -f "$CONFIG_DIR/nvim-init.vim" ]; then
    echo -e "${BLUE}  Installing Neovim configuration${NC}"
    cp "$CONFIG_DIR/nvim-init.vim" ~/.config/nvim/init.vim
    echo -e "${GREEN} Neovim configuration installed${NC}"
else
    echo -e "${YELLOW}  Neovim config not found at $CONFIG_DIR/nvim-init.vim${NC}"
fi

# Install Python LSP server
echo -e "${BLUE} Installing Python LSP server${NC}"
pip3 install --user python-lsp-server[all] python-lsp-black python-lsp-isort

# Install additional tools for Python development
echo -e "${BLUE} Installing Python development tools${NC}"
pip3 install --user black isort flake8 mypy pylint

# Install Node.js tools for some plugins
if command -v npm &> /dev/null; then
    echo -e "${BLUE} Installing Node.js tools for Neovim${NC}"
    npm install -g tree-sitter-cli
fi

# Set nvim as default editor
echo -e "${BLUE}  Setting Neovim as default editor${NC}"

# Add to shell configurations
SHELL_CONFIGS=(~/.bashrc ~/.zshrc ~/.profile)
for config in "${SHELL_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        if ! grep -q "export EDITOR=nvim" "$config"; then
            echo "" >> "$config"
            echo "# Set Neovim as default editor" >> "$config"
            echo "export EDITOR=nvim" >> "$config"
            echo "export VISUAL=nvim" >> "$config"
            echo "alias vim=nvim" >> "$config"
            echo "alias vi=nvim" >> "$config"
        fi
    fi
done

echo ""
echo -e "${GREEN} Neovim Python IDE setup complete!${NC}"
echo ""
echo -e "${BLUE} Next steps:${NC}"
echo "1. Restart your shell or run: source ~/.zshrc"
echo "2. Open Neovim: nvim"
echo "3. Install plugins: :PlugInstall"
echo "4. Install language servers: :LspInstall pylsp"
echo ""
echo -e "${BLUE} Key shortcuts:${NC}"
echo "  <leader>cc - Claude prompt"
echo "  <leader>ca - Claude analyze project"
echo "  <leader>py - Run Python file"
echo "  <leader>pf - Format with Black"
echo "  <leader>e  - Toggle file explorer"
echo "  <leader>ff - Find files"
echo "  <leader>fg - Live grep"
echo ""
echo -e "${BLUE} Pro tip:${NC}"
echo "Run 'nvim .' in any project directory to start coding!"
