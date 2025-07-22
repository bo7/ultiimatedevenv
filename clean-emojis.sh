#!/bin/bash
#
# Manual emoji removal script for development
# Run this anytime you want to clean emojis from your project
#

set -e

echo "🧹 Manual Emoji Removal Tool"
echo "================================"

# Get the root directory of the git repository
GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT"

# Check if remove_emojis.py exists
EMOJI_SCRIPT="claude-setup/templates/remove_emojis.py"
if [ ! -f "$EMOJI_SCRIPT" ]; then
    echo "❌ Error: remove_emojis.py not found at $EMOJI_SCRIPT"
    exit 1
fi

# Check if emoji module is available
if ! python3 -c "import emoji" 2>/dev/null; then
    echo "📦 Installing emoji module..."
    pip3 install --user emoji 2>/dev/null || \
    pip3 install --break-system-packages emoji 2>/dev/null || \
    python3 -m pip install --user emoji 2>/dev/null || \
    {
        echo "❌ Could not install emoji module"
        echo "Please install manually: pip3 install --user emoji"
        exit 1
    }
fi

# Parse command line arguments
DRY_RUN=false
AUTO_COMMIT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --commit|-c)
            AUTO_COMMIT=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -d    Show what would be changed without modifying files"
            echo "  --commit, -c     Automatically commit changes after emoji removal"
            echo "  --help, -h       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Remove emojis and show results"
            echo "  $0 --dry-run         # Preview what would be changed"
            echo "  $0 --commit          # Remove emojis and auto-commit changes"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run emoji removal
if [ "$DRY_RUN" = true ]; then
    echo "🔍 Running dry-run to preview changes..."
    python3 "$EMOJI_SCRIPT" --root "$GIT_ROOT" --dry-run
else
    echo "🔍 Checking for emojis in project files..."
    
    # First run dry-run to see what would change
    CHANGES=$(python3 "$EMOJI_SCRIPT" --root "$GIT_ROOT" --dry-run)
    echo "$CHANGES"
    
    if echo "$CHANGES" | grep -q "would remove"; then
        echo ""
        echo "⚠️  Emojis detected in project files!"
        echo "🧹 Running emoji removal..."
        
        # Run actual emoji removal
        python3 "$EMOJI_SCRIPT" --root "$GIT_ROOT"
        
        if [ "$AUTO_COMMIT" = true ]; then
            # Auto-commit changes
            echo "📝 Staging and committing emoji removal changes..."
            git add -A
            
            if ! git diff --cached --quiet; then
                git commit -m "chore: manual emoji removal

- Remove emojis for cleaner, professional codebase
- Run via clean-emojis.sh script"
                echo "💾 Changes committed successfully!"
            else
                echo "ℹ️  No changes to commit"
            fi
        else
            echo ""
            echo "📝 Emoji removal completed!"
            echo "💡 Changes are unstaged. To commit them:"
            echo "   git add -A"
            echo "   git commit -m 'chore: remove emojis'"
            echo ""
            echo "💡 Or run this script with --commit flag to auto-commit"
        fi
    else
        echo "✅ No emojis found in project files!"
    fi
fi

echo ""
echo "🎯 Emoji removal process completed!"
