#!/bin/bash

# Ultimate Claude Code Setup Script
# Automatically installs and configures everything for optimal Claude Code experience

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════════════════════╗"
echo "║                   ULTIMATE CLAUDE CODE SETUP                                ║"
echo "║                                                                                  ║"
echo "║  Complete automatic setup for Claude Code with all recommended files,           ║"
echo "║  MCP servers, project templates, and intelligent project creation               ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SETUP_DIR="$(dirname "$SCRIPT_DIR")"

print_status "Claude setup directory: $CLAUDE_SETUP_DIR"

# Check if we're in the right location
if [ ! -f "$CLAUDE_SETUP_DIR/scripts/install-claude-setup.sh" ]; then
    echo -e "${RED}Error: Cannot find Claude setup files. Please run this from the claude-setup directory.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE} What this will install:${NC}"
echo "• All recommended MCP servers (Context7, Zen, Filesystem, Playwright, etc.)"
echo "• Project templates for Python, FastAPI, React, ML, Data Science"
echo "• remove_emojis.py script automatically added to every project root"
echo "• Neovim configured as Python IDE with LSP, plugins, and Claude integration"
echo "• Ghostty terminal layout script for optimal development workflow"
echo "• Custom Claude slash commands for enhanced workflows"
echo "• Automatic project creation: claude-new <project-name>"
echo "• Shell integration and helpful aliases"
echo "• VS Code integration and settings"
echo "• Environment configuration templates"
echo ""

read -p " Start automatic Claude Code setup? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Run the main installation script
print_status "Running Claude Code installation script..."
"$CLAUDE_SETUP_DIR/scripts/install-claude-setup.sh"

# Setup Neovim Python IDE
print_status "Setting up Neovim Python IDE..."
"$CLAUDE_SETUP_DIR/scripts/setup-neovim.sh"

# Additional setup for Docker environment integration
if [ -f "$(dirname "$CLAUDE_SETUP_DIR")/orchestrator.sh" ]; then
    print_status "Integrating with Docker development environment..."
    
    # Create integration function
    cat >> ~/.zshrc << 'EOF'

# Neovim and Development Workflow
# ===================================

# Set Neovim as default editor
export EDITOR=nvim
export VISUAL=nvim
alias vim=nvim
alias vi=nvim
alias nano=nvim  # Replace nano with nvim

# Ghostty development layout
alias dev-layout='~/docker-dev-environment/claude-setup/scripts/start-dev-layout.sh'
alias ghostty-dev='~/docker-dev-environment/claude-setup/scripts/start-dev-layout.sh'

# Neovim shortcuts
alias nv='nvim'
alias nvim-config='nvim ~/.config/nvim/init.vim'
alias nvim-plugins='nvim +PlugInstall +qall'
alias nvim-update='nvim +PlugUpdate +qall'

# Python development with Neovim
code-python() {
    local dir="${1:-.}"
    cd "$dir"
    ~/docker-dev-environment/claude-setup/scripts/start-dev-layout.sh "$(pwd)"
}

# Quick project setup with Neovim
quick-python() {
    local project_name="$1"
    if [ -z "$project_name" ]; then
        echo "Usage: quick-python <project-name>"
        return 1
    fi
    
    claude-new "$project_name"
    cd "$project_name"
    code-python
}

# Docker Environment + Claude Code Integration
# ============================================

# Start Claude development environment
claude-dev-start() {
    local env="${1:-dev}"
    cd ~/docker-dev-environment
    ./orchestrator.sh start "$env"
    echo " Claude development environment ($env) started!"
    echo "Enter with: ./orchestrator.sh enter $env"
}

