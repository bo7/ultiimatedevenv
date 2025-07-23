# Docker Development Environment

A comprehensive containerized development environment with persistent storage, workspace management, and integrated development tools.

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture Overview](#architecture-overview)
- [Docker Compose Setup](#docker-compose-setup)
- [Container Management](#container-management)
- [Workspace and Persistence](#workspace-and-persistence)
- [Git Workflow for Projects](#git-workflow-for-projects)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git configured on your host system

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd docker-dev-environment
```

### 2. Environment Configuration
```bash
# Copy and configure your environment variables
cp .env.example .env
# Edit .env with your API keys and configuration
nano .env
```

### 3. Start the Environment
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

### 4. Enter the Development Container
```bash
# Enter the main development container
docker-compose exec dev-container bash

# Or start a new shell session
docker-compose run --rm dev-container bash
```

## Architecture Overview

```
docker-dev-environment/
├── docker-compose.yml          # Main orchestration file
├── image/                      # Docker build context
│   ├── Dockerfile             # Container definition
│   ├── nvim/                  # Neovim configuration
│   └── start-*.sh             # Startup scripts
├── workspace/                  # Your projects (persistent)
│   ├── project-1/             # Independent git repository
│   ├── project-2/             # Independent git repository
│   └── README.md              # Workspace documentation
├── data/                       # Container data (persistent)
│   ├── home/                  # User home directory
│   ├── npm-global/            # Global npm packages
│   ├── postgres/              # Database data
│   └── redis/                 # Cache data
└── .env                       # Environment configuration
```

## Docker Compose Setup

### Services Overview

The `docker-compose.yml` defines multiple services:

- **dev-container**: Main development environment
- **postgres**: PostgreSQL database (optional)
- **redis**: Redis cache (optional)

### Starting Services

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d dev-container

# View logs
docker-compose logs -f dev-container

# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: destroys data)
docker-compose down -v
```

### Rebuilding the Container

```bash
# Rebuild after changes to Dockerfile or image/ directory
docker-compose build dev-container

# Rebuild and start
docker-compose up -d --build dev-container
```

## Container Management

### Entering the Container

```bash
# Method 1: Exec into running container
docker-compose exec dev-container bash

# Method 2: Run new container instance
docker-compose run --rm dev-container bash

# Method 3: Run with specific user
docker-compose exec --user root dev-container bash
```

### Container Commands

```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs -f dev-container

# Restart container
docker-compose restart dev-container

# Get container shell with specific working directory
docker-compose exec --workdir /workspace dev-container bash
```

## Workspace and Persistence

### Workspace Mapping

The `./workspace/` directory is mounted into the container at `/workspace/`:

```yaml
# In docker-compose.yml
volumes:
  - ./workspace:/workspace
  - ./data:/data
```

**Key Points:**
- Files in `./workspace/` persist between container restarts
- Changes made inside `/workspace/` are immediately visible on host
- Git repositories in workspace are independent and portable
- Projects can be developed from host or container

### Persistent Data Structure

```
./data/                         # Container persistent data
├── home/                       # User home directory
│   ├── .bashrc                # Shell configuration
│   ├── .gitconfig             # Git configuration
│   └── .ssh/                  # SSH keys
├── npm-global/                # Global npm packages
├── postgres/                  # Database files
├── redis/                     # Redis data
└── claude-config/             # AI tool configurations
```

### Setting Up Persistence

1. **First Time Setup:**
```bash
# Create required directories
mkdir -p data/{home,npm-global,postgres,redis,claude-config}
mkdir -p workspace

# Set permissions (if needed)
chmod -R 755 data/
```

2. **Configure User Inside Container:**
```bash
# Enter container
docker-compose exec dev-container bash

# Set up git identity (persists in data/home/.gitconfig)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Generate SSH keys (persists in data/home/.ssh/)
ssh-keygen -t ed25519 -C "your.email@example.com"
```

## Git Workflow for Projects

### Independent Project Management

Each project in `./workspace/` can be an independent Git repository:

```bash
# Create new project
cd workspace/
mkdir my-new-project
cd my-new-project

# Initialize as independent git repository
git init
git remote add origin https://github.com/username/my-new-project.git

# Create initial structure
echo "# My New Project" > README.md
mkdir -p src tests docs
git add .
git commit -m "Initial commit"
git push -u origin main
```

### Multi-Project Workflow

```bash
workspace/
├── frontend-app/              # React/Vue project
│   ├── .git/                 # Independent git repo
│   ├── package.json
│   └── src/
├── backend-api/               # Python/Node API
│   ├── .git/                 # Independent git repo
│   ├── requirements.txt
│   └── src/
├── mobile-app/                # React Native project
│   ├── .git/                 # Independent git repo
│   └── src/
└── shared-utils/              # Shared libraries
    ├── .git/                 # Independent git repo
    └── lib/
```

### Working from Host vs Container

**From Host:**
```bash
# Clone directly to workspace
cd docker-dev-environment/workspace/
git clone https://github.com/username/project.git
cd project/
# Edit with host IDE (VS Code, etc.)
```

**From Container:**
```bash
# Enter container
docker-compose exec dev-container bash
cd /workspace/

# Clone inside container
git clone https://github.com/username/project.git
cd project/
# Use container tools (nvim, etc.)
```

### Git Configuration Persistence

Git configuration persists in `./data/home/.gitconfig`:

```bash
# Inside container - configuration persists
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false

# SSH keys persist in ./data/home/.ssh/
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub
```

## Development Workflow

### Daily Development Process

1. **Start Environment:**
```bash
cd docker-dev-environment/
docker-compose up -d
```

2. **Enter Development Container:**
```bash
docker-compose exec dev-container bash
cd /workspace/my-project/
```

3. **Development Tasks:**
```bash
# Install dependencies
npm install  # or pip install -r requirements.txt

# Run development server
npm run dev  # or python main.py

# Run tests
npm test     # or pytest

# Git workflow
git add .
git commit -m "Feature: add new functionality"
git push
```

4. **Stop When Done:**
```bash
docker-compose down
```

### Port Forwarding

Access services running in container from host:

```yaml
# In docker-compose.yml
ports:
  - "3000:3000"    # React dev server
  - "8000:8000"    # Python/FastAPI
  - "5432:5432"    # PostgreSQL
  - "6379:6379"    # Redis
```

```bash
# Access from host browser
http://localhost:3000  # Frontend
http://localhost:8000  # API
```

### Environment Variables

Use `.env` file for configuration:

```bash
# .env file
DATABASE_URL=postgresql://user:password@postgres:5432/mydb
REDIS_URL=redis://redis:6379/0
API_KEY=your-api-key-here
NODE_ENV=development
```

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

3. **Port Already in Use:**
```bash
# Find process using port
lsof -i :3000

# Kill process or change port in docker-compose.yml
```

4. **Volume Mount Issues:**
```bash
# Verify mounts
docker-compose exec dev-container df -h
docker-compose exec dev-container ls -la /workspace
```

### Data Recovery

If you need to recover data:

```bash
# Backup workspace and data
tar -czf backup-$(date +%Y%m%d).tar.gz workspace/ data/

# Restore from backup
tar -xzf backup-20240723.tar.gz
```

### Container Debugging

```bash
# Enter as root for system debugging
docker-compose exec --user root dev-container bash

# Check container processes
docker-compose exec dev-container ps aux

# Check disk usage
docker-compose exec dev-container df -h
```

## Best Practices

### Project Organization

1. **One Project Per Directory:**
```bash
workspace/
├── project-a/  # Independent git repo
├── project-b/  # Independent git repo
└── project-c/  # Independent git repo
```

2. **Use Consistent Structure:**
```bash
project-structure/
├── README.md
├── .gitignore
├── src/
├── tests/
├── docs/
└── config/
```

### Performance Optimization

1. **Use .gitignore for Large Files:**
```gitignore
# In each project's .gitignore
node_modules/
.npm/
*.log
dist/
build/
```

2. **Regular Cleanup:**
```bash
# Clean unused Docker resources
docker system prune -a

# Clean npm cache (if needed)
docker-compose exec dev-container npm cache clean --force
```

### Security

1. **Keep Secrets in .env:**
```bash
# Never commit .env file
echo ".env" >> .gitignore
```

2. **Use Environment Variables:**
```bash
# In container
export DATABASE_URL=${DATABASE_URL}
export API_KEY=${API_KEY}
```

### Backup Strategy

1. **Regular Backups:**
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf "backup_${DATE}.tar.gz" workspace/ data/
```

2. **Version Control:**
```bash
# Keep infrastructure versioned
git add docker-compose.yml .env.example
git commit -m "Update container configuration"
```

---

# Workspace Directory (./workspace/)

The `./workspace/` directory is your main development area. It's mounted into the container at `/workspace/` and contains all your projects.

## Workspace Structure

```
workspace/
├── README.md                  # This documentation
├── project-1/                 # Independent git repository
│   ├── .git/                 # Project's own git repo
│   ├── README.md             # Project documentation
│   ├── src/                  # Source code
│   └── package.json          # Dependencies
├── project-2/                 # Another independent git repository
│   ├── .git/                 # Project's own git repo
│   ├── requirements.txt      # Python dependencies
│   └── src/                  # Source code
└── shared-tools/              # Shared utilities across projects
    ├── .git/                 # Independent git repo
    └── lib/                  # Shared libraries
```

## Current Projects

*Add your projects here as you create them:*

- `example-project/` - Example project demonstrating the structure
- `shared-tools/` - Utilities and libraries shared across projects

## Adding New Projects

### Method 1: Create New Project

```bash
# Enter the workspace
cd workspace/

# Create new project directory
mkdir my-awesome-project
cd my-awesome-project

# Initialize as independent git repository
git init
git remote add origin https://github.com/username/my-awesome-project.git

# Create basic structure
echo "# My Awesome Project" > README.md
mkdir -p src tests docs config
echo "node_modules/" > .gitignore
echo "*.log" >> .gitignore

# Initial commit
git add .
git commit -m "Initial project structure"
git push -u origin main
```

### Method 2: Clone Existing Project

```bash
# Clone directly to workspace
cd workspace/
git clone https://github.com/username/existing-project.git
cd existing-project/

# Start developing immediately
```

### Method 3: From Inside Container

```bash
# Enter container
docker-compose exec dev-container bash

# Navigate to workspace
cd /workspace/

# Create or clone project
git clone https://github.com/username/project.git
# OR
mkdir new-project && cd new-project && git init
```

## Development Guidelines

### Project Structure Standards

Each project should follow this structure:

```
project-name/
├── README.md                  # Project documentation
├── .gitignore                # Git ignore patterns
├── .env.example              # Environment template
├── src/                      # Source code
│   ├── main.py              # Entry point
│   └── modules/             # Application modules
├── tests/                    # Test files
│   ├── test_main.py
│   └── fixtures/
├── docs/                     # Documentation
│   ├── api.md
│   └── setup.md
├── config/                   # Configuration files
│   ├── development.json
│   └── production.json
└── scripts/                  # Utility scripts
    ├── build.sh
    └── deploy.sh
```

### Code Quality Standards

- **Documentation**: Every project must have a comprehensive README.md
- **Testing**: Include tests in the `tests/` directory
- **Environment**: Use `.env.example` for environment variable templates
- **Dependencies**: Keep dependency files updated (package.json, requirements.txt, etc.)
- **Git**: Use meaningful commit messages and maintain clean git history

### Git Workflow for Workspace Projects

Each project is an independent git repository:

```bash
# Example workflow for a project
cd workspace/my-project/

# Daily development
git pull origin main          # Get latest changes
# ... make changes ...
git add .                     # Stage changes
git commit -m "feat: add new feature"  # Commit with conventional format
git push origin main          # Push to remote

# Feature development
git checkout -b feature/new-feature    # Create feature branch
# ... develop feature ...
git add .
git commit -m "feat: implement new feature"
git push origin feature/new-feature
# Create PR on GitHub
```

### Cross-Project Development

When working with multiple related projects:

```bash
# Terminal 1: Frontend development
cd workspace/frontend-app/
npm run dev                   # Runs on localhost:3000

# Terminal 2: Backend development  
cd workspace/backend-api/
python main.py               # Runs on localhost:8000

# Terminal 3: Database
docker-compose exec postgres psql -U user -d mydb
```

### Sharing Code Between Projects

Use the `shared-tools/` directory for common utilities:

```bash
workspace/shared-tools/
├── .git/                     # Independent git repo
├── lib/
│   ├── auth.py              # Authentication utilities
│   ├── database.py          # Database helpers
│   └── utils.py             # Common functions
└── package.json             # If it's a Node.js package
```

Projects can reference shared tools:

```python
# In workspace/backend-api/src/main.py
import sys
sys.path.append('../shared-tools/lib')
from auth import authenticate_user
```

## Container Integration

### Accessing Projects from Container

```bash
# Enter container
docker-compose exec dev-container bash

# All projects available at /workspace/
ls /workspace/
cd /workspace/my-project/

# Use container tools
nvim src/main.py             # Edit with Neovim
python src/main.py           # Run Python
npm install                  # Install Node packages
```

### Host vs Container Development

**Advantages of Container Development:**
- Consistent environment across machines
- Pre-configured development tools
- Isolated dependencies
- Easy cleanup and reset

**Advantages of Host Development:**
- Use familiar IDE (VS Code, IntelliJ, etc.)
- Better performance for some operations
- Direct file system access

**Best Practice**: Use both approaches:
- Edit files from host with your preferred IDE
- Run commands and tools from inside container
- Keep git operations on host for better integration

### Port Mapping for Development

Projects can expose services on different ports:

```yaml
# In docker-compose.yml, add port mappings as needed
ports:
  - "3000:3000"    # Frontend dev server
  - "3001:3001"    # Alternative frontend
  - "8000:8000"    # Backend API
  - "8001:8001"    # Alternative backend
  - "5432:5432"    # PostgreSQL
  - "6379:6379"    # Redis
```

Access services from host browser:
- Frontend: http://localhost:3000
- API: http://localhost:8000
- Database: localhost:5432

## Backup and Recovery

### Project Backup

Since each project is an independent git repository:

```bash
# Backup by pushing to remote
cd workspace/my-project/
git add .
git commit -m "backup: current state"
git push origin main

# Or create local backup
tar -czf ../my-project-backup.tar.gz .
```

### Workspace Backup

```bash
# From host system
cd docker-dev-environment/
tar -czf workspace-backup-$(date +%Y%m%d).tar.gz workspace/
```

### Recovery

```bash
# Restore entire workspace
tar -xzf workspace-backup-20240723.tar.gz

# Or restore individual project
cd workspace/
tar -xzf my-project-backup.tar.gz
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

### 4. Development Workflow
- Start container once, work on multiple projects
- Use tmux or multiple terminals for concurrent development
- Keep dependencies updated regularly
- Write tests for critical functionality

### 5. Performance
- Use `.dockerignore` to exclude unnecessary files from context
- Regularly clean up unused Docker resources: `docker system prune`
- Monitor disk usage: `du -sh workspace/*/`

This comprehensive setup provides a robust, scalable development environment where each project maintains its independence while benefiting from shared infrastructure and tooling.