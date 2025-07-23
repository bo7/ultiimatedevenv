# Development Workspace

This directory contains all development projects. Each subdirectory is an independent Git repository that can be developed, versioned, and deployed separately.

## Current Projects

*Add your projects here as you create them:*

- `agentsautogen/` - Agent automation with MCP integration
- `another-project/` - Node.js project example
- `demo-project/` - Python demo project with tests
- `myproject/` - Node.js project with package management
- `pushup3/` - Flask web application with dashboard
- `shared-tools/` - Common utilities and libraries (if needed)

## Quick Start

### Creating a New Project

```bash
# From host system
cd docker-dev-environment/workspace/
mkdir my-new-project
cd my-new-project/

# Initialize git repository
git init
git remote add origin https://github.com/username/my-new-project.git

# Create basic structure
echo "# My New Project" > README.md
mkdir -p src tests docs config
echo "node_modules/" > .gitignore
echo "*.log" >> .gitignore
echo ".env" >> .gitignore

# Initial commit
git add .
git commit -m "Initial project structure"
git push -u origin main
```

### Cloning Existing Project

```bash
# Clone directly to workspace
cd docker-dev-environment/workspace/
git clone https://github.com/username/existing-project.git
cd existing-project/
```

### Working from Container

```bash
# Enter the development container
docker-compose exec dev-container bash

# Navigate to workspace (mounted at /workspace/)
cd /workspace/

# Create or work on projects
mkdir new-project && cd new-project
git init
```

## Project Structure Guidelines

Each project should follow this recommended structure:

```
project-name/
├── README.md                  # Project documentation
├── .gitignore                # Git ignore patterns
├── .env.example              # Environment variables template
├── src/                      # Source code
│   ├── main.py              # Entry point
│   └── modules/             # Application modules
├── tests/                    # Test files
├── docs/                     # Documentation
├── config/                   # Configuration files
└── scripts/                  # Build/deployment scripts
```

## Development Workflow

### Daily Development

1. **Start the container environment:**
```bash
cd docker-dev-environment/
docker-compose up -d
```

2. **Enter container for development:**
```bash
docker-compose exec dev-container bash
cd /workspace/my-project/
```

3. **Develop with persistent storage:**
- All changes in `/workspace/` persist between container restarts
- Git repositories maintain their state
- Dependencies and configurations are preserved

4. **Git workflow:**
```bash
git pull origin main
# ... make changes ...
git add .
git commit -m "feat: add new feature"
git push origin main
```

### Multi-Project Development

Work on multiple projects simultaneously:

```bash
# Terminal 1: Frontend
cd workspace/frontend-app/
npm run dev                   # Runs on port 3000

# Terminal 2: Backend
cd workspace/backend-api/
python main.py               # Runs on port 8000

# Terminal 3: Container shell
docker-compose exec dev-container bash
cd /workspace/
```

## Claude Code Integration

### Installing Claude Code for a Project

The workspace includes `install-claude-code-with-mcp-v2.sh` script that installs Claude Code locally for each project:

```bash
# Install Claude Code for a specific project
cd /workspace/
./install-claude-code-with-mcp-v2.sh ./my-project

# This creates:
# my-project/bin/claude        # Claude executable
# my-project/lib/              # Library files
# my-project/config/           # MCP server configurations
# my-project/node_modules/     # Dependencies
```

### Using Claude Code

After installation, use Claude Code from within the project:

```bash
# Navigate to your project
cd /workspace/my-project/

# Run Claude Code (no npm servers needed)
./bin/claude

# Or run Claude with specific prompts
./bin/claude "Help me debug this Python function"

# Claude Code comes pre-configured with MCP servers:
# - filesystem-server (file access)
# - context7-server (documentation)
# - desktop-commander (system integration)
# - zen (AI tools, if available)
# - jest-server (testing integration)
```

### Project-Specific Claude Installation

Each project gets its own Claude Code installation:

```
my-project/
├── bin/
│   └── claude              # Project-specific Claude executable
├── lib/                    # Claude Code libraries
├── config/                 # MCP server configurations
├── node_modules/           # Node.js dependencies
├── src/                    # Your project source code
├── tests/                  # Your project tests
└── README.md               # Your project documentation
```

**Benefits:**
- No global npm server management required
- Each project has isolated Claude Code configuration
- MCP servers are pre-configured and ready to use
- No conflicts between different project setups

## Git Management

### Independent Repositories

Each project in workspace/ is completely independent:

- **Separate git history**: Each project has its own `.git/` directory
- **Individual remotes**: Projects can push to different GitHub repositories
- **Independent branching**: Feature branches are per-project
- **Separate releases**: Each project can have its own versioning

### Example Multi-Repo Setup

```
workspace/
├── frontend-react/           # React application
│   ├── .git/                # -> github.com/username/frontend-react
│   ├── bin/claude           # Project-specific Claude Code
│   └── src/
├── backend-python/           # Python API
│   ├── .git/                # -> github.com/username/backend-python
│   ├── bin/claude           # Project-specific Claude Code
│   └── src/
├── mobile-app/               # React Native
│   ├── .git/                # -> github.com/username/mobile-app
│   ├── bin/claude           # Project-specific Claude Code
│   └── src/
└── shared-components/        # Shared UI library
    ├── .git/                # -> github.com/username/shared-components
    ├── bin/claude           # Project-specific Claude Code
    └── lib/
```

### Git Configuration Persistence

Git configuration persists in the container's data volume:

