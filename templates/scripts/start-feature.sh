#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: start-feature <issue-number> <feature-name>"
    echo "Example: start-feature 42 config-support"
    exit 1
fi

ISSUE_NUM=$1
FEATURE_NAME=$2
BRANCH_NAME="feature/${FEATURE_NAME}-#${ISSUE_NUM}"

echo "🔄 Switching to dev branch..."
git checkout dev || { echo "❌ Failed to checkout dev"; exit 1; }

echo "📥 Pulling latest changes..."
git pull origin dev || { echo "❌ Failed to pull dev"; exit 1; }

echo "🌿 Creating feature branch: ${BRANCH_NAME}"
git checkout -b "${BRANCH_NAME}" || { echo "❌ Failed to create branch"; exit 1; }

echo "✅ Feature branch created successfully!"
echo "📝 Branch: ${BRANCH_NAME}"
echo ""
echo "Next steps:"
echo "  1. Make your changes"
echo "  2. Run: git add ."
echo "  3. Run: git commit -m 'Your message (Closes #${ISSUE_NUM})'"
echo "  4. Run: git push -u origin ${BRANCH_NAME}"