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

##   Working Inside the Container

**For the best development experience, work directly inside the containerized environment:**

### Why Container-First Development?
-  **Consistent Environment** - Same setup across all machines
-  **Isolated Dependencies** - No conflicts with host system
-  **Pre-configured Tools** - Everything ready out of the box
-  **Claude Code Integration** - Optimized AI development workflow

### Container Development Workflow

#### 1. Start Your Development Environment
```bash
# Start the development container
./manage.sh start

# Enter the container with full development setup
./manage.sh enter-dev

# Or use the optimized dev session (Ghostty + tmux layout)
./start-dev-session.sh
```

#### 2. Initialize Your Workspace Inside Container
```bash
# Inside the container - set up your git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Initialize your workspace directory
cd /workspace
git init
```

#### 3. Create Claude Code Projects Inside Container
```bash
# Method 1: Use the built-in project creator
claude-new my-project
cd my-project

# Method 2: Manual setup for existing projects
mkdir my-existing-project
cd my-existing-project
git init

# Create Claude Code configuration
cat > .claude_project <<EOF
{
  "name": "My Project",
  "description": "Description of your project",
  "version": "1.0.0",
  "mcp_servers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@claudeai/mcp-server-filesystem", "/workspace/my-existing-project"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    },
    "zen": {
      "command": "npx", 
      "args": ["-y", "@zen-js/mcp-server"]
    }
  }
}
EOF

# Initialize with basic project structure
mkdir -p {src,tests,docs,config}
touch {README.md,requirements.txt,.gitignore}
```

#### 4. Claude Code Development Workflow
```bash
# Start Claude Code from inside container
claude-code

# Or use with specific project configuration  
claude-code --project-config .claude_project

# Connect additional MCP servers for your project
claude-code --add-server desktop-commander
claude-code --add-server puppeteer
```

###  Recommended Project Structure Inside Container
```
/workspace/
├── my-project/                 # Your main project
│   ├── .claude_project        # Claude Code configuration
│   ├── .git/                  # Git repository
│   ├── src/                   # Source code
│   ├── tests/                 # Test files
│   ├── docs/                  # Documentation
│   └── config/                # Configuration files
├── experiments/               # Quick experiments and prototypes
├── shared-tools/              # Shared utilities across projects
└── templates/                 # Project templates
```

###  Container Development Tips

#### Git Configuration Inside Container
```bash
# Set up SSH keys for GitHub (if needed)
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub

# Or use GitHub CLI
gh auth login

# Configure git for better container workflow
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor nvim
```

#### Persistent Data
```bash
# Your workspace is mounted and persistent
ls /workspace  # This directory survives container restarts

# Container data locations:
# /workspace     -> Persistent project files
# /home/dev      -> User home (temporary)
# /opt/tools     -> Pre-installed development tools
```

#### Environment Variables for Claude Code
```bash
# Inside container - check your environment
echo $ANTHROPIC_API_KEY
echo $GITHUB_TOKEN

# Add project-specific environment variables
cat >> ~/.bashrc <<EOF
export PROJECT_NAME="my-project"
export DEVELOPMENT_MODE="container"
EOF
```

#### Advanced Claude Code Project Setup
```bash
# Create a comprehensive Claude Code project
mkdir my-advanced-project && cd my-advanced-project

# Initialize with full MCP server suite
cat > .claude_project <<EOF
{
  "name": "Advanced Development Project",
  "description": "Full-featured development project with all MCP servers",
  "version": "1.0.0",
  "mcp_servers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@claudeai/mcp-server-filesystem", "/workspace/my-advanced-project"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    },
    "zen": {
      "command": "npx",
      "args": ["-y", "@zen-js/mcp-server"]
    },
    "desktop-commander": {
      "command": "desktop-commander"
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@puppeteer/mcp-server"]
    },
    "crypto": {
      "command": "npx",
      "args": ["-y", "mcp-crypto-ccxt"]
    }
  },
  "workspace": {
    "root": "/workspace/my-advanced-project",
    "include": ["src/**", "tests/**", "docs/**"],
    "exclude": ["node_modules/**", ".git/**", "*.log"]
  }
}
EOF

# Create comprehensive project structure
mkdir -p {src/{components,utils,services},tests/{unit,integration},docs,config,scripts}

# Add development scripts
cat > scripts/dev-setup.sh <<EOF
#!/bin/bash
# Development setup script
echo "Setting up development environment..."
pip install -r requirements.txt
npm install
echo " Development environment ready!"
EOF
chmod +x scripts/dev-setup.sh

# Initialize git with proper ignores
cat > .gitignore <<EOF
# Dependencies
node_modules/
__pycache__/
*.pyc
.venv/

# Environment
.env
.env.local

# IDE
.vscode/
.idea/

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db
EOF

git init
git add .
git commit -m "Initial project setup with Claude Code configuration"
```

