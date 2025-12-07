#!/bin/bash

# ============================================
# GitHub CLI Tool Repository Setup Script
# This script automates the entire repository creation and setup process
# ============================================

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed!"
        echo ""
        echo "Install it from: https://cli.github.com/"
        echo ""
        echo "macOS:   brew install gh"
        echo "Linux:   See https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        echo "Windows: winget install --id GitHub.cli"
        exit 1
    fi
    print_success "GitHub CLI found"
}

# Check if templates directory exists
check_templates() {
    if [ ! -d "$TEMPLATES_DIR" ]; then
        print_error "Templates directory not found: $TEMPLATES_DIR"
        echo ""
        echo "Please create a templates/ directory with the following structure:"
        echo "  templates/"
        echo "  ├── README.md"
        echo "  ├── CHANGELOG.md"
        echo "  ├── DEVELOPMENT.md"
        exit 1
    fi
    print_success "Templates directory found"
}

# Check if user is authenticated
check_gh_auth() {
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub!"
        echo ""
        echo "Run: gh auth login"
        exit 1
    fi
    print_success "GitHub authentication verified"
}

# Check SSH keys
check_ssh_keys() {
    print_info "Checking SSH keys..."
    
    if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_warning "SSH key authentication may not be set up"
        echo ""
        echo "To set up SSH keys:"
        echo "  1. Generate key: ssh-keygen -t ed25519 -C \"your_email@example.com\""
        echo "  2. Add to agent: ssh-add ~/.ssh/id_ed25519"
        echo "  3. Add to GitHub: gh ssh-key add ~/.ssh/id_ed25519.pub"
        echo ""
        read -p "Continue anyway? (y/N): " CONTINUE
        if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "SSH authentication verified"
    fi
}

# Get repository details from user
get_repo_details() {
    echo ""
    print_info "Repository Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Repository name
    read -p "Repository name: " REPO_NAME
    if [ -z "$REPO_NAME" ]; then
        print_error "Repository name cannot be empty"
        exit 1
    fi
    
    # Description
    read -p "Description: " REPO_DESC
    
    # Language/gitignore template
    echo ""
    echo "Select language for .gitignore:"
    echo "  1) Python"
    echo "  2) Rust"
    echo "  3) Node (JavaScript/TypeScript)"
    echo "  4) Go"
    echo "  5) Other/None"
    read -p "Choice (1-5): " LANG_CHOICE
    
    case $LANG_CHOICE in
        1) GITIGNORE="Python" ;;
        2) GITIGNORE="Rust" ;;
        3) GITIGNORE="Node" ;;
        4) GITIGNORE="Go" ;;
        5) GITIGNORE="" ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
    
    # Visibility
    echo ""
    read -p "Public repository? (Y/n): " IS_PUBLIC
    if [[ $IS_PUBLIC =~ ^[Nn]$ ]]; then
        VISIBILITY="private"
    else
        VISIBILITY="public"
    fi
}

# Create the repository
create_repository() {
    print_info "Creating GitHub repository..."
    
    # Build gh repo create command
    CMD="gh repo create ${REPO_NAME} --${VISIBILITY}"
    
    if [ -n "$REPO_DESC" ]; then
        CMD="$CMD --description \"${REPO_DESC}\""
    fi
    
    if [ -n "$GITIGNORE" ]; then
        CMD="$CMD --gitignore ${GITIGNORE}"
    fi
    
    # Add README and LICENSE
    CMD="$CMD --license mit --add-readme"
    
    # Execute the command
    eval $CMD || {
        print_error "Failed to create repository"
        exit 1
    }
    
    print_success "Repository created: ${REPO_NAME}"
}

# Clone the repository
clone_repository() {
    print_info "Cloning repository locally..."
    
    # Get GitHub username
    GH_USER=$(gh api user -q .login)
    
    # Clone using SSH
    git clone "git@github.com:${GH_USER}/${REPO_NAME}.git" || {
        print_error "Failed to clone repository"
        print_warning "Make sure you have SSH keys set up with GitHub"
        echo "See: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
        exit 1
    }
    
    cd "$REPO_NAME"
    print_success "Repository cloned to: $(pwd)"
}

# Update README with proper structure
setup_readme() {
    print_info "Setting up README..."
    
    if [ ! -f "$TEMPLATES_DIR/README.md" ]; then
        print_error "Template not found: $TEMPLATES_DIR/README.md"
        exit 1
    fi
    
    # Copy template and replace placeholders
    sed -e "s/{{REPO_NAME}}/${REPO_NAME}/g" \
        -e "s/{{REPO_DESC}}/${REPO_DESC}/g" \
        "$TEMPLATES_DIR/README.md" > README.md
    
    print_success "README.md created from template"
}

# Create CHANGELOG
create_changelog() {
    print_info "Creating CHANGELOG.md..."
    
    if [ ! -f "$TEMPLATES_DIR/CHANGELOG.md" ]; then
        print_error "Template not found: $TEMPLATES_DIR/CHANGELOG.md"
        exit 1
    fi
    
    # Copy template and replace date placeholder
    sed "s/{{DATE}}/$(date +%Y-%m-%d)/g" "$TEMPLATES_DIR/CHANGELOG.md" > CHANGELOG.md
    
    print_success "CHANGELOG.md created from template"
}

