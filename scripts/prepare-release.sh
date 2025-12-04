#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: prepare-release <version>"
    echo "Example: prepare-release 1.2.0"
    exit 1
fi

VERSION=$1

# Validate semantic versioning format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Use semantic versioning: MAJOR.MINOR.PATCH"
    echo "Example: 1.2.0"
    exit 1
fi

echo "🔄 Switching to dev branch..."
git checkout dev || { echo "❌ Failed to checkout dev"; exit 1; }

echo "📥 Pulling latest changes..."
git pull origin dev || { echo "❌ Failed to pull dev"; exit 1; }

echo ""
echo "📝 Preparing release v${VERSION}..."
echo ""
echo "Please update the following files:"
echo "  ✏️  Version number in your code"
echo "  ✏️  CHANGELOG.md with release notes"
echo ""
echo "Opening CHANGELOG.md for editing..."
echo ""

# Add new version section to CHANGELOG if it doesn't exist
if ! grep -q "\[${VERSION}\]" CHANGELOG.md 2>/dev/null; then
    # Create temporary file with new version
    {
        echo "## [${VERSION}] - $(date +%Y-%m-%d)"
        echo ""
        echo "### Added"
        echo "- "
        echo ""
        echo "### Changed"
        echo "- "
        echo ""
        echo "### Fixed"
        echo "- "
        echo ""
    } > /tmp/changelog_new.md
    
    # Insert after [Unreleased] section
    if [ -f CHANGELOG.md ]; then
        sed -i.bak '/## \[Unreleased\]/r /tmp/changelog_new.md' CHANGELOG.md
        rm CHANGELOG.md.bak 2>/dev/null
    fi
fi

# Open editor for CHANGELOG
${EDITOR:-nano} CHANGELOG.md

echo ""
echo "Press Enter when you've finished updating version and CHANGELOG..."
read -r

# Check if there are changes to commit
if [[ -z $(git status -s) ]]; then
    echo "⚠️  No changes detected. Did you update the version and CHANGELOG?"
    echo "Continue anyway? (y/n)"
    read -r continue
    if [[ ! $continue =~ ^[Yy]$ ]]; then
        echo "❌ Aborted"
        exit 1
    fi
fi

echo "📦 Committing release preparation..."
git add .
git commit -m "Bump version to ${VERSION}

Prepare release ${VERSION}" || {
    echo "❌ Commit failed"
    exit 1
}

echo "📤 Pushing to dev..."
git push origin dev || {
    echo "❌ Push failed"
    exit 1
}

echo ""
echo "✅ Release v${VERSION} prepared on dev!"
echo ""
echo "🌐 Next steps:"
echo "  1. Run: ./scripts/create-release.sh ${VERSION}"
echo "  2. Review and merge the PR"
echo "  3. Run: ./scripts/tag-release.sh ${VERSION}"
echo "  4. Run: ./scripts/sync-dev.sh"