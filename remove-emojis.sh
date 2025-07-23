#!/bin/bash
#
# Manual emoji removal script for Docker development environment
# Run this script before pushing changes to ensure clean codebase
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE} Docker Development Environment - Emoji Removal Tool${NC}"
echo "=================================================="

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Check if we're in a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo -e "${RED} Error: Not in a git repository root${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Path to the emoji removal script
EMOJI_SCRIPT="$PROJECT_ROOT/claude-setup/templates/remove_emojis.py"

if [ ! -f "$EMOJI_SCRIPT" ]; then
    echo -e "${RED} Error: remove_emojis.py not found${NC}"
    echo "Expected location: $EMOJI_SCRIPT"
    exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED} Error: Python 3 is required but not found${NC}"
    exit 1
fi

# Check if emoji module is available, install if needed
echo -e "${BLUE} Checking Python emoji module...${NC}"
if ! python3 -c "import emoji" 2>/dev/null; then
    echo -e "${YELLOW}  Installing emoji module...${NC}"
    # Try different installation methods
    if command -v pip3 &> /dev/null; then
        pip3 install --user emoji 2>/dev/null || \
        pip3 install --break-system-packages emoji 2>/dev/null || \
        python3 -m pip install --user emoji 2>/dev/null || \
        {
            echo -e "${YELLOW}  Could not install emoji module automatically${NC}"
            echo "Please install manually with one of:"
            echo "  pip3 install --user emoji"
            echo "  pip3 install --break-system-packages emoji"
            echo "  python3 -m pip install --user emoji"
            exit 1
        }
    else
        echo -e "${RED} Error: pip3 not found${NC}"
        exit 1
    fi
fi

# Parse command line arguments
DRY_RUN=false
FORCE=false
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo -e "${RED} Unknown option: $1${NC}"
            HELP=true
            shift
            ;;
    esac
done

if [ "$HELP" = true ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run, -d    Show what would be changed without modifying files"
    echo "  --force, -f      Skip confirmation prompts"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                # Interactive emoji removal"
    echo "  $0 --dry-run     # Preview changes without modifying files"
    echo "  $0 --force       # Remove emojis without confirmation"
    exit 0
fi

echo -e "${BLUE} Scanning for emojis in project files...${NC}"

# Run dry run first to check for emojis
DRY_RUN_OUTPUT=$(python3 "$EMOJI_SCRIPT" --root "$PROJECT_ROOT" --dry-run 2>&1)
echo "$DRY_RUN_OUTPUT"

# Check if emojis were found
if echo "$DRY_RUN_OUTPUT" | grep -q "would remove"; then
    EMOJI_COUNT=$(echo "$DRY_RUN_OUTPUT" | grep "Total emojis removed:" | awk '{print $4}')
    echo ""
    echo -e "${YELLOW}  Found $EMOJI_COUNT emojis in project files!${NC}"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}  Dry run complete - no files modified${NC}"
        exit 0
    fi
    
    if [ "$FORCE" = false ]; then
        echo ""
        echo -e "${YELLOW}Do you want to remove all emojis? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}  Operation cancelled${NC}"
            exit 0
        fi
    fi
    
    echo ""
    echo -e "${BLUE} Removing emojis from project files...${NC}"
    
    # Run actual emoji removal
    python3 "$EMOJI_SCRIPT" --root "$PROJECT_ROOT"
    
    echo ""
    echo -e "${GREEN} Emoji removal completed successfully!${NC}"
    
    # Check git status
    if git diff --quiet; then
        echo -e "${BLUE}  No changes detected (emojis may have been in non-tracked files)${NC}"
    else
        echo -e "${YELLOW} Changes detected in tracked files${NC}"
        echo ""
        echo "Modified files:"
        git diff --name-only | while read file; do
            echo "  - $file"
        done
        
        echo ""
        echo -e "${BLUE} Next steps:${NC}"
        echo "  1. Review changes: git diff"
        echo "  2. Stage changes: git add -A"
        echo "  3. Commit changes: git commit -m 'chore: remove emojis'"
        echo "  4. Push changes: git push"
    fi
    
else
    echo ""
    echo -e "${GREEN} No emojis found in project files - codebase is clean!${NC}"
fi

echo ""
echo -e "${BLUE} Emoji removal process complete${NC}"
