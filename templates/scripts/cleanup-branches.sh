#!/bin/bash

echo "🔍 Cleaning up merged branches..."
echo ""

# Switch to dev to check what's merged
git checkout dev 2>/dev/null
git fetch --prune origin

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Local feature/bugfix branches:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find all local feature/bugfix branches
LOCAL_BRANCHES=$(git branch | grep -E '^\s*(feature|bugfix)/' | sed 's/^[ *]*//')

if [ -z "$LOCAL_BRANCHES" ]; then
    echo "✨ No local feature/bugfix branches found!"
else
    echo "$LOCAL_BRANCHES"
    echo ""
    
    # Check which are merged to dev
    MERGED_TO_DEV=$(git branch --merged dev | grep -E '^\s*(feature|bugfix)/' | sed 's/^[ *]*//')
    
    if [ -z "$MERGED_TO_DEV" ]; then
        echo "ℹ️  None of these branches are merged to dev yet"
    else
        echo ""
        echo "Branches merged to dev:"
        echo "$MERGED_TO_DEV"
        echo ""
        echo "Delete these branches? (y/n)"
        read -r delete_merged
        
        if [[ $delete_merged =~ ^[Yy]$ ]]; then
            echo "$MERGED_TO_DEV" | while read -r branch; do
                echo "🗑️  Deleting: $branch"
                git branch -d "$branch" 2>/dev/null || git branch -D "$branch"
            done
            echo "✅ Merged branches deleted"
        fi
    fi
    
    # Show unmerged branches
    UNMERGED=$(comm -23 <(echo "$LOCAL_BRANCHES" | sort) <(echo "$MERGED_TO_DEV" | sort))
    
    if [ -n "$UNMERGED" ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Unmerged branches (not deleted):"
        echo "$UNMERGED"
        echo ""
        echo "Force delete unmerged branches? (y/n)"
        read -r force_delete
        
        if [[ $force_delete =~ ^[Yy]$ ]]; then
            echo "⚠️  This will delete branches that haven't been merged!"
            echo "Are you sure? Type 'yes' to confirm:"
            read -r confirm
            
            if [[ $confirm == "yes" ]]; then
                echo "$UNMERGED" | while read -r branch; do
                    echo "🗑️  Force deleting: $branch"
                    git branch -D "$branch"
                done
                echo "✅ Unmerged branches deleted"
            else
                echo "❌ Aborted"
            fi
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Remote branches that no longer exist:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Clean up tracking branches for deleted remotes
git fetch --prune origin

# Find stale remote tracking branches
STALE=$(git branch -vv | grep ': gone]' | awk '{print $1}' | sed 's/^[ *]*//')

if [ -z "$STALE" ]; then
    echo "✨ No stale remote tracking branches!"
else
    echo "$STALE"
    echo ""
    echo "Delete these local branches? (y/n)"
    read -r delete_stale
    
    if [[ $delete_stale =~ ^[Yy]$ ]]; then
        echo "$STALE" | while read -r branch; do
            echo "🗑️  Deleting: $branch"
            git branch -D "$branch"
        done
        echo "✅ Stale branches deleted"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Cleanup complete!"
echo ""
echo "Current branches:"
git branch