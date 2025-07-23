#!/bin/bash
#
# Git hooks setup script
# Ensures all necessary git hooks are installed and configured
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE} Setting up Git hooks...${NC}"

# Get the git repository root
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
HOOKS_DIR="$GIT_ROOT/.git/hooks"

# Ensure hooks directory exists
mkdir -p "$HOOKS_DIR"

# Install pre-push hook for emoji removal
PRE_PUSH_HOOK="$HOOKS_DIR/pre-push"

if [ -f "$PRE_PUSH_HOOK" ]; then
    echo -e "${YELLOW}  Pre-push hook already exists${NC}"
    echo "Backing up existing hook..."
    mv "$PRE_PUSH_HOOK" "$PRE_PUSH_HOOK.backup.$(date +%s)"
fi

echo -e "${BLUE} Installing pre-push hook for emoji removal...${NC}"

cat > "$PRE_PUSH_HOOK" << 'EOF'
#!/bin/bash
#
# Git pre-push hook to remove emojis from all files before pushing
# This ensures clean, professional code without emoji characters
#

set -e

echo " Running pre-push emoji removal..."

# Get the root directory of the git repository
GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT"

# Check if remove_emojis.py exists
EMOJI_SCRIPT="claude-setup/templates/remove_emojis.py"
if [ ! -f "$EMOJI_SCRIPT" ]; then
    echo " Error: remove_emojis.py not found at $EMOJI_SCRIPT"
    exit 1
fi

# Check if emoji module is available
if ! python3 -c "import emoji" 2>/dev/null; then
    echo " Installing emoji module..."
    pip3 install --user emoji 2>/dev/null || \\
    pip3 install --break-system-packages emoji 2>/dev/null || \\
    python3 -m pip install --user emoji 2>/dev/null || \\
    {
        echo " Could not install emoji module - skipping emoji removal"
        echo "Please install manually: pip3 install --user emoji"
        exit 0
    }
fi

# Run emoji removal (dry run first to show what would change)
echo " Checking for emojis in project files..."
python3 "$EMOJI_SCRIPT" --root "$GIT_ROOT" --dry-run

# Ask for confirmation if emojis were found
if python3 "$EMOJI_SCRIPT" --root "$GIT_ROOT" --dry-run | grep -q "would remove"; then
    echo ""
    echo "  Emojis detected in project files!"
    echo " Running automatic emoji removal..."
    
    # Run actual emoji removal
    python3 "$EMOJI_SCRIPT" --root "$GIT_ROOT"
    
    # Stage the changes
    echo " Staging emoji removal changes..."
    git add -A
    
    # Check if there are changes to commit
    if ! git diff --cached --quiet; then
        echo " Committing emoji removal changes..."
        git commit -m "chore: remove emojis before push

- Automatic emoji removal via pre-push hook
- Ensures clean, professional codebase
- Run by remove_emojis.py script"
    fi
    
    echo " Emoji removal completed successfully!"
else
    echo " No emojis found - proceeding with push"
fi

echo " Pre-push checks passed - proceeding with push..."
EOF

# Make the hook executable
chmod +x "$PRE_PUSH_HOOK"

echo -e "${GREEN} Pre-push hook installed successfully!${NC}"

# Install any other hooks here in the future

echo ""
echo -e "${BLUE} Git hooks summary:${NC}"
echo "   Pre-push hook: Automatic emoji removal"
echo ""
echo -e "${BLUE} The pre-push hook will:${NC}"
echo "  1. Scan all project files for emojis before each push"
echo "  2. Automatically remove any emojis found"
echo "  3. Commit the changes and continue with push"
echo ""
echo -e "${GREEN} Git hooks setup complete!${NC}"
