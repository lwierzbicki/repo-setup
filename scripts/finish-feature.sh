#!/bin/bash
CURRENT_BRANCH=$(git branch --show-current)

if [[ ! $CURRENT_BRANCH =~ ^(feature|bugfix)/ ]]; then
    echo "❌ Not on a feature or bugfix branch!"
    echo "Current branch: ${CURRENT_BRANCH}"
    exit 1
fi

echo "🔄 Switching to dev branch..."
git checkout dev || { echo "❌ Failed to checkout dev"; exit 1; }

echo "📥 Pulling latest changes..."
git pull origin dev || { echo "❌ Failed to pull dev"; exit 1; }

echo "🗑️  Deleting local branch: ${CURRENT_BRANCH}"
git branch -d "${CURRENT_BRANCH}" || {
    echo "⚠️  Branch not fully merged. Force delete? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git branch -D "${CURRENT_BRANCH}"
    else
        echo "❌ Aborted"
        exit 1
    fi
}

echo "✅ Feature branch cleaned up!"
echo "📝 You're now on: dev"