### 🧹 Automatic Emoji Removal

**This repository automatically maintains clean, professional code by removing emojis before every push.**

#### How It Works
- **Pre-push Hook**: Automatically runs `remove_emojis.py` before every `git push`
- **Comprehensive Scanning**: Processes all text files (`.py`, `.md`, `.js`, `.ts`, etc.)
- **Auto-commit**: Automatically commits emoji removal changes
- **Zero Configuration**: Works out of the box with no setup required

#### Manual Emoji Removal
```bash
# Preview what emojis would be removed (dry-run)
./clean-emojis.sh --dry-run

# Remove emojis from all files
./clean-emojis.sh

# Remove emojis and automatically commit changes
./clean-emojis.sh --commit

# Get help with all options
./clean-emojis.sh --help
```

#### When Emoji Removal Happens
1. **Before every push** - Pre-push hook automatically runs
2. **Manual cleanup** - Use `./clean-emojis.sh` anytime
3. **Project setup** - New projects are cleaned automatically

#### What Gets Cleaned
- **All text files**: `.py`, `.md`, `.js`, `.ts`, `.html`, `.css`, `.json`, `.yaml`
- **Documentation**: README files, comments, docstrings
- **Configuration**: Environment files, config files, scripts
- **Skips**: Binary files, git directories, node_modules, cache directories

```bash
# Example: The pre-push hook will transform this:
echo "🚀 Starting deployment process 📝"

# Into this:
echo "Starting deployment process"
```

**Why Remove Emojis?**
- ✅ **Professional appearance** in production code
- ✅ **Consistent rendering** across different systems
- ✅ **Better compatibility** with CI/CD and deployment tools
- ✅ **Cleaner git diffs** and code reviews

### 🔒 Fork-Based Contribution Model

**This repository uses a secure fork-based workflow to ensure code quality and security.**

#### 🛡️ Branch Protection
- **No direct pushes to main** - All changes must go through Pull Requests
- **Required reviews** - At least 1 approval needed before merge
- **Automated checks** - PR validation, security scans, and build tests
- **Admin enforcement** - Rules apply to all contributors, including maintainers

#### 🚀 Quick Contribution Steps
```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/docker-dev-environment.git
cd docker-dev-environment

# 3. Add upstream remote
git remote add upstream https://github.com/bo7/ultiimatedevenv.git

# 4. Create feature branch
git checkout -b feature/your-feature-name

# 5. Make changes and commit
git add .
git commit -m "feat: your feature description"

# 6. Push to your fork and create PR
git push origin feature/your-feature-name
# Then create PR on GitHub: your-fork → original-repo
```

#### 🧪 Automated PR Validation
Every Pull Request automatically runs:
- **Security scan** - Checks for vulnerabilities and secrets
- **Docker build test** - Ensures containers build successfully  
- **Setup script validation** - Verifies all scripts work correctly
- **Documentation check** - Ensures docs are updated
- **Emoji removal** - Maintains professional code standards

#### 📋 Contribution Requirements
- **Fork-based workflow** - No direct repository access
- **Descriptive commits** - Follow conventional commit format
- **Updated documentation** - Document new features
- **Pass all checks** - Automated validation must succeed
- **Code review approval** - Maintainer review required

```bash
# Setup branch protection (for maintainers)
./setup-branch-protection.sh
```

**See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for detailed contribution guidelines.**

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

##   Code Quality & Pre-Push Process

### Automatic Emoji Removal
This project automatically removes emojis from all files before pushing to maintain a clean, professional codebase.

#### How It Works
- **Pre-push Hook**: Automatically runs `remove_emojis.py` before every `git push`
- **Clean Codebase**: Ensures no emoji characters in source code, documentation, or configuration files
- **Automatic Commit**: Creates a commit with emoji removal changes if needed

#### Manual Emoji Removal
```bash
# Check for emojis without removing them
./remove-emojis.sh --dry-run

# Remove emojis interactively (with confirmation)
./remove-emojis.sh

# Remove emojis automatically (no confirmation)
./remove-emojis.sh --force

# Get help and see all options
./remove-emojis.sh --help
```

#### What Gets Processed
- **File Types**: `.py`, `.md`, `.txt`, `.json`, `.yaml`, `.js`, `.ts`, `.html`, `.css`, `.sh`, etc.
- **Exclusions**: Binary files, `node_modules`, `.git`, `.venv`, cache directories
- **Scope**: All text files in the project recursively

#### Pre-Push Hook Details
The git pre-push hook:
1.  Scans all project files for emojis
2.  Removes any found emojis automatically  
3.  Stages and commits the changes
4.  Continues with the push

**Note**: The pre-push hook is automatically installed when you clone the repository.

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
