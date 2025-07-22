#!/bin/bash

# GitHub Release Preparation Script
# Cleans sensitive data from templates while preserving your working .env

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE} Preparing for GitHub release (Apache 2.0)${NC}"
echo -e "${YELLOW} Preserving your working .env file${NC}"

CURRENT_DIR="$HOME/docker-dev-environment"
cd "$CURRENT_DIR"

echo -e "${BLUE} Ensuring .env is properly git ignored...${NC}"

# Make sure .env is in .gitignore
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Preserve actual environment file with secrets" >> .gitignore
    echo ".env" >> .gitignore
    echo -e "${GREEN} Added .env to .gitignore${NC}"
else
    echo -e "${GREEN} .env already in .gitignore${NC}"
fi

echo -e "${BLUE} Sanitizing template files (keeping your .env intact)...${NC}"

# Clean up template files only (not your actual .env)
sanitize_file() {
    local file="$1"
    echo "  Cleaning: $file"
    
    # Replace actual API keys with placeholders
    sed -i.bak 's/sk-or-v1-[^"]*/"your_openrouter_api_key_here"/g' "$file"
    sed -i.bak 's/ghp_[^"]*/"your_github_token_here"/g' "$file"
    
    # Replace personal email addresses
    sed -i.bak 's/sven@daita-crafter\.com/your.email@example.com/g' "$file"
    
    # Replace SQL server details
    sed -i.bak 's/207\.180\.243\.86/your_sql_server_host/g' "$file"
    sed -i.bak 's/sql-crafter/your_sql_username/g' "$file"
    sed -i.bak 's/start123/your_sql_password/g' "$file"
    sed -i.bak 's/WideWorldImportersDW/your_database_name/g' "$file"
    
    # Replace OAuth credentials
    sed -i.bak 's/216626315808-[^"]*/"your_gmail_client_id"/g' "$file"
    sed -i.bak 's/GOCSPX-[^"]*/"your_gmail_client_secret"/g' "$file"
    sed -i.bak 's/1\/\/[^"]*/"your_refresh_token"/g' "$file"
    sed -i.bak 's/ya29\.[^"]*/"your_access_token"/g' "$file"
    
    # Replace personal name references
    sed -i.bak 's/Sven/Your Name/g' "$file"
    sed -i.bak 's/sbo/your-github-username/g' "$file"
    
    # Remove backup file
    rm -f "$file.bak"
}

# Sanitize all template files (but NOT the actual .env)
find . -name ".env_template*" | while read -r file; do
    sanitize_file "$file"
done

# Sanitize documentation files
find . -name "*.md" | while read -r file; do
    if [[ "$file" != *"PRIVATE"* ]]; then
        echo "  Cleaning documentation: $file"
        sed -i.bak 's/sven@daita-crafter\.com/your.email@example.com/g' "$file"
        sed -i.bak 's/Sven/Your Name/g' "$file"
        sed -i.bak 's/sbo/your-github-username/g' "$file"
        rm -f "$file.bak"
    fi
done

echo -e "${BLUE} Creating Apache 2.0 license...${NC}"

cat > LICENSE << 'EOF'
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   Copyright 2025 Claude Development Environment Contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
EOF

echo -e "${BLUE} Creating README for GitHub...${NC}"

cat > README.md << 'EOF'
#  Ultimate AI-Powered Development Environment

**A complete, containerized development platform with:**
-  **Claude Code** with all MCP servers
-  **Neovim Python IDE** with LSP and modern plugins  
-  **Ghostty terminal layout** for optimal workflow
-  **Multiple Docker environments** (Python, ML, Frontend, etc.)
-  **Automated project creation** with consistent setup
-  **Zero configuration** - everything works out of the box

##  Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/yourusername/claude-dev-environment.git
cd claude-dev-environment
./setup.sh
```

### 2. Configure Your Environment
```bash
# Copy environment template
cp .env_template_master .env

# Add your API keys
nvim .env
```

### 3. Start Developing
```bash
# Create new project with full AI setup
claude-new my-awesome-project

