#!/bin/bash
# This is identical to finish-feature.sh but for bugfix branches
CURRENT_BRANCH=$(git branch --show-current)

if [[ ! $CURRENT_BRANCH =~ ^bugfix/ ]]; then
    echo "❌ Not on a bugfix branch!"
    echo "Current branch: ${CURRENT_BRANCH}"
    exit 1
fi

# Check if there are uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "⚠️  You have uncommitted changes!"
    git status -s
    echo ""
    echo "Please commit or stash your changes first."
    exit 1
fi

# Check if branch has been pushed
if ! git rev-parse --verify "origin/${CURRENT_BRANCH}" &>/dev/null; then
    echo "⚠️  Branch not pushed to remote yet"
    echo "Pushing branch to origin..."
    git push -u origin "${CURRENT_BRANCH}" || {
        echo "❌ Failed to push branch"
        exit 1
    }
fi

# Check if there are unpushed commits
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "⚠️  You have unpushed commits"
    echo "Pushing latest commits..."
    git push || {
        echo "❌ Failed to push commits"
        exit 1
    }
fi

echo "📝 Creating Pull Request for bugfix..."
echo ""

gh pr create --base dev --fill || {
    echo ""
    echo "❌ Failed to create PR"
    echo "You can create it manually on GitHub"
    exit 1
}

echo ""
echo "✅ Pull Request created!"
echo ""

echo "Do you want to merge the PR now? (y/n)"
echo "  y = Merge immediately"
echo "  n = Wait for review"
read -r merge_now

if [[ $merge_now =~ ^[Yy]$ ]]; then
    echo ""
    echo "Select merge strategy:"
    echo "  1) Squash and merge (combines all commits into one)"
    echo "  2) Merge commit (preserves all commits)"
    echo "  3) Rebase and merge (linear history)"
    read -p "Choice (1-3, default=1): " merge_strategy
    
    case ${merge_strategy:-1} in
        1)
            echo "🔀 Squashing and merging..."
            gh pr merge --squash --delete-branch || {
                echo "❌ Failed to merge PR"
                exit 1
            }
            ;;
        2)
            echo "🔀 Creating merge commit..."
            gh pr merge --merge --delete-branch || {
                echo "❌ Failed to merge PR"
                exit 1
            }
            ;;
        3)
            echo "🔀 Rebasing and merging..."
            gh pr merge --rebase --delete-branch || {
                echo "❌ Failed to merge PR"
                exit 1
            }
            ;;
        *)
            echo "❌ Invalid choice"
            exit 1
            ;;
    esac
    
    echo "✅ PR merged successfully!"
    
    echo ""
    echo "🔄 Switching to dev branch..."
    git checkout dev || { echo "❌ Failed to checkout dev"; exit 1; }
    
    echo "📥 Pulling latest changes..."
    git pull origin dev || { echo "❌ Failed to pull dev"; exit 1; }
    
    echo "🗑️  Deleting local branch: ${CURRENT_BRANCH}"
    git branch -D "${CURRENT_BRANCH}" 2>/dev/null
    
    echo ""
    echo "✅ Bugfix complete!"
    echo "📝 You're now on: dev"
    
else
    echo ""
    echo "📋 PR created and waiting for review"
    echo ""
    echo "To merge later, run:"
    echo "  gh pr merge --squash --delete-branch"
    echo ""
    echo "Or merge via GitHub, then:"
    echo "  git checkout dev && git pull origin dev"
    echo "  git branch -D ${CURRENT_BRANCH}"
fi