# Development Guide

## Branch Strategy

- **main**: Production-ready code, stable releases only
- **dev**: Integration branch for development
- **feature/**: Feature branches (temporary)
- **bugfix/**: Bug fix branches (temporary)

```
main (production)
  ↑
  └── dev (integration)
        ↑
        ├── feature/awesome-#42
        ├── feature/config-#45
        └── bugfix/crash-#38
```

**Key principles:**
- ✅ Never commit directly to `main`
- ✅ All work goes through `dev` first
- ✅ Features/bugfixes in separate branches
- ✅ Issues stay open until released to `main`
- ✅ Branch protection prevents mistakes

### Issue Lifecycle

1. **Create issue** on GitHub (#42)
2. **Create branch** with issue reference (`feature/config-#42`)
3. **Commit** with closing keyword (`Closes #42`)
4. **Merge to dev** via PR (issue stays open)
5. **Release to main** (issue closes automatically!)

This ensures issues only close when changes reach production.

## Workflow

### Check status

Always check status first
```
./scripts/status.sh
```

### New Feature

1) Create issue #123 on GitHub

2) Start feature
```
./scripts/start-feature.sh 123 awesome-feature
```
3) Make changes
```
# ... edit files ...
git add .
git commit -m "Add awesome feature (Closes #123)"
```
4) Finish (push + PR + merge + cleanup)
```
./scripts/finish-feature.sh
# Choose merge strategy when prompted
```

### Bug Fixes

Same as features, but use `bugfix/` prefix:
1) Create issue #456 on GitHub

2) Start bugfix
```
./scripts/start-bugfix.sh 456 critical-crash
```
3) Fix the bug
```
# ... edit files ...
git add .
git commit -m "Fix critical crash (Fixes #456)"
```
4) Finish
```
./scripts/finish-bugfix.sh
```

### Release to Production

1) Prepare release on dev
```
./scripts/prepare-release.sh 1.2.0
# Updates CHANGELOG.md, commits, pushes to dev
```
2) Create release PR (automatically collects all issues!)
```
./scripts/create-release-pr.sh 1.2.0
# Analyzes commits between main and dev
# Extracts all issue numbers
# Fetches issue titles and labels
# Creates PR with all "Closes #N" references
# Issues will auto-close when PR merges!
```
3) Review and merge PR on GitHub
```
# When merged to main, all referenced issues close automatically!
```
4) Tag the release
```
./scripts/tag-release.sh 1.2.0
```
5) Create GitHub Release
```
gh release create v1.2.0 --title "v1.2.0" --notes "Release notes here"
```
6) Sync dev with main
```
./scripts/sync-dev.sh
```

### Save Work in Progress

Current work on feature branch, not ready for PR yet
```
# Commit and push
./scripts/push-feature.sh
# Will commit if you have changes and push to remote
```

### Maintenance and Cleanup

Clean up merged and stale branches
```
./scripts/cleanup-branches.sh
```

## Scripts

Powerful scripts to streamline your entire development process:

| Script | Purpose |
|--------|---------|
| `start-feature.sh` | Create feature branch from dev |
| `start-bugfix.sh` | Create bugfix branch from dev |
| `push-feature.sh` | Save work to remote without PR |
| `finish-feature.sh` | Create PR, merge, and cleanup automatically |
| `finish-bugfix.sh` | Same as above for bugfixes |
| `prepare-release.sh` | Prepare new release with version bump |
| `create-release-pr.sh` | Create release PR with automatic issue collection |
| `tag-release.sh` | Tag release after merging to main |
| `sync-dev.sh` | Sync dev with main after release |
| `status.sh` | Show git status with smart suggestions |
| `cleanup-branches.sh` | Clean up merged and stale branches |