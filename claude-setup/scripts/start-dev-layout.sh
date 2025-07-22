#!/bin/bash

# Ghostty Development Layout Script
# Creates a three-window layout: nvim (left), terminal (top-right), claude (bottom-right)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE} Starting Ghostty Development Environment${NC}"

# Check if Ghostty is installed
if ! command -v ghostty &> /dev/null; then
    echo -e "${YELLOW}  Ghostty not found. Please install Ghostty terminal.${NC}"
    echo "Visit: https://ghostty.org"
    exit 1
fi

# Check if directory argument is provided
PROJECT_DIR="${1:-$(pwd)}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}  Directory $PROJECT_DIR does not exist${NC}"
    exit 1
fi

echo -e "${GREEN} Working directory: $PROJECT_DIR${NC}"

# Create Ghostty config for development layout
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
mkdir -p "$GHOSTTY_CONFIG_DIR"

# Create development-specific config
cat > "$GHOSTTY_CONFIG_DIR/dev-layout.conf" << 'EOF'
# Ghostty Development Layout Configuration

# Theme and appearance
theme = tokyonight-storm
font-family = "JetBrains Mono"
font-size = 14
cursor-style = bar
cursor-style-blink = true

# Window settings
window-decoration = true
window-title-font-family = "JetBrains Mono"
gtk-single-instance = false

# Terminal behavior
scrollback-limit = 10000
confirm-close-surface = false

# Colors and transparency
background-opacity = 0.95
unfocused-split-opacity = 0.8

# Keybindings for pane management
keybind = ctrl+shift+v=new_split:right
keybind = ctrl+shift+h=new_split:down
keybind = ctrl+shift+w=close_surface
keybind = ctrl+shift+left=goto_split:left
keybind = ctrl+shift+right=goto_split:right
keybind = ctrl+shift+up=goto_split:up
keybind = ctrl+shift+down=goto_split:down

# Copy/paste
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
EOF

echo -e "${GREEN}  Ghostty config created${NC}"

# Function to start Ghostty with layout
start_ghostty_layout() {
    local project_dir="$1"
    
    # Start main Ghostty window with nvim (left half)
    ghostty \
        --config="$GHOSTTY_CONFIG_DIR/dev-layout.conf" \
        --working-directory="$project_dir" \
        --command="bash" \
        --execute="nvim ." &
    
    local main_pid=$!
    sleep 2
    
    # Create right split for terminal
    ghostty \
        --config="$GHOSTTY_CONFIG_DIR/dev-layout.conf" \
        --working-directory="$project_dir" \
        --new-window=false \
        --command="bash" &
    
    sleep 1
    
    # Create bottom-right split for Claude Code
    ghostty \
        --config="$GHOSTTY_CONFIG_DIR/dev-layout.conf" \
        --working-directory="$project_dir" \
        --new-window=false \
        --command="bash" \
        --execute="echo 'Claude Code Terminal - Run: claude -p \"your prompt here\"'; bash" &
    
    wait $main_pid
}

# Alternative approach using tmux inside Ghostty for better layout control
start_tmux_layout() {
    local project_dir="$1"
    
    # Create tmux session with the desired layout
    local session_name="dev-$(basename "$project_dir")"
    
    # Kill existing session if it exists
    tmux kill-session -t "$session_name" 2>/dev/null || true
    
    # Start new tmux session
    tmux new-session -d -s "$session_name" -c "$project_dir"
    
    # Split window vertically (left and right)
    tmux split-window -h -t "$session_name:0" -c "$project_dir"
    
    # Split right pane horizontally (top and bottom right)
    tmux split-window -v -t "$session_name:0.1" -c "$project_dir"
    
    # Set up panes
    # Left pane: nvim
    tmux send-keys -t "$session_name:0.0" "nvim ." Enter
    
    # Top-right pane: terminal
    tmux send-keys -t "$session_name:0.1" "echo 'Terminal - Ready for commands'" Enter
    
    # Bottom-right pane: Claude Code
    tmux send-keys -t "$session_name:0.2" "echo 'Claude Code Terminal'" Enter
    tmux send-keys -t "$session_name:0.2" "echo 'Usage: claude -p \"your prompt here\"'" Enter
    tmux send-keys -t "$session_name:0.2" "echo 'Quick commands: claude-analyze, claude-review'" Enter
    
    # Set pane sizes (left: 50%, top-right: 25%, bottom-right: 25% of total height)
    tmux resize-pane -t "$session_name:0.0" -x 50%
    tmux resize-pane -t "$session_name:0.1" -y 50%
    
    # Start Ghostty with tmux session
    ghostty \
        --config="$GHOSTTY_CONFIG_DIR/dev-layout.conf" \
        --working-directory="$project_dir" \
        --command="tmux" \
        --execute="attach-session -t $session_name"
}

# Check if tmux is available for better layout control
if command -v tmux &> /dev/null; then
    echo -e "${GREEN}  Using tmux for precise layout control${NC}"
    start_tmux_layout "$PROJECT_DIR"
else
    echo -e "${YELLOW}  tmux not found, using basic Ghostty splits${NC}"
    start_ghostty_layout "$PROJECT_DIR"
fi

echo -e "${GREEN} Development environment started!${NC}"
echo ""
echo -e "${BLUE} Layout:${NC}"
echo "    Left: Neovim Python IDE"
echo "    Top-right: Terminal for commands"
echo "    Bottom-right: Claude Code terminal"
echo ""
echo -e "${BLUE} Key shortcuts:${NC}"
echo "   Ctrl+Shift+V: New vertical split"
echo "   Ctrl+Shift+H: New horizontal split"
echo "   Ctrl+Shift+Arrow: Navigate splits"
echo "   Ctrl+Shift+W: Close split"
echo ""
echo -e "${BLUE} Neovim shortcuts:${NC}"
echo "   <leader>cc: Claude prompt"
echo "   <leader>ca: Claude analyze project"
echo "   <leader>py: Run Python file"
echo "   <leader>pf: Format with Black"
echo "   <leader>e: Toggle file explorer"
echo ""
echo -e "${BLUE} Claude commands:${NC}"
echo "   claude -p \"your prompt\""
echo "   claude-analyze"
echo "   claude-review"
echo "   claude -p \"/analyze-project\""
