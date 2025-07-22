#!/bin/bash

# Claude Code Automatic Setup Script - Enhanced with Playwright and Emoji Removal
# Installs and configures Claude Code with optimal settings for all project types

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CLAUDE_SETUP_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
TEMPLATES_DIR="$CLAUDE_SETUP_DIR/templates"
GLOBAL_CONFIG_DIR="$HOME/.claude-setup"
CLAUDE_CONFIG_DIR="$HOME/.claude-code"

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                      CLAUDE CODE AUTOMATIC SETUP                         ║"
    echo "║                                                                               ║"
    echo "║  Enhanced with Playwright Testing & Emoji Removal for all projects          ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_deps=()
    
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi
    
    if ! command -v claude &> /dev/null; then
        missing_deps+=("claude")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo "Please install:"
        echo "- Node.js 18+: https://nodejs.org/"
        echo "- Python 3.9+: https://python.org/"
        echo "- Claude Code: npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
    
    print_success "All prerequisites met"
}

install_mcp_servers() {
    print_status "Installing MCP servers globally..."
    
    local servers=(
        "@upstash/context7-mcp"
        "@beehiveinnovations/zen-mcp-server"
        "@modelcontextprotocol/server-filesystem"
        "desktop-commander"
        "@anthropic-ai/mcp-web-search"
        "mcp-frontend-testing"
        "mcp-jest"
        "@playwright/test"
        "playwright"
    )
    
    for server in "${servers[@]}"; do
        print_status "Installing $server..."
        if npm install -g "$server" 2>/dev/null; then
            print_success "✓ $server installed"
        else
            print_warning " Failed to install $server (may already be installed)"
        fi
    done
}

install_playwright() {
    print_status "Installing Playwright for comprehensive web testing..."
    
    # Install Playwright globally
    if npm install -g @playwright/test 2>/dev/null; then
        print_success "✓ Playwright installed globally"
    else
        print_warning " Failed to install Playwright globally"
    fi
    
    # Install Playwright browsers
    print_status "Installing Playwright browsers..."
    if npx playwright install 2>/dev/null; then
        print_success "✓ Playwright browsers installed"
    else
        print_warning " Failed to install Playwright browsers"
    fi
}

install_python_dependencies() {
    print_status "Installing Python dependencies for emoji removal..."
    
    # Install emoji package for remove_emojis.py script
    if python3 -m pip install emoji 2>/dev/null; then
        print_success "✓ Python emoji package installed"
    else
        print_warning " Failed to install Python emoji package"
        print_status "You can install it manually with: pip install emoji"
    fi
}

setup_global_config() {
    print_status "Setting up global Claude Code configuration..."
    
    # Create global config directory
    mkdir -p "$GLOBAL_CONFIG_DIR"
    mkdir -p "$CLAUDE_CONFIG_DIR"
    
    # Copy enhanced global MCP configuration
    cat > "$CLAUDE_CONFIG_DIR/global_mcp_config.json" << 'EOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "zen": {
      "command": "npx", 
      "args": ["-y", "@beehiveinnovations/zen-mcp-server"],
      "env": {
        "OPENROUTER_API_KEY": "${OPENROUTER_API_KEY}",
        "DEFAULT_MODEL": "${DEFAULT_MODEL:-deepseek/deepseek-r1-0528}",
        "ZEN_DEFAULT_MODEL": "${ZEN_DEFAULT_MODEL:-deepseek/deepseek-r1-0528}",
        "ZEN_THINKING_MODE": "${ZEN_THINKING_MODE:-medium}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/"]
    },
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "desktop-commander"] 
    },
    "web-search": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-web-search"]
    },
    "frontend-testing": {
      "command": "npx", 
      "args": ["-y", "mcp-frontend-testing"]
    },
    "mcp-jest": {
      "command": "npx",
      "args": ["-y", "mcp-jest"]
    },
    "playwright-testing": {
      "command": "npx",
      "args": ["-y", "@playwright/test"]
    }
  }
}
EOF
        
        print_success "Enhanced MCP configuration with Playwright installed"
    
    # Setup environment template
    if [ ! -f "$HOME/.env_claude_template" ]; then
        cat > "$HOME/.env_claude_template" << 'EOF'
# Claude Code Environment Configuration
# Copy this file to .env in your project directory and customize

# OpenRouter API Key (for Zen MCP with DeepSeek)
OPENROUTER_API_KEY=your_openrouter_key_here

# Default AI Model Configuration
DEFAULT_MODEL=deepseek/deepseek-r1-0528
ZEN_DEFAULT_MODEL=deepseek/deepseek-r1-0528
ZEN_THINKING_MODE=medium