```bash
# Inside container - configuration persists across restarts
docker-compose exec dev-container bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main

# SSH keys also persist
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub
```

### Working from Host vs Container

**From Host System:**
- Edit files with your preferred IDE (VS Code, IntelliJ, etc.)
- Use host git client for commits and pushes
- Better performance for file operations
- Direct integration with host tools

**From Container:**
- Use pre-configured development tools (nvim, etc.)
- Run Claude Code: `./bin/claude`
- Consistent environment across machines
- Access to container-specific tools and services

**Best Practice**: Hybrid approach
- Edit files from host with familiar tools
- Run development commands inside container
- Use Claude Code from within project directories

## Container Integration

### Volume Mounting

The workspace is mounted into the container:

```yaml
# docker-compose.yml
volumes:
  - ./workspace:/workspace     # Bidirectional sync
  - ./data:/data              # Container data persistence
```

### Port Forwarding

Development servers in projects can be accessed from host:

```yaml
# docker-compose.yml ports section
ports:
  - "3000:3000"    # React dev server
  - "3001:3001"    # Additional frontend
  - "8000:8000"    # Python/FastAPI backend
  - "8080:8080"    # Alternative backend
  - "5432:5432"    # PostgreSQL database
  - "6379:6379"    # Redis cache
```

Access from host browser:
- http://localhost:3000 (Frontend)
- http://localhost:8000 (API)

### Environment Variables

Each project should have its own environment management:

```bash
# In each project directory
├── .env.example              # Template (committed to git)
├── .env                      # Actual values (git ignored)
└── .env.local               # Local overrides (git ignored)
```

## Best Practices

### Project Organization

1. **Consistent naming**: Use kebab-case for directories
2. **Clear structure**: Follow the recommended project structure
3. **Documentation**: Each project needs a comprehensive README.md
4. **Environment templates**: Always provide `.env.example`
5. **Claude Code per project**: Install Claude Code locally for each project

### Git Workflow

1. **Conventional commits**: Use prefixes like `feat:`, `fix:`, `docs:`
2. **Clean history**: Rebase feature branches before merging
3. **Meaningful messages**: Describe what and why, not just what
4. **Regular pushes**: Don't lose work due to container issues

### Development Practices

1. **Testing**: Include tests in every project
2. **Dependencies**: Keep package files updated
3. **Security**: Never commit secrets or credentials
4. **Claude Integration**: Use `./bin/claude` for AI-assisted development

## Troubleshooting

### Common Issues

1. **Container Won't Start:**
```bash
# Check logs
docker-compose logs dev-container

# Rebuild container
docker-compose build --no-cache dev-container
docker-compose up -d
```

2. **Permission Issues:**
```bash
# Fix workspace permissions
sudo chown -R $(id -u):$(id -g) workspace/
sudo chown -R $(id -u):$(id -g) data/
```

3. **Claude Code Issues:**
```bash
# Reinstall Claude Code for a project
cd /workspace/my-project/
../install-claude-code-with-mcp-v2.sh .

# Check if Claude Code is working
./bin/claude "Hello"
```

4. **Port Already in Use:**
```bash
# Find process using port
lsof -i :3000

# Kill process or change port in docker-compose.yml
```

### Data Recovery

If you need to recover data:

```bash
# Backup workspace and data
tar -czf backup-$(date +%Y%m%d).tar.gz workspace/ data/

# Restore from backup
tar -xzf backup-20240723.tar.gz
```

## Adding New Projects

### Template for New Projects

When creating a new project, use this checklist:

- [ ] Create project directory
- [ ] Initialize git repository
- [ ] Add remote origin
- [ ] Install Claude Code: `../install-claude-code-with-mcp-v2.sh .`
- [ ] Create basic file structure (src/, tests/, docs/)
- [ ] Add .gitignore file
- [ ] Create .env.example template
- [ ] Write initial README.md
- [ ] Make initial commit
- [ ] Push to remote repository
- [ ] Update this workspace README.md

### Project Documentation Template

Each project's README.md should include:

```markdown
# Project Name

Brief description of the project.

## Setup

1. Clone the repository
2. Copy .env.example to .env and configure
3. Install dependencies
4. Install Claude Code: `../install-claude-code-with-mcp-v2.sh .`
5. Run the project

## Development

- Start development server: `npm run dev`
- Run tests: `npm test`
- Build: `npm run build`
- Use Claude Code: `./bin/claude "help me with this code"`

## API Documentation

[Link to API docs or include here]

## Deployment

[Deployment instructions]
```

## Tips and Best Practices

### 1. Project Naming
- Use kebab-case for directory names: `my-awesome-project`
- Keep names descriptive but concise
- Avoid spaces and special characters

### 2. Git Management
- Each project should have its own `.gitignore`
- Use conventional commit messages: `feat:`, `fix:`, `docs:`, etc.
- Keep the main branch clean and stable
- Use branches for feature development

### 3. Environment Management
- Never commit `.env` files with secrets
- Always provide `.env.example` templates
- Use container environment variables when possible

### 4. Claude Code Integration
- Install Claude Code per project: `../install-claude-code-with-mcp-v2.sh .`
- Use `./bin/claude` from within each project
- MCP servers are pre-configured and ready to use
- No need to manage npm servers manually

### 5. Performance
- Use `.dockerignore` to exclude unnecessary files from context
- Regularly clean up unused Docker resources: `docker system prune`
- Monitor disk usage: `du -sh workspace/*/`

This comprehensive setup provides a robust, scalable development environment where each project maintains its independence while benefiting from shared infrastructure and Claude Code integration.

