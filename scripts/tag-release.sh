#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: tag-release <version>"
    echo "Example: tag-release 1.2.0"
    exit 1
fi

VERSION=$1
TAG_NAME="v${VERSION}"

# Validate semantic versioning format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Use semantic versioning: MAJOR.MINOR.PATCH"
    exit 1
fi

echo "🔄 Switching to main branch..."
git checkout main || { echo "❌ Failed to checkout main"; exit 1; }

echo "📥 Pulling latest changes..."
git pull origin main || { echo "❌ Failed to pull main"; exit 1; }

echo ""
echo "🏷️  Creating annotated tag: ${TAG_NAME}"
echo ""
echo "Enter release notes (or press Ctrl+D to use CHANGELOG):"
echo "---"

# Try to extract from CHANGELOG
if [ -f CHANGELOG.md ] && grep -q "\[${VERSION}\]" CHANGELOG.md; then
    echo "Found version ${VERSION} in CHANGELOG.md"
    echo "Use CHANGELOG content for release notes? (y/n)"
    read -r use_changelog
    
    if [[ $use_changelog =~ ^[Yy]$ ]]; then
        # Extract release notes from CHANGELOG
        NOTES=$(sed -n "/## \[${VERSION}\]/,/## \[/p" CHANGELOG.md | sed '$d' | tail -n +2)
    else
        NOTES=$(cat)
    fi
else
    NOTES=$(cat)
fi

if [ -z "$NOTES" ]; then
    NOTES="Release version ${VERSION}"
fi

git tag -a "${TAG_NAME}" -m "Release version ${VERSION}

${NOTES}" || {
    echo "❌ Tag creation failed"
    exit 1
}

echo ""
echo "📤 Pushing tag to GitHub..."
git push origin "${TAG_NAME}" || {
    echo "❌ Push failed"
    exit 1
}

echo ""
echo "✅ Tag ${TAG_NAME} created and pushed!"
echo ""
echo "🌐 Next steps:"
echo "  1. Create GitHub Release:"
echo "     gh release create ${TAG_NAME} --title \"${TAG_NAME}\" --notes \"${NOTES}\""
echo "  2. Or go to: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/new?tag=${TAG_NAME}"
echo "  3. Attach binaries if needed"
echo "  4. Run: ./scripts/sync-dev.sh"