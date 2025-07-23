#!/bin/bash

# Claude Code Local Installation and MCP Server Setup Script v2
# This script installs Claude Code to a custom location and configures all MCP servers
# Usage: ./install-claude-code-with-mcp-v2.sh [install_path]
# Default: $HOME/.claude-code

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get installation path from argument or use default
INSTALL_PATH="${1:-$HOME/.claude-code}"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Claude Code Installation & MCP Setup v2${NC}"
echo -e "${BLUE}=========================================${NC}"

# Validate and create installation path
echo ""
echo -e "${YELLOW}Installation Configuration:${NC}"
echo -e "Installation path: ${GREEN}$INSTALL_PATH${NC}"

# Ask for confirmation
read -p "Continue with this installation path? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 1
fi

# Create installation directories
echo ""
echo -e "${YELLOW}Creating installation directories...${NC}"
mkdir -p "$INSTALL_PATH/bin"
mkdir -p "$INSTALL_PATH/lib"
mkdir -p "$INSTALL_PATH/node_modules"
mkdir -p "$INSTALL_PATH/config"

# Set up npm prefix for this installation
export NPM_PREFIX="$INSTALL_PATH"
export PATH="$INSTALL_PATH/bin:$PATH"

# Step 1: Check and Install Claude Code
echo ""
echo -e "${YELLOW}Step 1: Installing Claude Code...${NC}"
echo "-------------------------------------------"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed. Please install Node.js and npm first.${NC}"
    exit 1
fi

# Configure npm to use our custom prefix
npm config set prefix "$INSTALL_PATH"

# Set Claude Code configuration directory
export CLAUDE_CONFIG_DIR="$INSTALL_PATH/config"

# Install Claude Code to custom location
echo -e "Installing Claude Code to ${GREEN}$INSTALL_PATH${NC}..."
npm install -g @anthropic-ai/claude-code

# Verify installation
if [ -f "$INSTALL_PATH/bin/claude" ]; then
    echo -e "${GREEN}✓ Claude Code installed successfully!${NC}"
    "$INSTALL_PATH/bin/claude" --version
else
    echo -e "${RED}✗ Claude Code installation failed!${NC}"
    exit 1
fi

# Step 2: Configure PATH
echo ""
echo -e "${YELLOW}Step 2: Configuring PATH...${NC}"
echo "-------------------------------------------"

# Function to add PATH export to a file
add_path_to_file() {
    local file=$1
    local path_line="export PATH=\"$INSTALL_PATH/bin:\$PATH\""
    local config_line="export CLAUDE_CONFIG_DIR=\"$INSTALL_PATH/config\""
    local claude_function="claude() { CLAUDE_CONFIG_DIR=\"$INSTALL_PATH/config\" \"$INSTALL_PATH/bin/claude\" \"\$@\"; }"
    
    if [ -f "$file" ]; then
        # Remove old entries if they exist
        sed -i.bak "/claude-code.*bin/d" "$file" 2>/dev/null || true
        sed -i.bak "/^claude() {/d" "$file" 2>/dev/null || true
        sed -i.bak "/CLAUDE_CONFIG_DIR/d" "$file" 2>/dev/null || true
        
        # Add new entries
        echo "" >> "$file"
        echo "# Claude Code - Added by install script" >> "$file"
        echo "$path_line" >> "$file"
        echo "$config_line" >> "$file"
        echo "$claude_function" >> "$file"
        echo -e "${GREEN}✓ Updated $file${NC}"
    fi
}

# Update shell configuration files
add_path_to_file "$HOME/.bashrc"
add_path_to_file "$HOME/.zshrc"
add_path_to_file "$HOME/.profile"

# Create a system-wide launcher script
LAUNCHER_SCRIPT="/usr/local/bin/claude"
if [ -w "/usr/local/bin" ]; then
    echo ""
    echo -e "${YELLOW}Creating system-wide launcher (requires sudo)...${NC}"
    sudo tee "$LAUNCHER_SCRIPT" > /dev/null << EOF
#!/bin/bash
# Claude Code launcher script
export CLAUDE_CONFIG_DIR="$INSTALL_PATH/config"
exec "$INSTALL_PATH/bin/claude" "\$@"
EOF
    sudo chmod +x "$LAUNCHER_SCRIPT"
    echo -e "${GREEN}✓ Created system launcher at $LAUNCHER_SCRIPT${NC}"
else
    # Create user-local launcher
    USER_BIN="$HOME/bin"
    mkdir -p "$USER_BIN"
    LAUNCHER_SCRIPT="$USER_BIN/claude"
    cat > "$LAUNCHER_SCRIPT" << EOF
