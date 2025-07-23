#!/bin/bash
#
# Branch Protection Setup Script
# 
# This script helps set up branch protection rules for the repository
# to enforce fork-based contributions and prevent direct pushes to main
#

set -e

echo " Branch Protection Setup"
echo "=========================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo " Error: Not in a git repository"
    exit 1
fi

# Check if we have a remote origin
ORIGIN_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$ORIGIN_URL" ]; then
    echo " Error: No origin remote found"
    echo " Add remote: git remote add origin <repository-url>"
    exit 1
fi

echo " Repository: $ORIGIN_URL"
echo ""

# Extract repository info
if [[ "$ORIGIN_URL" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    echo " Owner: $REPO_OWNER"
    echo " Repository: $REPO_NAME"
else
    echo " Error: Could not parse GitHub repository URL"
    exit 1
fi

echo ""
echo " Required Branch Protection Rules"
echo "===================================="
echo ""
echo "To enforce fork-based contributions, set up these rules on GitHub:"
echo ""
echo "1.  Restrict pushes to main branch"
echo "   - Go to: Settings → Branches → Add rule"
echo "   - Branch name pattern: main"
echo "   -  Restrict pushes that create files"
echo "   -  Restrict force pushes"
echo "   -  Include administrators"
echo ""
echo "2.  Require pull request reviews"
echo "   -  Require a pull request before merging"
echo "   -  Require approvals: 1"
echo "   -  Dismiss stale reviews when new commits are pushed"
echo "   -  Require review from code owners (if CODEOWNERS file exists)"
echo ""
echo "3.  Require status checks"
echo "   -  Require branches to be up to date before merging"
echo "   -  Require 'PR Ready for Review' check to pass"
echo "   -  Require 'Security Scan' check to pass"
echo "   -  Require 'Test Docker Build' check to pass"
echo ""
echo "4.  Additional restrictions"
echo "   -  Require conversation resolution before merging"
echo "   -  Require signed commits (recommended)"
echo "   -  Do not allow bypassing the above settings"
echo ""

# Check if GitHub CLI is available
if command -v gh > /dev/null 2>&1; then
    echo " GitHub CLI detected!"
    echo ""
    read -p " Would you like to set up branch protection via GitHub CLI? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo " Setting up branch protection rules..."
        
        # Set up branch protection
        gh api repos/$REPO_OWNER/$REPO_NAME/branches/main/protection \
            --method PUT \
            --field required_status_checks='{"strict":true,"contexts":["PR Ready for Review","Security Scan","Test Docker Build"]}' \
            --field enforce_admins=true \
            --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":false}' \
            --field restrictions=null \
            2>/dev/null && echo " Branch protection rules applied!" || echo " Failed to apply rules (check permissions)"
    fi
else
    echo " Install GitHub CLI for automated setup:"
    echo "   brew install gh  # macOS"
    echo "   # or visit: https://cli.github.com"
fi

echo ""
echo " Manual Setup Instructions"
echo "============================"
echo ""
echo "If you prefer manual setup, visit:"
echo "https://github.com/$REPO_OWNER/$REPO_NAME/settings/branches"
echo ""
echo "And apply the rules listed above."
echo ""

echo " Verification Checklist"
echo "========================="
echo ""
echo "After setup, verify:"
echo "□ Direct push to main is blocked"
echo "□ PRs are required for main branch"
echo "□ Status checks are required"
echo "□ Admin enforcement is enabled"
echo "□ Force pushes are blocked"
echo ""

echo " Test the Setup"
echo "=================="
echo ""
echo "To test branch protection:"
echo ""
echo "1. Try to push directly to main (should fail):"
echo "   git push origin main"
echo ""
echo "2. Create a feature branch and PR:"
echo "   git checkout -b test/branch-protection"
echo "   echo 'test' > test-file.txt"
echo "   git add test-file.txt"
echo "   git commit -m 'test: verify branch protection'"
echo "   git push origin test/branch-protection"
echo "   # Then create PR on GitHub"
echo ""

echo " Branch Protection Setup Complete!"
echo ""
echo " Next steps:"
echo "   1. Apply branch protection rules (manual or via GitHub CLI)"
echo "   2. Test the setup with a test PR"
echo "   3. Update CONTRIBUTING.md if needed"
echo "   4. Inform contributors about the new workflow"
