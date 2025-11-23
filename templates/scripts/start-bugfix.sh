#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: start-bugfix <issue-number> <bug-name>"
    echo "Example: start-bugfix 38 windows-crash"
    exit 1
fi

ISSUE_NUM=$1
BUG_NAME=$2
BRANCH_NAME="bugfix/${BUG_NAME}-#${ISSUE_NUM}"

echo "🔄 Switching to dev branch..."
git checkout dev || { echo "❌ Failed to checkout dev"; exit 1; }

echo "📥 Pulling latest changes..."
git pull origin dev || { echo "❌ Failed to pull dev"; exit 1; }

echo "🌿 Creating bugfix branch: ${BRANCH_NAME}"
git checkout -b "${BRANCH_NAME}" || { echo "❌ Failed to create branch"; exit 1; }

echo "✅ Bugfix branch created successfully!"
echo "📝 Branch: ${BRANCH_NAME}"
echo ""
echo "Next steps:"
echo "  1. Fix the bug"
echo "  2. Run: git add ."
echo "  3. Run: git commit -m 'Fix description (Fixes #${ISSUE_NUM})'"
echo "  4. Run: git push -u origin ${BRANCH_NAME}"