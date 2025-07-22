#!/bin/bash

# Ultimate Development Tmux Session
# Creates a tmux session with Neovim, terminal, and Claude Code layout

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SESSION_NAME="dev-session"
PROJECT_DIR="${1:-$(pwd)}"

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}Error: tmux is not installed${NC}"
    exit 1
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    print_status "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

print_status "Creating development session: $SESSION_NAME"
print_status "Project directory: $PROJECT_DIR"

# Create new tmux session detached
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR"

# Rename the first window
tmux rename-window -t "$SESSION_NAME:0" "dev"

# ===============================
# Window 1: Main Development
# ===============================
print_status "Setting up Window 1: Main Development (Neovim + Terminal)"

# Split window vertically (left and right)
tmux split-window -h -t "$SESSION_NAME:0" -c "$PROJECT_DIR"

# Left pane: Neovim
tmux send-keys -t "$SESSION_NAME:0.0" "nvim ." Enter

# Right pane: Split horizontally (top and bottom)
tmux split-window -v -t "$SESSION_NAME:0.1" -c "$PROJECT_DIR"

# Right top pane: Terminal for commands
tmux send-keys -t "$SESSION_NAME:0.1" "# Terminal for commands and testing" Enter
tmux send-keys -t "$SESSION_NAME:0.1" "echo 'Development Terminal Ready'" Enter

# Right bottom pane: Claude Code
tmux send-keys -t "$SESSION_NAME:0.2" "# Claude Code Terminal" Enter
tmux send-keys -t "$SESSION_NAME:0.2" "echo 'Claude Code Ready - Use: claude -p \"your prompt\"'" Enter

# ===============================
# Window 2: Git and Tools
# ===============================
print_status "Setting up Window 2: Git and Tools"

# Create second window
tmux new-window -t "$SESSION_NAME" -n "git" -c "$PROJECT_DIR"

# Split into three panes
tmux split-window -h -t "$SESSION_NAME:1" -c "$PROJECT_DIR"
tmux split-window -v -t "$SESSION_NAME:1.1" -c "$PROJECT_DIR"

# Git status pane
tmux send-keys -t "$SESSION_NAME:1.0" "git status" Enter

# Git log pane
tmux send-keys -t "$SESSION_NAME:1.1" "git log --oneline -10" Enter

# Tools pane (htop, monitoring)
tmux send-keys -t "$SESSION_NAME:1.2" "htop" Enter

# ===============================
# Window 3: Docker and Services
# ===============================
print_status "Setting up Window 3: Docker and Services"

# Create third window
tmux new-window -t "$SESSION_NAME" -n "docker" -c "$PROJECT_DIR"

# Split into two panes
tmux split-window -h -t "$SESSION_NAME:2" -c "$PROJECT_DIR"

# Docker status pane
tmux send-keys -t "$SESSION_NAME:2.0" "docker ps" Enter

# Services pane
tmux send-keys -t "$SESSION_NAME:2.1" "echo 'Services and logs'" Enter

# ===============================
# Pane Size Adjustments
# ===============================
print_status "Adjusting pane sizes..."

# Main window: Make Neovim pane larger (60% width)
tmux resize-pane -t "$SESSION_NAME:0.0" -x 60%

# Right side: Make terminal pane larger (60% height)
tmux resize-pane -t "$SESSION_NAME:0.1" -y 60%

# ===============================
# Set Focus and Configure
# ===============================

# Set focus to main development window, Neovim pane
tmux select-window -t "$SESSION_NAME:0"
tmux select-pane -t "$SESSION_NAME:0.0"

# Enable mouse support
tmux set-option -t "$SESSION_NAME" mouse on

# Set status bar
tmux set-option -t "$SESSION_NAME" status-bg colour235
tmux set-option -t "$SESSION_NAME" status-fg colour255
tmux set-option -t "$SESSION_NAME" status-left "#[fg=green]#S #[fg=yellow]#I:#P "
tmux set-option -t "$SESSION_NAME" status-right "#[fg=cyan]%Y-%m-%d %H:%M"

# Window options
tmux set-window-option -t "$SESSION_NAME" window-status-current-style fg=black,bg=green

print_success "Development session created successfully!"
echo ""
echo -e "${YELLOW}Session Layout:${NC}"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│  Window 1: Main Development                            │"
echo "│  ┌─────────────────┬─────────────────────────────────┐  │"
echo "│  │                 │  Terminal (commands/testing)   │  │"
echo "│  │                 ├─────────────────────────────────┤  │"
echo "│  │     Neovim      │                                 │  │"
echo "│  │   (Python IDE)  │      Claude Code Terminal       │  │"
echo "│  │                 │                                 │  │"
echo "│  └─────────────────┴─────────────────────────────────┘  │"
echo "│                                                         │"
echo "│  Window 2: Git and Tools                               │"
echo "│  Window 3: Docker and Services                         │"
echo "└─────────────────────────────────────────────────────────┘"
echo ""
echo -e "${BLUE}Quick Commands:${NC}"
echo "• Tmux attach: tmux attach-session -t $SESSION_NAME"
echo "• Switch windows: Ctrl+b + [0,1,2]"
echo "• Navigate panes: Ctrl+b + [h,j,k,l]"
echo "• Neovim help: :DevHelp (in nvim)"
echo "• Claude Code: claude -p 'your prompt' (in Claude terminal)"
echo ""
echo -e "${GREEN}Starting session...${NC}"

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