# Start three-pane development layout
dev-layout
```

##  What's Included

###  **AI-Powered Development:**
- **Claude Code** with all recommended MCP servers
- **Context7** - Up-to-date documentation access
- **Zen** - Multi-AI orchestration with DeepSeek reasoning
- **Playwright** - Modern web testing and automation
- **Built-in AI commands** for code review, analysis, testing

###  **Professional Editor:**
- **Neovim Python IDE** with LSP support
- **Code completion** and intelligent suggestions
- **Auto-formatting** with Black, isort
- **Testing integration** with pytest
- **Git integration** and status indicators
- **Claude Code keybindings** for AI assistance

###  **Optimal Workflow:**
- **Ghostty three-pane layout** - Editor | Terminal | Claude Code
- **tmux integration** for precise window management
- **Custom themes** and optimized configurations
- **Automated project setup** with consistent structure

###  **Multiple Environments:**
- **Python Development** - FastAPI, Django, ML libraries
- **Frontend Development** - React, Next.js, TypeScript
- **Machine Learning** - Jupyter, PyTorch, TensorFlow
- **Data Science** - Pandas, NumPy, Matplotlib
- **DevOps** - Docker, Kubernetes, Terraform

##  Features

###  **Zero Configuration**
- Everything works immediately after setup
- Consistent environment across all projects
- Automated dependency management
- Pre-configured development tools

###  **AI Integration**
- Claude Code with custom slash commands
- Multi-AI collaboration with Zen
- Automated code review and analysis
- AI-powered testing and optimization

###  **Developer Experience**
- Modern editor with professional features
- Optimal terminal layout for productivity
- Git integration and workflow automation
- Extensible configuration system

##  Documentation

- **[Complete Setup Guide](README_COMPLETE.md)** - Comprehensive documentation
- **[Neovim IDE Guide](claude-setup/NEOVIM_GHOSTTY_FINAL.md)** - Editor configuration
- **[Environment Configuration](claude-setup/ENV_CONFIGURATION_COMPLETE.md)** - API keys and settings
- **[Adding New Servers](claude-setup/ADD_NEW_SERVER_GUIDE.md)** - Extend with custom MCP servers

##  Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

##  License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

##  Acknowledgments

Built with amazing open source tools:
- [Claude Code](https://www.anthropic.com) - AI-powered development
- [Neovim](https://neovim.io) - Modern text editor
- [Ghostty](https://ghostty.org) - GPU-accelerated terminal
- [Docker](https://docker.com) - Containerization platform

---

**Ready for AI-powered development?** 
EOF

echo -e "${BLUE} Creating contributing guide...${NC}"

cat > CONTRIBUTING.md << 'EOF'
# Contributing to Claude Development Environment

##  Welcome Contributors!

Thank you for your interest in contributing to this AI-powered development environment!

##  Getting Started

1. **Fork the repository**
2. **Clone your fork**
3. **Create a feature branch**
4. **Make your changes**
5. **Test thoroughly**
6. **Submit a pull request**

##  Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/claude-dev-environment.git
cd claude-dev-environment

# Setup development environment
./setup.sh

# Create your environment file
cp .env_template_master .env
# Add your API keys and configuration
```

##  Contribution Guidelines

### **Code Style**
- Follow existing code patterns
- Use clear, descriptive commit messages
- Add documentation for new features
- Test all changes thoroughly

### **Areas for Contribution**
- **New MCP servers** - Add support for additional AI tools
- **Docker environments** - New specialized development containers
- **Editor configurations** - Enhance Neovim setup or add other editors
- **Documentation** - Improve guides and examples
- **Testing** - Add automated tests and validation
- **Templates** - New project templates and configurations

### **Pull Request Process**
1. Update documentation for any new features
2. Add tests where applicable
3. Ensure all existing tests pass
4. Update README if needed
5. Get review from maintainers

##  Bug Reports

Please use GitHub Issues for bug reports. Include:
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Docker version, etc.)
- Relevant log output

##  Feature Requests

We welcome feature requests! Please:
- Check existing issues first
- Describe the use case clearly
- Explain how it benefits users
- Consider implementation complexity

##  License

By contributing, you agree that your contributions will be licensed under the Apache 2.0 License.
EOF

echo -e "${BLUE} Checking git status...${NC}"

# Show what's ready for commit (should not include .env)
echo -e "${YELLOW}Files ready for GitHub:${NC}"
git status --porcelain | grep -v "^?? .env$" || echo "No changes to commit (good!)"

echo ""
echo -e "${GREEN} Repository ready for GitHub release!${NC}"
echo ""
echo -e "${BLUE} Next steps:${NC}"
echo "1. Review changes: git status"
echo "2. Add files: git add ."
echo "3. Commit: git commit -m 'Initial release'"
echo "4. Create GitHub repository"
echo "5. Push: git remote add origin <your-repo-url>"
echo "6. Push: git push -u origin main"
echo ""
echo -e "${YELLOW} Your .env file with actual credentials is safely ignored!${NC}"
echo -e "${GREEN} Templates are cleaned and safe for public release${NC}"
