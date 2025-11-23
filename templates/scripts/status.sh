#!/bin/bash

CURRENT_BRANCH=$(git branch --show-current)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Git Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Current branch: ${CURRENT_BRANCH}"

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo ""
    echo "⚠️  Uncommitted changes:"
    git status -s
else
    echo "✅ Working directory clean"
fi

echo ""

# Check commits ahead/behind
if git rev-parse --abbrev-ref @{u} &>/dev/null 2>&1; then
    UPSTREAM=$(git rev-parse --abbrev-ref @{u})
    AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    
    echo "🔗 Tracking: ${UPSTREAM}"
    
    if [ "$AHEAD" -gt 0 ]; then
        echo "⬆️  Ahead: ${AHEAD} commit(s)"
    fi
    
    if [ "$BEHIND" -gt 0 ]; then
        echo "⬇️  Behind: ${BEHIND} commit(s)"
    fi
    
    if [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ]; then
        echo "✅ Up to date with remote"
    fi
else
    echo "⚠️  Not tracking a remote branch"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Show recent commits
echo "📜 Recent commits on ${CURRENT_BRANCH}:"
git log --oneline --graph -5

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Show branch list
echo "🌿 Local branches:"
git branch --format="%(if)%(HEAD)%(then)* %(end)%(refname:short)%(if)%(upstream)%(then) -> %(upstream:short)%(end)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Suggest next steps based on branch
echo "💡 Suggested next steps:"
echo ""

if [[ $CURRENT_BRANCH == "dev" ]]; then
    echo "  Start new work:"
    echo "    ./scripts/start-feature.sh <issue-num> <name>"
    echo "    ./scripts/start-bugfix.sh <issue-num> <name>"
    echo ""
    echo "  Prepare release:"
    echo "    ./scripts/prepare-release.sh <version>"
    
elif [[ $CURRENT_BRANCH =~ ^(feature|bugfix)/ ]]; then
    if [[ -n $(git status -s) ]]; then
        echo "  Commit changes:"
        echo "    git add ."
        echo "    git commit -m 'Your message (Closes #N)'"
    fi
    
    echo "  Push and create PR:"
    echo "    ./scripts/push-feature.sh"
    echo ""
    echo "  Finish (push, PR, merge, cleanup):"
    if [[ $CURRENT_BRANCH =~ ^feature/ ]]; then
        echo "    ./scripts/finish-feature.sh"
    else
        echo "    ./scripts/finish-bugfix.sh"
    fi
    
elif [[ $CURRENT_BRANCH == "main" ]]; then
    echo "  Tag release:"
    echo "    ./scripts/tag-release.sh <version>"
    echo ""
    echo "  Sync dev with main:"
    echo "    ./scripts/sync-dev.sh"
    echo ""
    echo "  Switch to dev:"
    echo "    git checkout dev"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"