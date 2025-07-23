#!/bin/bash
# Start development environment optimized for Ghostty splits
# This script runs inside the container

echo "Starting development environment..."
echo "Ghostty splits should be managed from the host terminal"
echo "Use Cmd+D for right split, Cmd+Shift+D for down split"

# Setup Claude configuration with environment variables
if [ -f "/home/devuser/setup-claude-config.sh" ]; then
    /home/devuser/setup-claude-config.sh
fi

# Check for project requirements and install them
if [ -f "/workspace/requirements.txt" ]; then
    echo "Found requirements.txt, installing packages..."
    pip install -r /workspace/requirements.txt
elif [ -f "/workspace/pyproject.toml" ]; then
    echo "Found pyproject.toml, installing with pip..."
    pip install -e /workspace
elif [ -f "/workspace/package.json" ]; then
    echo "Found package.json, installing npm dependencies..."
    cd /workspace && npm install
fi

# Check for saved container state and offer to restore
if [ -f "/workspace/.container-packages.txt" ]; then
    echo "Found saved package state. Restore? (y/n)"
    read -t 10 -n 1 restore_choice
    if [ "$restore_choice" = "y" ]; then
        echo "Restoring saved packages..."
        pip install -r /workspace/.container-packages.txt
    fi
fi

echo ""
echo "Development environment ready!"
echo "Recommended Ghostty layout:"
echo "1. Current pane: Start Neovim with: nvim"
echo "2. Cmd+D: Create right split for terminal/shell"
echo "3. Cmd+Shift+D: Create bottom right split for Claude Code"
echo ""
echo "Commands:"
echo "  nvim           - Start Neovim editor"
echo "  claude         - Start Claude Code with MCP servers"
echo "  claude --mcp-debug - Start Claude Code with MCP debugging"
echo "  python         - Python 3.12 REPL"
echo "  dev-help       - Show more development commands"
echo ""
echo "MCP Servers configured:"
echo "  ✓ Filesystem    - File operations"
echo "  ✓ Memory        - Memory storage"
echo "  ✓ Fetch         - Web content fetching"
echo "  ✓ Time          - Date/time operations"
echo "  ✓ Context7      - Documentation lookup"
echo "  ✓ Desktop Cmd   - Desktop commands"
echo "  ✓ Brave Search  - Web search (with API key)"
echo "  ✓ Zen (Beehive) - Multi-AI orchestration (Gemini/OpenAI/Ollama)"
echo ""
echo "Zen MCP Server Features:"
echo "  • chat         - Collaborative thinking with multiple AIs"
echo "  • thinkdeep    - Extended reasoning and analysis"
echo "  • codereview   - Professional code review"
echo "  • debug        - Root cause analysis"
echo "  • analyze      - Code and architecture analysis"
echo ""
echo "Ollama Integration:"
echo "  • External Ollama: http://host.docker.internal:11434"
echo "  • Default model: qwen3:8b (configurable)"
echo ""
