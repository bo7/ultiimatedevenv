# Advanced Zsh Configuration for Development
# =========================================

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  python
  docker
  azure
  npm
  node
  vscode
  colored-man-pages
  command-not-found
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Load environment variables
if [ -f ~/.env ]; then
    source ~/.env
fi

# Python Development Aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias requirements='pip freeze > requirements.txt'
alias install-dev='pip install black flake8 pylint mypy isort pre-commit'

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Claude Code Aliases
alias claude-dev='claude'
alias cc='claude -p'
alias claude-debug='claude --debug'
alias claude-zen='claude -p "Use zen with deepseek to"'
alias claude-docs='claude -p "Use context7 to get documentation for"'

# VS Code Aliases
alias code-here='code .'
alias code-ext='code --list-extensions'
alias code-install='code --install-extension'

# Docker Aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Azure CLI Aliases
alias az-login='az login'
alias az-account='az account show'
alias az-list='az account list'

# npm/Node Aliases
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'

# System Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias h='history'
alias c='clear'
alias e='exit'

# Development Shortcuts
alias dev-setup='echo "Setting up development environment..." && install-dev && pre-commit install'
alias format-python='find . -name "*.py" -exec black {} \;'
alias lint-python='find . -name "*.py" -exec flake8 {} \;'
alias test-python='python -m pytest -v'

# Function to create new Python project
new-python-project() {
    if [ -z "$1" ]; then
        echo "Usage: new-python-project <project-name>"
        return 1
    fi
    
    mkdir "$1" && cd "$1"
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    
    # Create basic project structure
    mkdir src tests docs
    touch README.md requirements.txt .gitignore
    touch src/__init__.py tests/__init__.py
    
    # Create basic files
    cat > .gitignore << EOF
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.pytest_cache/
EOF
    
    cat > requirements.txt << EOF
# Production dependencies
fastapi
uvicorn
requests
python-dotenv

# Development dependencies
black
flake8
pylint
mypy
isort
pre-commit
pytest
pytest-cov
EOF
    
    echo "Python project '$1' created successfully!"
    echo "Run 'pip install -r requirements.txt' to install dependencies"
}

# Function to run Claude Code with context
claude-with-context() {
    if [ -z "$1" ]; then
        echo "Usage: claude-with-context <prompt>"
        return 1
    fi
    
    echo " Current directory: $(pwd)"
    echo " Files in directory:"
    ls -la
    echo ""
    echo " Running Claude Code..."
    claude -p "$1"
}

# Function to setup VS Code extensions
setup-vscode() {
    echo "Installing VS Code extensions for Python development..."
    
    # Python extensions
    code --install-extension ms-python.python
    code --install-extension ms-python.black-formatter
    code --install-extension ms-python.flake8
    code --install-extension ms-python.pylint
    code --install-extension ms-python.mypy
    code --install-extension ms-python.isort
    
    # Azure extensions
    code --install-extension ms-vscode.azure-cli-tools
    code --install-extension ms-azure-devops.azure-devops
    code --install-extension ms-azuretools.azure-cli-tools
    
    # Git extensions
    code --install-extension eamodio.gitlens
    code --install-extension github.vscode-pull-request-github
    
    # General development
    code --install-extension bradlc.vscode-tailwindcss
    code --install-extension ms-vscode.vscode-typescript-next
    code --install-extension esbenp.prettier-vscode
    code --install-extension ms-vscode.vscode-eslint
    
    echo "VS Code extensions installed!"
}

# Environment setup
export EDITOR=vim
export BROWSER=code
export PYTHONPATH="$PYTHONPATH:/workspace"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS

# Auto-completion
autoload -Uz compinit
compinit

# Welcome message
echo " Development Container Ready!"
echo " Node.js: $(node --version)"
echo " Python: $(python3 --version)"
echo " VS Code: $(code --version | head -n1)"
echo " Claude Code: Available"
echo ""
echo " Quick commands:"
echo "   new-python-project <name> - Create new Python project"
echo "   claude-with-context <prompt> - Run Claude with current directory context"
echo "   setup-vscode - Install VS Code extensions"
echo "   dev-setup - Setup Python development tools"
echo ""
echo " Happy coding!"
