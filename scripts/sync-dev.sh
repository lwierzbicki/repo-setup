#!/bin/bash

echo "🔄 Syncing dev with main after release..."
echo ""

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)

echo "📥 Fetching latest from origin..."
git fetch origin || { echo "❌ Fetch failed"; exit 1; }

echo "🔄 Switching to main..."
git checkout main || { echo "❌ Failed to checkout main"; exit 1; }

echo "📥 Pulling main..."
git pull origin main || { echo "❌ Failed to pull main"; exit 1; }

echo "🔄 Switching to dev..."
git checkout dev || { echo "❌ Failed to checkout dev"; exit 1; }

echo "📥 Pulling dev..."
git pull origin dev || { echo "❌ Failed to pull dev"; exit 1; }

echo "🔀 Merging main into dev..."
git merge main -m "Sync dev with main after release" || {
    echo "❌ Merge conflict detected!"
    echo "Please resolve conflicts manually, then:"
    echo "  git add ."
    echo "  git commit"
    echo "  git push origin dev"
    exit 1
}

echo "📤 Pushing dev..."
git push origin dev || { echo "❌ Push failed"; exit 1; }

# Return to original branch if it wasn't dev
if [ "$CURRENT_BRANCH" != "dev" ] && [ "$CURRENT_BRANCH" != "main" ]; then
    echo "🔄 Returning to ${CURRENT_BRANCH}..."
    git checkout "$CURRENT_BRANCH" 2>/dev/null || {
        echo "⚠️  Could not return to ${CURRENT_BRANCH}"
        echo "📝 You're now on: dev"
    }
else
    echo "📝 You're now on: dev"
fi

echo ""
echo "✅ Dev synced with main!"
echo "🌿 Ready for new development!"