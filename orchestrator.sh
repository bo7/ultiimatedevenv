#!/bin/bash

# Multi-Environment Development Orchestrator
# Manages specialized development environments

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
COMPOSE_FILE="docker-compose.yml"
SPECIALIZED_COMPOSE_FILE="docker-compose.specialized.yml"

print_header() {
    echo -e "${BLUE}"
    echo "██████╗ ███████╗██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗███╗   ██╗████████╗"
    echo "██╔══██╗██╔════╝██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗████╗ ████║██╔════╝████╗  ██║╚══██╔══╝"
    echo "██║  ██║█████╗  ██║   ██║█████╗  ██║     ██║   ██║██████╔╝██╔████╔██║█████╗  ██╔██╗ ██║   ██║   "
    echo "██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   "
    echo "██████╔╝███████╗ ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   "
    echo "╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${CYAN} Multi-Environment Development Orchestrator${NC}"
    echo "=============================================="
}

# Available environments
declare -A ENVIRONMENTS
ENVIRONMENTS[dev]="Main development environment with Claude Code + MCP"
ENVIRONMENTS[datascience]="Data science with Jupyter, R, Julia, ML libraries"
ENVIRONMENTS[devops]="DevOps with Terraform, Kubernetes, AWS/Azure/GCP tools"
ENVIRONMENTS[frontend]="Frontend development with React, Vue, Angular tools"
ENVIRONMENTS[backend]="Backend API development with FastAPI, databases"
ENVIRONMENTS[microservices]="Microservices with monitoring and tracing"
ENVIRONMENTS[security]="Security testing with OWASP ZAP, vulnerability scanning"
ENVIRONMENTS[testing]="Automated testing with Selenium, Playwright"
ENVIRONMENTS[mobile]="Mobile development with React Native, Expo"
ENVIRONMENTS[ml]="Machine learning with GPU support, TensorFlow, PyTorch"

# Function to list available environments
list_environments() {
    echo -e "${BLUE} Available Development Environments:${NC}"
    echo "======================================="
    
    for env in "${!ENVIRONMENTS[@]}"; do
        echo -e "${GREEN} $env${NC} - ${ENVIRONMENTS[$env]}"
    done
    
    echo ""
    echo -e "${YELLOW} Usage: ./orchestrator.sh start <environment>${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED} Missing dependencies: ${missing_deps[*]}${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED} Docker daemon is not running${NC}"
        exit 1
    fi
}

# Function to start an environment
start_environment() {
    local env=$1
    
    if [ -z "$env" ]; then
        echo -e "${RED} Environment name required${NC}"
        list_environments
        exit 1
    fi
    
    if [ ! ${ENVIRONMENTS[$env]+_} ]; then
        echo -e "${RED} Unknown environment: $env${NC}"
        list_environments
        exit 1
    fi
    
    echo -e "${BLUE} Starting $env environment...${NC}"
    echo "Description: ${ENVIRONMENTS[$env]}"
    echo ""
    
    # Check if it's the main dev environment
    if [ "$env" = "dev" ]; then
        docker-compose -f $COMPOSE_FILE up -d
    else
        # Use specialized compose file
        docker-compose -f $SPECIALIZED_COMPOSE_FILE up -d $env
    fi
    
    # Wait for services to be ready
    sleep 5
    
    echo -e "${GREEN} Environment '$env' is starting up!${NC}"
    show_environment_info $env
}

# Function to stop an environment
stop_environment() {
    local env=$1
    
    if [ -z "$env" ]; then
        echo -e "${YELLOW}  Stopping all environments...${NC}"
        docker-compose -f $COMPOSE_FILE down
        docker-compose -f $SPECIALIZED_COMPOSE_FILE down
    else
        echo -e "${YELLOW}  Stopping $env environment...${NC}"
        if [ "$env" = "dev" ]; then
            docker-compose -f $COMPOSE_FILE down
        else
            docker-compose -f $SPECIALIZED_COMPOSE_FILE stop $env
            docker-compose -f $SPECIALIZED_COMPOSE_FILE rm -f $env
        fi
    fi
    
    echo -e "${GREEN} Environment stopped${NC}"
}