# Context7 Configuration
CONTEXT7_API_KEY=

# Git Configuration
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your.email@example.com

# Project Specific Variables
PROJECT_NAME=my-project
PROJECT_DESCRIPTION=My awesome project
AUTHOR_NAME=Your Name
AUTHOR_EMAIL=your.email@example.com
USERNAME=your-github-username

# Playwright Configuration
PLAYWRIGHT_BROWSERS=chromium,firefox,webkit
PLAYWRIGHT_HEADLESS=true
PLAYWRIGHT_TIMEOUT=30000
EOF
        print_success "Environment template created with Playwright configuration"
    fi
}

create_claude_commands() {
    print_status "Creating enhanced Claude commands with Playwright support..."
    
    local commands_dir="$HOME/.claude/commands"
    mkdir -p "$commands_dir"
    
    # Enhanced project analysis command
    cat > "$commands_dir/analyze-project.md" << 'EOF'
# Comprehensive project analysis with testing and cleanup recommendations

Please perform a comprehensive analysis of this project:

1. **Project Structure Analysis**
   - Review directory organization and file structure
   - Assess adherence to best practices and conventions
   - Identify missing or misplaced files

2. **Code Quality Assessment**
   - Review code organization and architecture
   - Check for code smells and anti-patterns
   - Assess maintainability and readability

3. **Testing Strategy Review**
   - Analyze current testing setup (unit, integration, e2e)
   - Evaluate Playwright configuration if present
   - Suggest testing improvements and coverage gaps

4. **File Cleanup Assessment**
   - Check for emoji usage in code/docs that should be removed
   - Identify temporary files and cleanup opportunities
   - Assess file organization and naming conventions

5. **Documentation Review**
   - Evaluate README and documentation completeness
   - Check for missing API documentation
   - Assess code comments and docstrings

6. **Security and Performance**
   - Check for common security vulnerabilities
   - Review dependency security
   - Identify potential performance bottlenecks

Use context7 for current best practices, zen with deepseek for detailed analysis, and playwright-testing for test strategy.

**Focus Area**: $ARGUMENTS

Please provide:
- Executive summary of project status
- Prioritized improvement recommendations
- Testing strategy recommendations
- File cleanup suggestions including emoji removal
- Implementation guidance
EOF

    # Playwright-specific testing command
    cat > "$commands_dir/setup-playwright-testing.md" << 'EOF'
# Comprehensive Playwright testing setup and configuration

Please help set up comprehensive Playwright testing for this project:

1. **Playwright Configuration**
   - Create playwright.config.js with optimal settings
   - Configure multiple browsers (Chromium, Firefox, WebKit)
   - Set up test environments and base URLs
   - Configure reporting and screenshots

2. **Test Structure Setup**
   - Create page object models for maintainable tests
   - Set up test fixtures and utilities
   - Configure test data management
   - Establish testing conventions

3. **Test Implementation**
   - Generate end-to-end test scenarios
   - Create API testing setup
   - Implement visual regression testing
   - Add accessibility testing

4. **CI/CD Integration**
   - Configure GitHub Actions for Playwright
   - Set up test reporting and artifacts
   - Configure parallel testing
   - Set up test result notifications

Use playwright-testing MCP and frontend-testing for comprehensive setup.

**Application Type/Requirements**: $ARGUMENTS

Please provide:
- Complete Playwright configuration
- Page object model examples
- Sample test implementations
- CI/CD pipeline configuration
- Best practices documentation
EOF

    # Project cleanup command
    cat > "$commands_dir/cleanup-project.md" << 'EOF'
# Comprehensive project cleanup including emoji removal

Please help clean up this project comprehensively:

1. **Emoji Removal**
   - Analyze which files contain emojis
   - Safely remove emojis using remove_emojis.py
   - Ensure documentation remains clear and readable
   - Verify no functional code is affected

2. **File Organization**
   - Review current directory structure
   - Identify misplaced or redundant files
   - Suggest organizational improvements
   - Clean up temporary and cache files

3. **Code Cleanup**
   - Remove dead code and unused imports
   - Optimize dependencies and requirements
   - Clean up commented-out code
   - Standardize code formatting

4. **Documentation Cleanup**
   - Ensure all docs are emoji-free but readable
   - Update outdated documentation
   - Standardize documentation format
   - Check for broken links and references

**Target Directory**: $ARGUMENTS (default: current directory)

Please provide:
- Step-by-step cleanup instructions
- Safe emoji removal procedure
- File organization recommendations
- Documentation improvement suggestions

Cleanup procedure:
1. python remove_emojis.py --dry-run (preview changes)
2. python remove_emojis.py (execute removal)
3. Review and organize file structure
4. Update documentation as needed
EOF

    print_success "Enhanced Claude commands created with Playwright and cleanup support"
}

