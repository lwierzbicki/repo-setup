# Development Guide

## Branch Strategy

- **main**: Production-ready code, stable releases only
- **dev**: Integration branch for development
- **feature/**: Feature branches (temporary)
- **bugfix/**: Bug fix branches (temporary)

## Workflow

### Starting a New Feature

1. Create an issue on GitHub
2. Create feature branch from dev:
```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/my-feature-#123
```
3. Make changes and commit:
```bash
   git add .
   git commit -m "Add feature description (Closes #123)"
```
4. Push and create PR:
```bash
   git push -u origin feature/my-feature-#123
```
5. Create Pull Request: `dev` ← `feature/my-feature-#123`
6. After merge, clean up:
```bash
   git checkout dev
   git pull origin dev
   git branch -d feature/my-feature-#123
```

### Bug Fixes

Same as features, but use `bugfix/` prefix:
```bash
git checkout -b bugfix/fix-crash-#456
```

### Releasing

1. Update version and CHANGELOG on dev
2. Create PR: `main` ← `dev`
3. After merge, tag the release:
```bash
   git checkout main
   git pull origin main
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
```
4. Create GitHub Release
5. Sync dev with main:
```bash
   git checkout dev
   git merge main
   git push origin dev
```

## Commit Message Format