#!/bin/bash
# Claude Code launcher script
export CLAUDE_CONFIG_DIR="$INSTALL_PATH/config"
exec "$INSTALL_PATH/bin/claude" "\$@"
EOF
    chmod +x "$LAUNCHER_SCRIPT"
    echo -e "${GREEN}✓ Created user launcher at $LAUNCHER_SCRIPT${NC}"
    
    # Add ~/bin to PATH if needed
    if [[ ":$PATH:" != *":$USER_BIN:"* ]]; then
        for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [ -f "$file" ]; then
                sed -i "s|export PATH=\"$INSTALL_PATH/bin:\$PATH\"|export PATH=\"$USER_BIN:$INSTALL_PATH/bin:\$PATH\"|g" "$file"
            fi
        done
    fi
fi

# Step 3: Configure MCP Servers
echo ""
echo -e "${YELLOW}Step 3: Configuring MCP Servers...${NC}"
echo "-----------------------------"

# Detect and migrate existing configurations
echo -e "${BLUE}Checking for existing Claude Code configurations...${NC}"

# Common config locations including current workspace
OLD_CONFIG_DIRS=(
    "$HOME/.config/claude"
    "$HOME/.claude-code"
    "$HOME/.claude"
    "/opt/claude-code/config"
    "/workspace/.claude-code"
    "$(pwd)/.claude-code"
)

# Check for existing Claude Code installation and MCP servers
MIGRATED=false
echo -e "${BLUE}Checking for existing Claude Code with MCP servers...${NC}"

# Try to detect existing claude command and export its MCP config
if command -v claude &> /dev/null; then
    echo -e "${YELLOW}Found existing Claude Code installation${NC}"
    echo -e "Exporting MCP server configuration..."
    
    # Create temp file for MCP export
    TEMP_MCP_CONFIG=$(mktemp)
    
    # Try to export existing MCP config
    if claude mcp export > "$TEMP_MCP_CONFIG" 2>/dev/null && [ -s "$TEMP_MCP_CONFIG" ]; then
        echo -e "${GREEN}✓ MCP servers exported successfully${NC}"
        MIGRATED=true
        
        # Import to new installation after it's set up
        echo -e "Will import MCP servers to new installation..."
    else
        echo -e "${YELLOW}No MCP servers found in existing installation${NC}"
        rm -f "$TEMP_MCP_CONFIG"
    fi
else
    echo -e "${BLUE}No existing Claude Code installation found${NC}"
fi

# Configure MCP servers - import if we have exported config
if [ "$MIGRATED" = true ] && [ -f "$TEMP_MCP_CONFIG" ]; then
    echo -e "${BLUE}Importing MCP servers to new installation...${NC}"
    
    # Import the MCP config to the new installation
    if CLAUDE_CONFIG_DIR="$INSTALL_PATH/config" "$INSTALL_PATH/bin/claude" mcp import < "$TEMP_MCP_CONFIG" 2>/dev/null; then
        echo -e "${GREEN}✓ MCP servers imported successfully${NC}"
        
        # Verify the import worked
        echo -e "${BLUE}Verifying MCP server connections...${NC}"
        CLAUDE_CONFIG_DIR="$INSTALL_PATH/config" "$INSTALL_PATH/bin/claude" mcp list || {
            echo -e "${YELLOW}Import verification failed, will reconfigure servers...${NC}"
            MIGRATED=false
        }
    else
        echo -e "${YELLOW}Import failed, will reconfigure servers...${NC}"
        MIGRATED=false
    fi
    
    # Clean up temp file
    rm -f "$TEMP_MCP_CONFIG"
fi

if [ "$MIGRATED" = false ]; then
    echo -e "${BLUE}Configuring MCP servers for current installation...${NC}"
    
    # Function to add MCP server and check result
add_mcp_server() {
    local name=$1
    shift
    
    # Always reconfigure to ensure correct paths
    echo -e "Configuring ${BLUE}$name${NC}..."
    
    # Remove if exists
    CLAUDE_CONFIG_DIR="$INSTALL_PATH/config" "$INSTALL_PATH/bin/claude" mcp remove "$name" 2>/dev/null || true
    
    # Add with new configuration
    if CLAUDE_CONFIG_DIR="$INSTALL_PATH/config" "$INSTALL_PATH/bin/claude" mcp add "$name" "$@" 2>/dev/null; then
        echo -e "${GREEN}✓ $name configured successfully${NC}"
    else
        echo -e "${RED}✗ Failed to configure $name${NC}"
    fi
}

