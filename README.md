# repo-setup

Automated GitHub repository setup tool with complete development workflow for CLI tools and open-source projects.

## Overview

This project provides a comprehensive automation script that creates a fully configured GitHub repository with professional development workflows, branch management scripts, and best practices built-in. Perfect for starting new CLI tools, libraries, or any open-source project.

- [repo-setup](#repo-setup)
  - [Overview](#overview)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [GitHub CLI](#github-cli)
    - [Authentication](#authentication)
  - [Usage](#usage)
    - [1. Clone This Repository](#1-clone-this-repository)
    - [2. Run Setup Script](#2-run-setup-script)
    - [3. Follow Interactive Prompts](#3-follow-interactive-prompts)
    - [4. Done! 🎉](#4-done-)
  - [Features](#features)
    - [🚀 One-Command Repository Creation](#-one-command-repository-creation)
    - [📁 Complete Project Structure](#-complete-project-structure)
    - [🌿 Branch Strategy Implementation](#-branch-strategy-implementation)
    - [✨ Intelligent Automation](#-intelligent-automation)
  - [Benefits](#benefits)
    - [For Solo Developers](#for-solo-developers)
    - [For Teams](#for-teams)
    - [For Open Source](#for-open-source)
  - [Troubleshooting](#troubleshooting)
    - ["GitHub CLI not installed"](#github-cli-not-installed)
    - ["SSH authentication failed"](#ssh-authentication-failed)
    - ["Branch protection failed"](#branch-protection-failed)
    - ["Issues not closing"](#issues-not-closing)
  - [Contributing](#contributing)
  - [Changelog](#changelog)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)
  - [Support](#support)



## Installation

### Prerequisites

- **Git** - Version control
- **GitHub CLI (gh)** - For repository and PR management
- **SSH keys** - Configured for GitHub authentication

### GitHub CLI
```bash
# macOS
brew install gh

# Windows
winget install --id GitHub.cli

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### Authentication
```bash
# Authenticate with GitHub
gh auth login

# Set up SSH keys (if not already done)
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-add ~/.ssh/id_ed25519
gh ssh-key add ~/.ssh/id_ed25519.pub
```

## Usage

### 1. Clone This Repository
```bash
git clone git@github.com:lwierzbicki/repo-setup.git
cd repo-setup
```

### 2. Run Setup Script
```bash
chmod +x setup-repo.sh
./setup-repo.sh
```

### 3. Follow Interactive Prompts
- Enter repository name
- Provide description
- Select language (Python/Rust/Node/Go)
- Choose public/private

### 4. Done! 🎉
Your new repository is created with everything configured and ready for development.

## Features

### 🚀 One-Command Repository Creation
- Creates GitHub repository via CLI
- Sets up proper .gitignore for your language (Python, Rust, Node, Go)
- Adds MIT License automatically
- Configures SSH for seamless Git operations

### 📁 Complete Project Structure
- Professional README with sections for installation, usage, features
- CHANGELOG.md following Keep a Changelog format
- DEVELOPMENT.md with detailed workflow guidelines
- Issue templates (bug reports, feature requests)
- GitHub funding configuration (Sponsors, Buy Me a Coffee)

### 🌿 Branch Strategy Implementation
- **main**: Production-ready releases only
- **dev**: Integration branch for development
- **feature/**: Temporary feature branches
- **bugfix/**: Temporary bugfix branches
- Branch protection rules configured automatically

### ✨ Intelligent Automation
- **Automatic PR creation** via GitHub CLI
- **Issue auto-closing** when releases merge to main
- **Smart issue collection** - extracts and categorizes all issues in release
- **Context-aware suggestions** - scripts suggest next steps based on current branch
- **Error handling** - comprehensive checks and helpful error messages

## Benefits

### For Solo Developers
- ⚡ **Fast setup** - New project in under 2 minutes
- 🎯 **Focus on code** - Workflow automation handles Git operations
- 📝 **Professional structure** - Best practices built-in
- 🔄 **Consistent process** - Same workflow for every project

### For Teams
- 👥 **Standardized workflow** - Everyone follows same process
- 🔒 **Protected branches** - Prevents accidental force pushes
- 📋 **Clear guidelines** - DEVELOPMENT.md documents process
- 🎫 **Issue tracking** - Issues linked to releases

### For Open Source
- ⭐ **Contributor-friendly** - Clear contributing guidelines
- 📄 **Issue templates** - Easy bug reporting and feature requests
- 💰 **Sponsorship ready** - Funding.yml configured
- 🏷️ **Proper releases** - Tagged versions with release notes

## Troubleshooting

### "GitHub CLI not installed"
Install `gh` using instructions above, then run `gh auth login`.

### "SSH authentication failed"
Set up SSH keys:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
gh ssh-key add ~/.ssh/id_ed25519.pub
```

### "Branch protection failed"
This requires admin rights. Set up manually:
- Go to Settings → Branches → Add rule for `main`

### "Issues not closing"
Issues only close when PR merges to `main` (default branch), not `dev`. This is intentional - issues close when released, not when developed.

## Contributing

Contributions welcome! This project follows its own workflow:

1. Create an issue describing your improvement
2. Fork the repository
3. Run `./scripts/start-feature.sh <issue-num> <feature-name>`
4. Make changes and commit
5. Run `./scripts/finish-feature.sh` (if you have access) - Or push and create PR manually
6. Wait for review and merge.

Please read [DEVELOPMENT.md](DEVELOPMENT.md) for detailed workflow guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed version history.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with:
- [GitHub CLI](https://cli.github.com/) - Command-line interface for GitHub
- Git - Version control system
- Bash - Shell scripting

## Support

- 📖 [Full Documentation](./DEVELOPMENT.md)
- 🐛 [Report Bug](../../issues/new?template=bug_report.md)
- 💡 [Request Feature](../../issues/new?template=feature_request.md)
- ⭐ Star this repo if you find it useful!

---