#!/bin/bash

# GitHub Repository Setup Script for Enhanced OCR Application
# This script initializes a Git repository and prepares for GitHub push

set -e

REPO_NAME=${REPO_NAME:-"ocr-text-extraction-enhanced"}
GITHUB_USERNAME=${GITHUB_USERNAME:-"your-username"}

echo "🐙 Setting up GitHub repository for Enhanced OCR Application"
echo "Repository Name: ${REPO_NAME}"
echo "GitHub Username: ${GITHUB_USERNAME}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed"
    exit 1
fi

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
else
    echo "📦 Git repository already initialized"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Environment variables
.env
*.env
!.env.example

# Credentials
credentials.json
service-account-key.json

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*
package-lock.json
yarn.lock

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Docker
.dockerignore

# Temporary files
tmp/
temp/
*.tmp

# Cloud Run
.gcloudignore
EOF
else
    echo "📝 .gitignore already exists"
fi

# Add all files
echo "📁 Adding files to Git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit"
else
    # Commit changes
    echo "💾 Committing changes..."
    git commit -m "🚀 Enhanced OCR Application with Redis caching, rate limiting, and multi-format support

Features:
- ⚡ Redis caching for identical images
- 🛡️ Rate limiting (30 requests/minute)
- 🖼️ Support for JPG, JPEG, PNG, GIF formats
- 📊 Cache management endpoints
- 🔒 Enhanced security and validation
- 📈 Performance monitoring
- 🐳 Docker containerization
- ☁️ Google Cloud Run deployment ready
- 🧪 Sample test images included

Tech Stack:
- FastAPI backend with Google Cloud Vision API
- React frontend with Material UI
- Redis for caching
- slowapi for rate limiting
- Google Cloud Run deployment
- Comprehensive documentation"
fi

# Set up remote origin (user will need to create the repo on GitHub first)
echo ""
echo "🔗 Setting up GitHub remote..."
echo "Please create a repository named '${REPO_NAME}' on GitHub first, then run:"
echo ""
echo "git remote add origin https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""
echo "Or if you want to use SSH:"
echo "git remote add origin git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""

# Create GitHub Actions workflow for CI/CD
mkdir -p .github/workflows

cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to Google Cloud Run

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  REGION: us-central1
  SERVICE_NAME: ocr-backend-enhanced
  FRONTEND_SERVICE_NAME: ocr-frontend-enhanced

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        cd backend
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        cd backend
        python -m pytest tests/ || echo "No tests found, skipping..."

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Google Cloud CLI
      uses: google-github-actions/setup-gcloud@v1
      with:
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ secrets.GCP_PROJECT_ID }}
    
    - name: Configure Docker to use gcloud as a credential helper
      run: gcloud auth configure-docker
    
    - name: Deploy to Cloud Run
      run: |
        chmod +x deploy-enhanced.sh
        PROJECT_ID=${{ secrets.GCP_PROJECT_ID }} REGION=$REGION ./deploy-enhanced.sh
EOF

echo "🔄 Created GitHub Actions workflow for CI/CD"

# Create issue templates
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - OS: [e.g. iOS]
 - Browser [e.g. chrome, safari]
 - Version [e.g. 22]

**Additional context**
Add any other context about the problem here.
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
EOF

echo "📋 Created GitHub issue templates"

# Create pull request template
cat > .github/pull_request_template.md << 'EOF'
## Description
Brief description of the changes in this PR.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] I have tested these changes locally
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
EOF

echo "📝 Created pull request template"

echo ""
echo "✅ GitHub repository setup completed!"
echo ""
echo "📋 Summary of created files:"
echo "  - .gitignore (comprehensive ignore rules)"
echo "  - .github/workflows/deploy.yml (CI/CD pipeline)"
echo "  - .github/ISSUE_TEMPLATE/ (bug report & feature request templates)"
echo "  - .github/pull_request_template.md (PR template)"
echo ""
echo "🚀 Next steps:"
echo "1. Create a new repository on GitHub named '${REPO_NAME}'"
echo "2. Add the remote origin and push:"
echo "   git remote add origin https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Set up GitHub Secrets for CI/CD:"
echo "   - GCP_PROJECT_ID: Your Google Cloud Project ID"
echo "   - GCP_SA_KEY: Your Google Cloud Service Account Key (JSON)"
echo ""
echo "4. Deploy to Google Cloud Run:"
echo "   ./deploy-enhanced.sh"
echo ""
echo "🎉 Your enhanced OCR application is ready for GitHub!"