# Add filesystem-server - provides file system access
add_mcp_server "filesystem-server" "npx" "-y" "@modelcontextprotocol/server-filesystem" "."

# Add context7-server - provides documentation retrieval
add_mcp_server "context7-server" "npx" "@upstash/context7-mcp"

# Add desktop-commander - provides desktop automation
add_mcp_server "desktop-commander" "npx" "@wonderwhy-er/desktop-commander"

# Add zen server - provides AI assistant tools
ZEN_SERVER_PATH="/home/devuser/.zen-mcp-server"
if [ -f "$ZEN_SERVER_PATH/server.py" ] && [ -f "$ZEN_SERVER_PATH/venv/bin/python" ]; then
    add_mcp_server "zen" "$ZEN_SERVER_PATH/venv/bin/python" "$ZEN_SERVER_PATH/server.py"
else
    echo -e "${YELLOW} Zen server not found at $ZEN_SERVER_PATH${NC}"
    echo "  To install zen server manually:"
    echo "  1. Clone/install zen-mcp-server"
    echo "  2. Run: claude mcp add zen /path/to/venv/bin/python /path/to/server.py"
fi

# Add jest-server - provides Jest testing integration
    add_mcp_server "jest-server" "npx" "mcp-jest"
fi

# Step 4: Verify Installation
echo ""
echo -e "${YELLOW}Step 4: Verifying Installation...${NC}"
echo "--------------------------------"
echo "Checking Claude Code installation..."
CLAUDE_CONFIG_DIR="$INSTALL_PATH/config" "$INSTALL_PATH/bin/claude" --version

echo ""
echo "Checking MCP server connections..."
CLAUDE_CONFIG_DIR="$INSTALL_PATH/config" "$INSTALL_PATH/bin/claude" mcp list

# Create uninstall script
echo ""
echo -e "${YELLOW}Creating uninstall script...${NC}"
cat > "$INSTALL_PATH/uninstall.sh" << EOF
#!/bin/bash
# Claude Code Uninstaller

echo "This will remove Claude Code from: $INSTALL_PATH"
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ \$REPLY =~ ^[Yy]$ ]]; then
    # Remove installation directory
    rm -rf "$INSTALL_PATH"
    
    # Remove PATH entries from shell configs
    for file in ~/.bashrc ~/.zshrc ~/.profile; do
        if [ -f "\$file" ]; then
            sed -i.bak "/claude-code.*bin/d" "\$file" 2>/dev/null || true
            sed -i.bak "/^claude() {/d" "\$file" 2>/dev/null || true
            sed -i.bak "/CLAUDE_CONFIG_DIR/d" "\$file" 2>/dev/null || true
        fi
    done
    
    # Remove launcher scripts
    [ -f "/usr/local/bin/claude" ] && sudo rm -f "/usr/local/bin/claude"
    [ -f "$HOME/bin/claude" ] && rm -f "$HOME/bin/claude"
    
    echo "Claude Code has been uninstalled."
else
    echo "Uninstall cancelled."
fi
EOF
chmod +x "$INSTALL_PATH/uninstall.sh"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}Claude Code is installed at:${NC} $INSTALL_PATH"
echo -e "${BLUE}Configuration directory:${NC} $INSTALL_PATH/config"
echo ""
echo -e "${BLUE}Available MCP servers:${NC}"
echo "- filesystem-server: File system access"
echo "- context7-server: Documentation retrieval"
echo "- desktop-commander: Desktop automation"
echo "- zen: AI assistant tools (if available)"
echo "- jest-server: Jest testing integration"
echo ""
echo -e "${YELLOW}To start using Claude Code:${NC}"
echo "1. Reload your shell: source ~/.bashrc (or ~/.zshrc)"
echo "2. Run: claude"
echo ""
echo -e "${YELLOW}Alternative methods:${NC}"
echo "- Use full path: $INSTALL_PATH/bin/claude"
echo "- Use npx: npx claude"
echo ""
echo -e "${YELLOW}Important:${NC} MCP servers are configured specifically for this installation."
echo "The configuration is stored in: $INSTALL_PATH/config"
echo ""
echo -e "${YELLOW}To uninstall:${NC} $INSTALL_PATH/uninstall.sh"
echo ""

# Test if claude command works in current shell
if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓ 'claude' command is ready to use!${NC}"
else
    echo -e "${YELLOW}Note: Run 'source ~/.bashrc' to use 'claude' in current session${NC}"
fi