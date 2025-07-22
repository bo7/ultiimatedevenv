#!/bin/bash

# Quick Setup and Test Script for Docker Development Environment
# =============================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE} Docker Development Environment Setup${NC}"
echo "==========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED} Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN} Docker is running${NC}"

# Check if docker-compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    echo -e "${RED} docker-compose not found. Please install Docker Compose.${NC}"
    exit 1
fi
echo -e "${GREEN} Docker Compose is available${NC}"

# Run setup
echo ""
echo -e "${BLUE} Setting up directories and environment...${NC}"
./manage.sh setup

# Check if .env was created and prompt for API key
if [ -f .env ]; then
    if grep -q "your_openrouter_key_here" .env; then
        echo ""
        echo -e "${YELLOW}  API Key Setup Required${NC}"
        echo "Please add your OpenRouter API key to .env file"
        echo "Get your key from: https://openrouter.ai/keys"
        echo ""
        read -p "Do you want to edit .env now? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} .env
        fi
    fi
fi

# Build the container
echo ""
echo -e "${BLUE} Building development container...${NC}"
echo "This may take a few minutes on first run..."
./manage.sh build

# Start the environment
echo ""
echo -e "${BLUE} Starting development environment...${NC}"
./manage.sh start

# Wait a moment for startup
sleep 3

# Test the container
echo ""
echo -e "${BLUE} Testing container...${NC}"

# Test basic tools
echo "Testing Node.js..."
docker exec claude-dev-env node --version

echo "Testing Python..."
docker exec claude-dev-env python3 --version

echo "Testing npm..."
docker exec claude-dev-env npm --version

echo "Testing Claude Code..."
if docker exec claude-dev-env which claude > /dev/null 2>&1; then
    echo -e "${GREEN} Claude Code installed${NC}"
else
    echo -e "${RED} Claude Code not found${NC}"
fi

echo "Testing Vim..."
docker exec claude-dev-env vim --version | head -n1

echo "Testing VS Code..."
docker exec claude-dev-env code --version | head -n1

# Test MCP configuration
echo ""
echo "Testing MCP configuration..."
if docker exec claude-dev-env test -f /home/devuser/.claude-code/global_mcp_config.json; then
    echo -e "${GREEN} MCP configuration found${NC}"
else
    echo -e "${RED} MCP configuration missing${NC}"
fi

# Show status
echo ""
./manage.sh status

# Success message
echo ""
echo -e "${GREEN} Setup Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Enter the container: ${BLUE}./manage.sh enter${NC}"
echo "2. Test Claude Code: ${BLUE}claude -p 'Hello from container'${NC}"
echo "3. Start coding in: ${BLUE}/workspace${NC}"
echo ""
echo "VS Code: ${BLUE}code .${NC} (inside container)"
echo "Vim IDE: ${BLUE}vim your_file.py${NC} (inside container)"
echo ""
echo " See README.md for detailed usage instructions"