# Create project in Docker environment
claude-docker-new() {
    local project_name="$1"
    local project_type="${2:-python}"
    local env="${3:-dev}"
    
    if [ -z "$project_name" ]; then
        echo "Usage: claude-docker-new <project-name> [type] [environment]"
        echo "Types: python, fastapi, react, ml, datascience"
        echo "Environments: dev, datascience, frontend, backend, ml"
        return 1
    fi
    
    cd ~/docker-dev-environment
    
    # Start appropriate environment
    ./orchestrator.sh start "$env"
    
    # Create workspace
    ./orchestrator.sh workspace "$project_name" "$env"
    
    # Enter and set up project
    echo " Creating $project_type project '$project_name' in $env environment..."
    ./orchestrator.sh enter "$env"
}

EOF

    print_success "Docker environment integration added"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════════╗"
echo "║                            SETUP COMPLETE!                                  ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN} Quick Start Commands:${NC}"
echo ""
echo -e "${YELLOW}Create New Projects:${NC}"
echo "   claude-new my-project           # Auto-detect project type"
echo "   claude-new my-api fastapi       # Create FastAPI project"
echo "   claude-new my-app react         # Create React project"
echo "   claude-new my-model ml          # Create ML project"
echo ""
echo -e "${YELLOW}Setup Existing Directory:${NC}"
echo "   cd existing-project"
echo "   claude-init python              # Add Claude configuration"
echo ""
echo -e "${YELLOW}Quick Analysis:${NC}"
echo "   claude-analyze                  # Analyze current project"
echo "   claude-review                   # Multi-AI review"
echo "   claude -p '/analyze-project'    # Use slash command"
echo ""
echo -e "${YELLOW}Environment Management:${NC}"
echo "   claude-env                      # Setup/edit .env file"
echo ""
echo -e "${YELLOW}Docker Integration (if available):${NC}"
echo "   claude-dev-start datascience    # Start data science environment"
echo "   claude-docker-new my-ml ml      # Create project in ML container"
echo ""
echo -e "${CYAN} Available Slash Commands:${NC}"
echo "   /analyze-project                # Comprehensive analysis"
echo "   /multi-ai-review               # Multi-AI collaboration"
echo "   /setup-project                 # Additional setup"
echo "   /review-project (Python)       # Python code review"
echo "   /debug-issue (Python)          # Systematic debugging"
echo "   /generate-tests (Python)       # Test generation"
echo ""
echo -e "${CYAN} MCP Servers Available:${NC}"
echo "   • Context7 - Up-to-date documentation"
echo "   • Zen - Multi-AI with DeepSeek reasoning"
echo "   • Filesystem - File operations"
echo "   • Desktop Commander - System commands"
echo "   • Web Search - Internet search"
echo "   • Frontend Testing - Jest & Cypress"
echo "   • MCP Jest - MCP server testing"
echo ""
echo -e "${YELLOW}  Next Steps:${NC}"
echo "1. Restart your shell: source ~/.zshrc"
echo "2. Edit environment template: nano ~/.env_claude_template"
echo "3. Test setup: claude-new test-project"
echo "4. Start coding with AI assistance!"
echo ""
echo -e "${GREEN} Claude Code is now supercharged for development! ${NC}"

# Test basic functionality
print_status "Testing basic functionality..."
if command -v claude &> /dev/null; then
    print_success "✓ Claude Code available"
else
    print_warning " Claude Code not found in PATH"
fi

if [ -f ~/.claude-setup/create-claude-project.sh ]; then
    print_success "✓ Project creator installed"
else
    print_warning " Project creator not found"
fi

echo ""
echo -e "${BLUE} Pro Tips:${NC}"
echo "• Use 'claude-new' for new projects with automatic setup"
echo "• Run '/analyze-project' in any project for comprehensive analysis"
echo "• Use Zen MCP with DeepSeek for advanced AI reasoning"
echo "• Ghostty layout: ~/docker-dev-environment/claude-setup/scripts/start-dev-layout.sh"
echo "• Neovim setup: nvim +PlugInstall +qall (install plugins)"
echo "• Custom slash commands provide specialized workflows"
echo ""
echo -e "${GREEN}Happy coding with your AI-powered development setup! ${NC}"