create_project_creator() {
    print_status "Creating enhanced project creator with automatic emoji removal..."
    
    cat > "$GLOBAL_CONFIG_DIR/create-claude-project.sh" << 'EOF'
#!/bin/bash

# Enhanced Claude Code Project Creator with Playwright and Emoji Removal
# Automatically sets up projects with optimal Claude Code configuration

set -e

PROJECT_NAME="$1"
PROJECT_TYPE="${2:-auto}"
PROJECT_DIR="${3:-$(pwd)/$PROJECT_NAME}"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: create-claude-project.sh <project-name> [type] [directory]"
    echo "Types: python, fastapi, react, fullstack, ml, datascience, auto"
    exit 1
fi

# Auto-detect project type if not specified
if [ "$PROJECT_TYPE" = "auto" ]; then
    echo " Auto-detecting project type..."
    
    if [[ "$PROJECT_NAME" == *"api"* ]] || [[ "$PROJECT_NAME" == *"backend"* ]]; then
        PROJECT_TYPE="fastapi"
    elif [[ "$PROJECT_NAME" == *"ui"* ]] || [[ "$PROJECT_NAME" == *"frontend"* ]] || [[ "$PROJECT_NAME" == *"app"* ]]; then
        PROJECT_TYPE="react"
    elif [[ "$PROJECT_NAME" == *"ml"* ]] || [[ "$PROJECT_NAME" == *"model"* ]] || [[ "$PROJECT_NAME" == *"ai"* ]]; then
        PROJECT_TYPE="ml"
    elif [[ "$PROJECT_NAME" == *"data"* ]] || [[ "$PROJECT_NAME" == *"analysis"* ]]; then
        PROJECT_TYPE="datascience"
    else
        PROJECT_TYPE="python"
    fi
    
    echo " Detected project type: $PROJECT_TYPE"
fi

echo " Creating Claude Code project: $PROJECT_NAME ($PROJECT_TYPE)"

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Copy appropriate template
TEMPLATES_DIR="$HOME/.claude-setup/templates"
if [ -d "$TEMPLATES_DIR/${PROJECT_TYPE}-project" ]; then
    echo " Copying template files..."
    cp -r "$TEMPLATES_DIR/${PROJECT_TYPE}-project/"* .
    cp -r "$TEMPLATES_DIR/${PROJECT_TYPE}-project/".* . 2>/dev/null || true
else
    echo " Using Python template as fallback..."
    cp -r "$TEMPLATES_DIR/python-project/"* .
    cp -r "$TEMPLATES_DIR/python-project/".* . 2>/dev/null || true
fi

# Customize template files
echo " Customizing project files..."
find . -type f -name "*.md" -o -name "*.toml" -o -name "*.json" -o -name "*.py" | while read file; do
    if [ -f "$file" ]; then
        sed -i.bak "s/PROJECT_NAME/$PROJECT_NAME/g" "$file" 2>/dev/null || true
        sed -i.bak "s/PROJECT_DESCRIPTION/A $PROJECT_TYPE project created with Claude Code/g" "$file" 2>/dev/null || true
        sed -i.bak "s/AUTHOR_NAME/${GIT_USER_NAME:-Your Name}/g" "$file" 2>/dev/null || true
        sed -i.bak "s/AUTHOR_EMAIL/${GIT_USER_EMAIL:-your.email@example.com}/g" "$file" 2>/dev/null || true
        sed -i.bak "s/USERNAME/${USERNAME:-your-username}/g" "$file" 2>/dev/null || true
        rm -f "$file.bak" 2>/dev/null || true
    fi
done

# Ensure remove_emojis.py is executable and has required dependencies
if [ -f "remove_emojis.py" ]; then
    chmod +x remove_emojis.py
    echo " Emoji removal script ready"
fi

# Initialize git repository
if [ ! -d ".git" ]; then
    echo " Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: $PROJECT_TYPE project setup with Claude Code integration"
fi

# Set up development environment
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    echo " Setting up Python environment..."
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    
    # Install emoji package for remove_emojis.py
    pip install emoji
    
    # Install project dependencies
    if [ -f "pyproject.toml" ]; then
        pip install -e ".[dev]" 2>/dev/null || pip install -e . 2>/dev/null || true
    elif [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    fi
    
    if [ -f ".pre-commit-config.yaml" ]; then
        echo " Installing pre-commit hooks..."
        pre-commit install
    fi
fi

if [ -f "package.json" ]; then
    echo " Installing Node.js dependencies..."
    npm install
    
    # Install Playwright if this is a frontend/testing project
    if [[ "$PROJECT_TYPE" == "react"* ]] || [[ "$PROJECT_TYPE" == "frontend"* ]]; then
        echo " Installing Playwright for testing..."
        npm install -D @playwright/test
        npx playwright install
    fi
fi

echo " Project $PROJECT_NAME created successfully!"
echo " Location: $PROJECT_DIR"
echo ""
echo " Next steps:"
echo "   cd $PROJECT_DIR"
echo "   claude -p 'Analyze this new project and suggest next development steps'"
echo ""
echo " Available Claude commands:"
echo "   /analyze-project - Comprehensive project analysis"
echo "   /setup-playwright-testing - Set up Playwright testing"
echo "   /cleanup-project - Clean up files and remove emojis"
echo ""
echo " Cleanup tools:"
echo "   python remove_emojis.py --dry-run   # Preview emoji removal"
echo "   python remove_emojis.py            # Remove emojis from all files"
EOF

    chmod +x "$GLOBAL_CONFIG_DIR/create-claude-project.sh"
    
    # Create symlink for easy access
    if [ ! -L "/usr/local/bin/create-claude-project" ]; then
        sudo ln -sf "$GLOBAL_CONFIG_DIR/create-claude-project.sh" /usr/local/bin/create-claude-project 2>/dev/null || {
            print_warning "Could not create global symlink. You can run the script directly from:"
            echo "$GLOBAL_CONFIG_DIR/create-claude-project.sh"
        }
    fi
    
    print_success "Enhanced project creator with Playwright and emoji removal installed"
}

setup_automatic_integration() {
    print_status "Setting up automatic Claude Code integration with enhanced features..."
    
    local shell_config=""
    if [ -n "$ZSH_VERSION" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_config" ]; then
        if ! grep -q "Claude Code Auto Setup - Enhanced" "$shell_config" 2>/dev/null; then
            cat >> "$shell_config" << 'EOF'

# Claude Code Auto Setup - Enhanced with Playwright & Emoji Removal
# ==================================================================

# Enhanced project setup function
claude-new() {
    local project_name="$1"
    local project_type="${2:-auto}"
    
    if [ -z "$project_name" ]; then
        echo "Usage: claude-new <project-name> [type]"
        echo "Types: python, fastapi, react, fullstack, ml, datascience, auto"
        return 1
    fi
    
    create-claude-project "$project_name" "$project_type"
    cd "$project_name"
    
    echo " Starting Claude Code for new project with enhanced features..."
    claude -p "Welcome to the new $project_type project '$project_name'. This project includes Playwright testing support and emoji removal tools. Please analyze the project structure and suggest the best next steps for development."
}

# Enhanced Claude commands
alias claude-analyze='claude -p "/analyze-project"'
alias claude-playwright='claude -p "/setup-playwright-testing"'
alias claude-cleanup='claude -p "/cleanup-project"'
alias claude-review='claude -p "/multi-ai-review"'

# Emoji removal helpers
claude-clean-emojis() {
    if [ -f "remove_emojis.py" ]; then
        echo " Removing emojis from project files..."
        python remove_emojis.py --dry-run
        read -p "Proceed with emoji removal? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            python remove_emojis.py
            echo " Emoji removal complete!"
        fi
    else
        echo " remove_emojis.py not found. Create a new project with claude-new to get this tool."
    fi
}

# Playwright testing helpers
claude-test-setup() {
    if [ -f "package.json" ]; then
        echo " Setting up Playwright testing..."
        npm install -D @playwright/test
        npx playwright install
        claude -p "/setup-playwright-testing web application"
    else
        echo " No package.json found. This command works best with JavaScript/React projects."
    fi
}

# Project initialization in existing directory - enhanced
claude-init() {
    local project_type="${1:-auto}"
    local project_name="${PWD##*/}"
    
    echo " Initializing enhanced Claude Code setup in current directory..."
    
    # Detect project type if auto
    if [ "$project_type" = "auto" ]; then
        if [ -f "package.json" ]; then
            project_type="react"
        elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
            project_type="python"
        elif [ -f "requirements.txt" ]; then
            project_type="python"
        else
            project_type="python"
        fi
    fi
    
    # Copy configuration files
    TEMPLATES_DIR="$HOME/.claude-setup/templates"
    if [ -d "$TEMPLATES_DIR/${project_type}-project" ]; then
        # Copy Claude-specific files
        cp "$TEMPLATES_DIR/${project_type}-project/.mcp.json" . 2>/dev/null || true
        cp -r "$TEMPLATES_DIR/${project_type}-project/.claude" . 2>/dev/null || true
        cp "$TEMPLATES_DIR/${project_type}-project/remove_emojis.py" . 2>/dev/null || true
        
        # Make remove_emojis.py executable
        chmod +x remove_emojis.py 2>/dev/null || true
        
        echo " Enhanced Claude Code configuration added to existing project"
        echo " Available: Claude Code with MCP servers, Playwright support, emoji removal"
        echo " Run: claude-clean-emojis to remove emojis from files"
        echo " Run: claude-test-setup to add Playwright testing"
    else
        echo " Unknown project type: $project_type"
        return 1
    fi
}

EOF
            print_success "Enhanced shell integration added to $shell_config"
            print_warning "Please restart your shell or run: source $shell_config"
        fi
    fi
}

verify_installation() {
    print_status "Verifying enhanced installation..."
    
    local issues=()
    
    # Check Claude Code
    if ! command -v claude &> /dev/null; then
        issues+=("Claude Code not found")
    fi
    
    # Check Playwright
    if ! npm list -g @playwright/test &> /dev/null; then
        issues+=("Playwright not installed globally")
    fi
    
    # Check Python emoji package
    if ! python3 -c "import emoji" 2>/dev/null; then
        issues+=("Python emoji package not installed")
    fi
    
    # Check MCP configuration
    if [ ! -f "$CLAUDE_CONFIG_DIR/global_mcp_config.json" ]; then
        issues+=("MCP configuration not found")
    fi
    
    # Check project creator
    if [ ! -f "$GLOBAL_CONFIG_DIR/create-claude-project.sh" ]; then
        issues+=("Project creator not found")
    fi
    
    # Check templates with remove_emojis.py
    if [ ! -f "$TEMPLATES_DIR/python-project/remove_emojis.py" ]; then
        issues+=("Emoji removal script not found in templates")
    fi
    
    if [ ${#issues[@]} -eq 0 ]; then
        print_success "All enhanced components installed successfully!"
        return 0
    else
        print_error "Installation issues found:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        return 1
    fi
}

show_completion_message() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                 ENHANCED CLAUDE CODE SETUP COMPLETE!                     ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${CYAN} Enhanced Features:${NC}"
    echo "   • Playwright testing integration"
    echo "   • Automatic emoji removal in all projects"
    echo "   • Enhanced MCP server configuration"
    echo "   • Advanced project templates"
    echo ""
    echo -e "${CYAN} Quick Start:${NC}"
    echo "   claude-new my-project          # Create new project with all features"
    echo "   claude-init                    # Add features to existing directory"
    echo "   claude-analyze                 # Enhanced project analysis"
    echo "   claude-playwright              # Setup Playwright testing"
    echo "   claude-cleanup                 # Clean project and remove emojis"
    echo ""
    echo -e "${CYAN} Emoji Removal:${NC}"
    echo "   claude-clean-emojis            # Interactive emoji removal"
    echo "   python remove_emojis.py --dry-run    # Preview changes"
    echo "   python remove_emojis.py              # Remove emojis"
    echo ""
    echo -e "${CYAN} Playwright Testing:${NC}"
    echo "   claude-test-setup              # Setup Playwright in JS projects"
    echo "   /setup-playwright-testing      # Claude command for test setup"
    echo ""
    echo -e "${YELLOW}  Remember to:${NC}"
    echo "   1. Restart your shell: source ~/.zshrc (or ~/.bashrc)"
    echo "   2. Edit ~/.env_claude_template with your API keys"
    echo "   3. Test: claude-new test-project && cd test-project"
    echo "   4. Test emoji removal: python remove_emojis.py --dry-run"
    echo ""
    echo -e "${GREEN}Happy coding with enhanced Claude Code features! ${NC}"
}

# Main installation flow
main() {
    print_header
    
    echo -e "${BLUE}Enhanced setup includes:${NC}"
    echo "• All original MCP servers and features"
    echo "• Playwright testing integration"
    echo "• Automatic emoji removal tool in every project"
    echo "• Enhanced project templates"
    echo "• Advanced testing and cleanup commands"
    echo ""
    
    read -p "Continue with enhanced installation? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    check_prerequisites
    install_mcp_servers
    install_playwright
    install_python_dependencies
    setup_global_config
    create_claude_commands
    create_project_creator
    setup_automatic_integration
    
    if verify_installation; then
        show_completion_message
    else
        print_error "Installation completed with issues. Please check the output above."
        exit 1
    fi
}

# Run main function
main "$@"
