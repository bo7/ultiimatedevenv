#  Docker Development Environment - Quick Reference

##  Container Includes
- **Node.js 20** + latest npm
- **Python 3** + development tools (black, flake8, pylint, mypy)
- **Vim** as Python IDE with custom config
- **VS Code** with Azure, Git, Python extensions
- **Claude Code** with all MCP servers (Context7, Zen, etc.)
- **Azure CLI** + **Git** + **Docker CLI**

##  Quick Commands

### Container Management
```bash
./setup.sh          # Complete setup (run once)
./manage.sh start    # Start environment
./manage.sh enter    # Enter container
./manage.sh stop     # Stop environment
./manage.sh status   # Check status
```

### Inside Container - Development
```bash
# Python Development
new-python-project my-api    # Create new project
dev-setup                   # Setup dev tools
format-python              # Format all Python files
test-python                # Run pytest

# Claude Code + MCP
claude -p "Use context7 for FastAPI docs"
claude -p "Use zen with deepseek to analyze this code"
claude-with-context "Debug this function"

# Vim Python IDE
vim script.py
# <leader>py = run python, <leader>pf = format, <leader>cc = claude

# VS Code
code .                     # Open VS Code in current dir
```

### Aliases Available in Container
```bash
# Python
py, pip, venv, activate, requirements

# Git  
gs, ga, gc, gp, gl, gd, gb, gco

# Claude
claude-dev, cc, claude-zen, claude-docs

# Docker
d, dc, dps, di

# Azure
az-login, az-account, az-list
```

##  Important Paths
- **Workspace**: `./workspace/` (persistent projects)
- **Config**: `./configs/` (all configuration files)
- **Data**: `./data/` (persistent container data)
- **Inside Container**: `/workspace` (your projects)

##  Configuration Files
- **`.env`** - API keys and environment variables
- **`configs/.claude-code/global_mcp_config.json`** - MCP servers
- **`configs/.vimrc`** - Vim Python IDE configuration
- **`configs/.zshrc`** - Shell with development aliases
- **`configs/.vscode/settings.json`** - VS Code Python setup

##  First Time Setup
1. `cd ~/docker-dev-environment`
2. `./setup.sh` (builds everything)
3. Edit `.env` with your OpenRouter API key
4. `./manage.sh enter` (enter container)
5. `new-python-project test-project` (create test project)

##  Common Workflows

### Python API Development
```bash
new-python-project my-api
cd my-api
pip install fastapi uvicorn
code .  # VS Code IDE
# OR
vim src/main.py  # Vim IDE
```

### Claude-Assisted Development
```bash
claude-with-context "Use context7 for docs, then zen with deepseek to design this API"
claude -p "Use frontend-testing to create tests for this component"
```

### Full-Stack Development
```bash
# Backend (Python)
cd backend && uvicorn main:app --reload --host 0.0.0.0

# Frontend (Node.js) - in another terminal
cd frontend && npm run dev
```

##  Port Mappings
- `3000` - Development server
- `8000` - FastAPI/Django  
- `8080` - Alternative web server
- `5000` - Flask
- `5432` - PostgreSQL (optional)
- `6379` - Redis (optional)

##  Troubleshooting
```bash
# View logs
./manage.sh logs

# Rebuild container
./manage.sh build

# Reset everything (DESTRUCTIVE)
./manage.sh reset

# Check MCP servers
docker exec -it claude-dev-env claude --debug -p "test"
```

##  Pro Tips
- All data in `./workspace/` and `./data/` persists between container restarts
- Use `./manage.sh backup` before major changes
- Install additional VS Code extensions with `./manage.sh vscode`
- The container includes PostgreSQL and Redis for database development
- Docker-in-Docker is supported for containerized workflows

##  Updates
```bash
# Update container with latest packages
./manage.sh backup  # Safety first
./manage.sh build   # Rebuild with updates
```

---
**Ready to code!**  Your development environment includes everything you need for modern Python, Node.js, and AI-assisted development.