# Function to show environment information
show_environment_info() {
    local env=$1
    
    echo -e "${PURPLE} Environment Information:${NC}"
    echo "==========================="
    
    case $env in
        dev)
            echo " Container: claude-dev-env"
            echo " Access: docker exec -it claude-dev-env zsh"
            echo " Tools: Claude Code, Vim IDE, VS Code, Python, Node.js"
            echo " Workspace: ./workspace"
            ;;
        datascience)
            echo " Container: datascience-env" 
            echo " Jupyter Lab: http://localhost:8888"
            echo " Streamlit: http://localhost:8501"
            echo " Dash: http://localhost:8050"
            echo " Tools: Python, R, Julia, ML libraries"
            ;;
        devops)
            echo " Container: devops-env"
            echo "  Kubernetes tools: kubectl, helm, k9s"
            echo "  Infrastructure: Terraform, Ansible"
            echo "  Cloud: AWS CLI, Azure CLI, GCP SDK"
            echo " Docker: Full Docker-in-Docker support"
            ;;
        frontend)
            echo " Container: frontend-env"
            echo "  React/Next.js: http://localhost:3000"
            echo " Vite: http://localhost:4000"
            echo " Storybook: http://localhost:6006"
            echo "  Tools: npm, webpack, vite, storybook"
            ;;
        backend)
            echo " Container: backend-env"
            echo " FastAPI: http://localhost:8000"
            echo "  PostgreSQL: localhost:5432"
            echo " Redis: localhost:6379"
            echo " Tools: FastAPI, SQLAlchemy, Alembic"
            ;;
        microservices)
            echo " Container: microservices-env"
            echo " API Gateway: http://localhost:8080"
            echo " Prometheus: http://localhost:9090"
            echo " Grafana: http://localhost:3000"
            echo " Jaeger: http://localhost:16686"
            ;;
        security)
            echo " Container: security-env"
            echo " OWASP ZAP: http://localhost:8008"
            echo " SonarQube: http://localhost:9001"
            echo "  Security scanning and penetration testing"
            ;;
        testing)
            echo " Container: testing-env"
            echo " Selenium Grid: http://localhost:4444"
            echo " Playwright testing environment"
            echo " Automated testing suite"
            ;;
        mobile)
            echo " Container: mobile-env"
            echo " Expo Dev: http://localhost:19000"
            echo " React Native development"
            echo " Android SDK included"
            ;;
        ml)
            echo " Container: ml-env"
            echo " Jupyter: http://localhost:8889"
            echo " TensorBoard: http://localhost:6006"
            echo "  GPU support enabled (if available)"
            echo " TensorFlow, PyTorch, scikit-learn"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN} Enter environment: docker exec -it ${env}-env zsh${NC}"
}

# Function to show status of all environments
show_status() {
    echo -e "${BLUE} Environment Status:${NC}"
    echo "===================="
    
    # Show main dev environment
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q claude-dev-env; then
        echo -e "${GREEN} dev${NC} - Running (claude-dev-env)"
    else
        echo -e "${RED} dev${NC} - Stopped"
    fi
    
    # Show specialized environments
    for env in datascience devops frontend backend microservices security testing mobile ml; do
        if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q ${env}-env; then
            echo -e "${GREEN} $env${NC} - Running (${env}-env)"
        else
            echo -e "${RED} $env${NC} - Stopped"
        fi
    done
    
    echo ""
    echo -e "${YELLOW} Resource Usage:${NC}"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "No containers running"
}

# Function to enter an environment
enter_environment() {
    local env=$1
    
    if [ -z "$env" ]; then
        echo -e "${RED} Environment name required${NC}"
        exit 1
    fi
    
    local container_name
    if [ "$env" = "dev" ]; then
        container_name="claude-dev-env"
    else
        container_name="${env}-env"
    fi
    
    if docker ps --format "{{.Names}}" | grep -q "$container_name"; then
        echo -e "${BLUE} Entering $env environment...${NC}"
        docker exec -it $container_name zsh
    else
        echo -e "${RED} Environment '$env' is not running${NC}"
        echo "Start it with: ./orchestrator.sh start $env"
    fi
}

# Function to create a new workspace
create_workspace() {
    local name=$1
    local env=${2:-dev}
    
    if [ -z "$name" ]; then
        echo -e "${RED} Workspace name required${NC}"
        exit 1
    fi
    
    echo -e "${BLUE} Creating workspace '$name' for $env environment...${NC}"
    
    mkdir -p "workspace/$name"
    
    case $env in
        datascience)
            mkdir -p "workspace/$name"/{notebooks,data,models,scripts}
            cat > "workspace/$name/README.md" << EOF
# $name - Data Science Project

