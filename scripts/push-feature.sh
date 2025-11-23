#!/bin/bash
CURRENT_BRANCH=$(git branch --show-current)

if [[ ! $CURRENT_BRANCH =~ ^(feature|bugfix)/ ]]; then
    echo "❌ Not on a feature or bugfix branch!"
    echo "Current branch: ${CURRENT_BRANCH}"
    exit 1
fi

# Check if there are uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "⚠️  You have uncommitted changes!"
    git status -s
    echo ""
    echo "Commit them first? (y/n)"
    read -r should_commit
    
    if [[ $should_commit =~ ^[Yy]$ ]]; then
        echo "Enter commit message:"
        read -r commit_msg
        git add .
        git commit -m "$commit_msg" || {
            echo "❌ Commit failed"
            exit 1
        }
    else
        echo "Please commit or stash your changes first."
        exit 1
    fi
fi

echo "📤 Pushing branch: ${CURRENT_BRANCH}"

# Check if branch exists on remote
if git rev-parse --verify "origin/${CURRENT_BRANCH}" &>/dev/null; then
    # Branch exists, just push
    git push || {
        echo "❌ Push failed"
        exit 1
    }
else
    # First time pushing this branch
    git push -u origin "${CURRENT_BRANCH}" || {
        echo "❌ Push failed"
        exit 1
    }
fi

echo "✅ Branch pushed successfully!"
echo ""
echo "🌐 Next steps:"
echo "  • Create PR: ./scripts/finish-feature.sh (or finish-bugfix.sh)"
echo "  • Or manually: gh pr create --base dev --fill"