# Create development guide
create_dev_guide() {
    print_info "Creating DEVELOPMENT.md..."
    
    if [ ! -f "$TEMPLATES_DIR/DEVELOPMENT.md" ]; then
        print_error "Template not found: $TEMPLATES_DIR/DEVELOPMENT.md"
        exit 1
    fi
    
    cp "$TEMPLATES_DIR/DEVELOPMENT.md" DEVELOPMENT.md
    
    print_success "DEVELOPMENT.md created from template"
}

# Create funding file
create_funding() {
    print_info "Creating funding configuration..."
    
    mkdir -p .github
    
    if [ ! -f "$SCRIPT_DIR/.github/FUNDING.yml" ]; then
        print_error "Template not found: $SCRIPT_DIR/.github/FUNDING.yml"
        exit 1
    fi
    
    cp "$SCRIPT_DIR/.github/FUNDING.yml" .github/FUNDING.yml
    
    print_success "FUNDING.yml created from template"
}

# Create issue templates
create_issue_templates() {
    print_info "Creating issue templates..."
    
    mkdir -p .github/ISSUE_TEMPLATE
    
    if [ ! -f "$SCRIPT_DIR/.github/ISSUE_TEMPLATE/bug_report.md" ]; then
        print_error "Template not found: $SCRIPT_DIR/.github/ISSUE_TEMPLATE/bug_report.md"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/.github/ISSUE_TEMPLATE/feature_request.md" ]; then
        print_error "Template not found: $SCRIPT_DIR/.github/ISSUE_TEMPLATE/feature_request.md"
        exit 1
    fi
    
    cp "$SCRIPT_DIR/.github/ISSUE_TEMPLATE/bug_report.md" .github/ISSUE_TEMPLATE/
    cp "$SCRIPT_DIR/.github/ISSUE_TEMPLATE/feature_request.md" .github/ISSUE_TEMPLATE/
    
    print_success "Issue templates created from templates"
}

# Create dev branch
create_dev_branch() {
    print_info "Creating dev branch..."
    
    git checkout -b dev
    git push -u origin dev
    
    print_success "Dev branch created"
}

# Set up branch protection
setup_branch_protection() {
    print_info "Setting up branch protection..."
    
    # Get GitHub username
    GH_USER=$(gh api user -q .login)
    
    # Protect main branch with proper JSON structure
    gh api repos/${GH_USER}/${REPO_NAME}/branches/main/protection \
        --method PUT \
        --input - << 'EOF' 2>/dev/null || {
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_conversation_resolution": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
        print_warning "Could not set branch protection"
        echo "Set it manually: Settings → Branches → Add rule for 'main'"
        return 1
    }
    
    print_success "Branch protection configured for main"
}

# Commit all setup files
commit_setup() {
    print_info "Committing setup files..."
    
    git add .
    git commit -m "Add development setup

- Add CHANGELOG.md
- Add DEVELOPMENT.md
- Add issue templates
- Update README.md
"
    git push origin dev
    
    print_success "Setup files committed to dev"
}

# Create management scripts
create_scripts() {
    print_info "Creating branch management scripts..."
    
    mkdir -p scripts
    
    # List of all scripts
    SCRIPTS=(
        "start-feature.sh"
        "start-bugfix.sh"
        "finish-feature.sh"
        "finish-bugfix.sh"
        "push-feature.sh"
        "prepare-release.sh"
        "create-release.sh"
        "tag-release.sh"
        "sync-dev.sh"
        "status.sh"
        "cleanup-branches.sh"
    )
    
    # Check if template scripts exist
    for script in "${SCRIPTS[@]}"; do
        if [ ! -f "$SCRIPT_DIR/scripts/$script" ]; then
            print_error "Template not found: $SCRIPT_DIR/scripts/$script"
            exit 1
        fi
    done
    
    # Copy all script templates
    cp "$SCRIPT_DIR/scripts/"*.sh scripts/
    
    # Make them executable
    chmod +x scripts/*.sh
    
    git add scripts/
    git commit -m "Add branch management scripts"
    git push origin dev
    
    print_success "Management scripts created from templates"
}

# Print final instructions
print_final_instructions() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Repository setup complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "Repository: https://github.com/$(gh api user -q .login)/${REPO_NAME}"
    print_info "Local path: $(pwd)"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Add your CLI tool code"
    echo "   2. Start working on features:"
    echo "      ./scripts/start-feature.sh <issue-num> <feature-name>"
    echo "   3. Read DEVELOPMENT.md for workflow details"
    echo ""
    echo "🔒 Manual setup required:"
    echo "   • Go to Settings → Branches"
    echo "   • Add branch protection rules for 'main'"
    echo "   • Go to Issues → Labels and customize labels"
    echo ""
}

# Main execution
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  GitHub CLI Tool Repository Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    check_gh_cli
    check_templates
    check_gh_auth
    check_ssh_keys
    get_repo_details
    create_repository
    clone_repository
    setup_readme
    create_changelog
    create_dev_guide
    create_funding
    create_issue_templates
    create_dev_branch
    create_scripts
    commit_setup
    setup_branch_protection
    print_final_instructions
}

# Run main function
main