## Structure
- \`notebooks/\` - Jupyter notebooks
- \`data/\` - Raw and processed data
- \`models/\` - Trained models
- \`scripts/\` - Python scripts

## Quick Start
1. Start environment: \`./orchestrator.sh start datascience\`
2. Open Jupyter: http://localhost:8888
3. Create notebook in \`notebooks/\` directory
EOF
            ;;
        backend)
            mkdir -p "workspace/$name"/{app,tests,docs,scripts}
            cat > "workspace/$name/app/main.py" << EOF
from fastapi import FastAPI

app = FastAPI(title="$name API")

@app.get("/")
async def root():
    return {"message": "Hello from $name!"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
EOF
            ;;
        frontend)
            mkdir -p "workspace/$name"/{src,public,tests}
            cat > "workspace/$name/package.json" << EOF
{
  "name": "$name",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "vite": "^4.0.0",
    "@vitejs/plugin-react": "^3.0.0"
  }
}
EOF
            ;;
    esac
    
    echo -e "${GREEN} Workspace '$name' created in workspace/$name${NC}"
}

# Function to backup environments
backup_environments() {
    echo -e "${BLUE} Creating backup of all environments...${NC}"
    
    BACKUP_NAME="dev-environments-backup-$(date +%Y%m%d-%H%M%S)"
    
    tar -czf "${BACKUP_NAME}.tar.gz" \
        workspace \
        data \
        configs \
        .env \
        docker-compose*.yml \
        dockerfiles \
        *.sh \
        *.md
    
    echo -e "${GREEN} Backup created: ${BACKUP_NAME}.tar.gz${NC}"
}

# Function to install advanced tools
install_advanced_tools() {
    echo -e "${BLUE} Installing advanced development tools...${NC}"
    
    if [ -f "./install-advanced-tools.sh" ]; then
        ./install-advanced-tools.sh
    else
        echo -e "${RED} Advanced tools installer not found${NC}"
    fi
}

# Function to show logs
show_logs() {
    local env=$1
    
    if [ -z "$env" ]; then
        echo -e "${BLUE} Showing logs for all environments...${NC}"
        docker-compose -f $COMPOSE_FILE logs -f &
        docker-compose -f $SPECIALIZED_COMPOSE_FILE logs -f &
        wait
    else
        echo -e "${BLUE} Showing logs for $env environment...${NC}"
        if [ "$env" = "dev" ]; then
            docker-compose -f $COMPOSE_FILE logs -f
        else
            docker-compose -f $SPECIALIZED_COMPOSE_FILE logs -f $env
        fi
    fi
}

# Main help function
show_help() {
    print_header
    echo ""
    echo -e "${CYAN}  Commands:${NC}"
    echo "============"
    echo ""
    echo -e "${GREEN}Environment Management:${NC}"
    echo "  list                    - List all available environments"
    echo "  start <env>             - Start a development environment"
    echo "  stop [env]              - Stop environment (or all if no env specified)"
    echo "  restart <env>           - Restart an environment"
    echo "  enter <env>             - Enter an environment shell"
    echo "  status                  - Show status of all environments"
    echo "  logs [env]              - Show logs (all or specific environment)"
    echo ""
    echo -e "${GREEN}Workspace Management:${NC}"
    echo "  workspace <name> [env]  - Create new workspace for environment"
    echo "  backup                  - Backup all environments and data"
    echo ""
    echo -e "${GREEN}Advanced Tools:${NC}"
    echo "  install-tools           - Install additional development tools"
    echo "  update                  - Update all container images"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./orchestrator.sh start datascience     # Start data science environment"
    echo "  ./orchestrator.sh enter backend         # Enter backend development shell"
    echo "  ./orchestrator.sh workspace my-api backend  # Create API project workspace"
    echo "  ./orchestrator.sh backup               # Backup everything"
    echo ""
    list_environments
}

# Main script logic
case "${1:-help}" in
    list)
        list_environments
        ;;
    start)
        check_prerequisites
        start_environment $2
        ;;
    stop)
        check_prerequisites
        stop_environment $2
        ;;
    restart)
        check_prerequisites
        stop_environment $2
        sleep 2
        start_environment $2
        ;;
    enter)
        enter_environment $2
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs $2
        ;;
    workspace)
        create_workspace $2 $3
        ;;
    backup)
        backup_environments
        ;;
    install-tools)
        install_advanced_tools
        ;;
    update)
        echo -e "${BLUE} Updating container images...${NC}"
        docker-compose -f $COMPOSE_FILE pull
        docker-compose -f $SPECIALIZED_COMPOSE_FILE pull
        echo -e "${GREEN} Images updated${NC}"
        ;;
    help|*)
        show_help
        ;;
esac
