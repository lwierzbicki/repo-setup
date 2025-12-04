#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: create-release-pr <version>"
    echo "Example: create-release-pr 1.2.0"
    exit 1
fi

VERSION=$1

# Validate semantic versioning format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Use semantic versioning: MAJOR.MINOR.PATCH"
    echo "Example: 1.2.0"
    exit 1
fi

echo "🔍 Analyzing changes between main and dev..."
echo ""

# Make sure we're up to date
git fetch origin

# Get all commits from main to dev
COMMITS=$(git log origin/main..origin/dev --oneline)

if [ -z "$COMMITS" ]; then
    echo "⚠️  No commits found between main and dev"
    echo "Nothing to release!"
    exit 1
fi

echo "📝 Commits in this release:"
echo "$COMMITS"
echo ""

# Extract issue numbers from commits
# Looks for patterns: #123, Closes #123, Fixes #123, Resolves #123
ISSUE_NUMBERS=$(echo "$COMMITS" | grep -oP '(#\K[0-9]+|Closes #\K[0-9]+|Fixes #\K[0-9]+|Resolves #\K[0-9]+)' | sort -u)

if [ -z "$ISSUE_NUMBERS" ]; then
    echo "⚠️  No issue references found in commits"
    echo "Creating PR without issue closures..."
    ISSUES_LIST=""
else
    echo "🔗 Issues referenced in commits:"
    echo "$ISSUE_NUMBERS" | while read -r num; do
        # Get issue title
        ISSUE_TITLE=$(gh issue view "$num" --json title -q .title 2>/dev/null || echo "Issue #$num")
        echo "  #$num - $ISSUE_TITLE"
    done
    echo ""
    
    # Build issues list for PR body
    ISSUES_LIST=""
    while read -r num; do
        ISSUE_TITLE=$(gh issue view "$num" --json title -q .title 2>/dev/null || echo "")
        ISSUE_LABELS=$(gh issue view "$num" --json labels -q '.labels[].name' 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
        
        if [ -n "$ISSUE_TITLE" ]; then
            # Categorize by label
            if echo "$ISSUE_LABELS" | grep -qi "bug"; then
                ISSUES_LIST="${ISSUES_LIST}
- Fix: $ISSUE_TITLE (#$num)"
            elif echo "$ISSUE_LABELS" | grep -qi "enhancement"; then
                ISSUES_LIST="${ISSUES_LIST}
- Feature: $ISSUE_TITLE (#$num)"
            elif echo "$ISSUE_LABELS" | grep -qi "documentation"; then
                ISSUES_LIST="${ISSUES_LIST}
- Docs: $ISSUE_TITLE (#$num)"
            else
                ISSUES_LIST="${ISSUES_LIST}
- $ISSUE_TITLE (#$num)"
            fi
        else
            ISSUES_LIST="${ISSUES_LIST}
- Issue #$num"
        fi
    done <<< "$ISSUE_NUMBERS"
fi

# Try to extract from CHANGELOG
CHANGELOG_CONTENT=""
if [ -f CHANGELOG.md ] && grep -q "\[${VERSION}\]" CHANGELOG.md; then
    echo "📋 Found version ${VERSION} in CHANGELOG.md"
    CHANGELOG_CONTENT=$(sed -n "/## \[${VERSION}\]/,/## \[/p" CHANGELOG.md | sed '$d' | tail -n +2 | sed 's/^//')
fi

# Build PR body
PR_BODY="# Release v${VERSION}

## Changes in this release
${ISSUES_LIST}

## Detailed Changes
${CHANGELOG_CONTENT}

---

## Commits
${COMMITS}

---

"

# Add closing keywords for all issues
if [ -n "$ISSUE_NUMBERS" ]; then
    PR_BODY="${PR_BODY}
Closes $(echo "$ISSUE_NUMBERS" | tr '\n' ',' | sed 's/,/, #/g' | sed 's/^/#/' | sed 's/, $//')"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 Pull Request Preview:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Title: Release v${VERSION}"
echo ""
echo "$PR_BODY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Confirm
read -p "Create this Pull Request? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ Aborted"
    exit 0
fi

echo ""
echo "🚀 Creating Pull Request: main ← dev"

# Create PR
echo "$PR_BODY" | gh pr create \
    --base main \
    --head dev \
    --title "Release v${VERSION}" \
    --body-file - || {
    echo "❌ Failed to create PR"
    echo ""
    echo "You can create it manually with this body:"
    echo "$PR_BODY"
    exit 1
}

echo ""
echo "✅ Release PR created successfully!"
echo ""
echo "🌐 Next steps:"
echo "  1. Review and merge the PR"
echo "  2. Run: ./scripts/tag-release.sh ${VERSION}"
echo "  3. Run: ./scripts/sync-dev.sh"