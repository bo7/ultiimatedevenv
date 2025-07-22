#!/bin/bash

# Development Environment Setup and Management Script
# ==================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Function to create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p workspace
    mkdir -p data/{home,vscode-extensions,claude-config,npm-global,cache,git,ssh,postgres,redis}
    
    # Set permissions
    chmod 700 data/ssh
    
    print_success "Directories created successfully"
}

# Function to setup environment file
setup_environment() {
    if [ ! -f .env ]; then
        print_status "Creating environment file..."
        
        cat > .env << EOF
# Docker Environment Configuration
COMPOSE_PROJECT_NAME=claude-dev

# API Keys (Replace with your actual keys)
OPENROUTER_API_KEY=your_openrouter_key_here

# Model Configuration
DEFAULT_MODEL=deepseek/deepseek-r1-0528
ZEN_DEFAULT_MODEL=deepseek/deepseek-r1-0528
ZEN_THINKING_MODE=medium

# Git Configuration
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your.email@example.com

# Display (for GUI apps if needed)
DISPLAY=:0
EOF
        
        print_warning "Please edit .env file and add your API keys!"
        print_status "Environment file created at .env"
    else
        print_status "Environment file already exists"
    fi
}

# Function to build the container
build_container() {
    print_status "Building development container..."
    docker-compose build --no-cache
    print_success "Container built successfully"
}

# Function to start the environment
start_environment() {
    print_status "Starting development environment..."
    docker-compose up -d
    
    # Wait for container to be ready
    sleep 5
    
    if docker-compose ps | grep -q "Up"; then
        print_success "Development environment is running!"
        print_status "Container: claude-dev-env"
        print_status "Workspace: ./workspace (mounted to /workspace)"
        print_status "Access: docker exec -it claude-dev-env zsh"
    else
        print_error "Failed to start development environment"
        exit 1
    fi
}

# Function to stop the environment
stop_environment() {
    print_status "Stopping development environment..."
    docker-compose down
    print_success "Development environment stopped"
}

# Function to enter the container
enter_container() {
    if docker-compose ps | grep -q "Up"; then
        print_status "Entering development container..."
        docker exec -it claude-dev-env zsh
    else
        print_error "Development environment is not running"
        print_status "Start it with: ./manage.sh start"
        exit 1
    fi
}

# Function to view logs
view_logs() {
    docker-compose logs -f dev-environment
}

# Function to reset environment
reset_environment() {
    print_warning "This will destroy all data in the development environment"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Resetting development environment..."
        docker-compose down -v
        docker-compose build --no-cache
        rm -rf data/*
        create_directories
        print_success "Environment reset complete"
    else
        print_status "Reset cancelled"
    fi
}

# Function to backup data
backup_data() {
    print_status "Creating backup of development environment..."
    
    BACKUP_NAME="dev-env-backup-$(date +%Y%m%d-%H%M%S)"
    
    tar -czf "${BACKUP_NAME}.tar.gz" workspace data .env
    
    print_success "Backup created: ${BACKUP_NAME}.tar.gz"
}

# Function to show status
show_status() {
    print_status "Development Environment Status"
    echo "======================================"
    
    if docker-compose ps | grep -q "Up"; then
        print_success "Environment: RUNNING"
        
        # Show container stats
        docker stats --no-stream claude-dev-env 2>/dev/null || true
        
        # Show port mappings
        echo ""
        print_status "Port Mappings:"
        docker-compose ps
        
    else
        print_warning "Environment: STOPPED"
    fi
    
    echo ""
    print_status "Workspace: $(pwd)/workspace"
    print_status "Data: $(pwd)/data"
    
    if [ -f .env ]; then
        print_status "Environment file: ✓"
    else
        print_warning "Environment file: ✗"
    fi
}

# Function to install VS Code extensions
install_vscode_extensions() {
    if docker-compose ps | grep -q "Up"; then
        print_status "Installing VS Code extensions..."
        
        # List of extensions to install
        extensions=(
            "ms-python.python"
            "ms-python.black-formatter"
            "ms-python.flake8"
            "ms-python.pylint"
            "ms-python.mypy"
            "ms-python.isort"
            "ms-vscode.azure-cli-tools"
            "ms-azure-devops.azure-devops"
            "eamodio.gitlens"
            "github.vscode-pull-request-github"
            "esbenp.prettier-vscode"
            "ms-vscode.vscode-eslint"
            "ms-vscode.vscode-typescript-next"
        )
        
        for ext in "${extensions[@]}"; do
            docker exec claude-dev-env code --install-extension "$ext"
        done
        
        print_success "VS Code extensions installed"
    else
        print_error "Environment not running. Start it first with: ./manage.sh start"
    fi
}

# Function to show help
show_help() {
    echo "Development Environment Management"
    echo "=================================="
    echo ""
    echo "Usage: ./manage.sh [command]"
    echo ""
    echo "Commands:"
    echo "  setup     - Initial setup (create directories and .env)"
    echo "  build     - Build the development container"
    echo "  start     - Start the development environment"
    echo "  stop      - Stop the development environment"
    echo "  restart   - Restart the development environment"
    echo "  enter     - Enter the development container"
    echo "  logs      - View container logs"
    echo "  status    - Show environment status"
    echo "  backup    - Create backup of workspace and data"
    echo "  reset     - Reset the entire environment (DESTRUCTIVE)"
    echo "  vscode    - Install VS Code extensions"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./manage.sh setup    # First time setup"
    echo "  ./manage.sh start    # Start environment"
    echo "  ./manage.sh enter    # Enter container shell"
}

# Main script logic
case "${1:-help}" in
    setup)
        create_directories
        setup_environment
        ;;
    build)
        build_container
        ;;
    start)
        start_environment
        ;;
    stop)
        stop_environment
        ;;
    restart)
        stop_environment
        start_environment
        ;;
    enter)
        enter_container
        ;;
    logs)
        view_logs
        ;;
    status)
        show_status
        ;;
    backup)
        backup_data
        ;;
    reset)
        reset_environment
        ;;
    vscode)
        install_vscode_extensions
        ;;
    help|*)
        show_help
        ;;
esac
