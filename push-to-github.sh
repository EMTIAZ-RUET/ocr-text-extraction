#!/bin/bash

echo "🚀 GitHub Repository Setup and Push Script"
echo "=========================================="

# Check if repository exists by trying to push
echo "📤 Attempting to push to GitHub..."
if git push -u origin main; then
    echo "✅ Successfully pushed to existing repository!"
    echo "🌐 Repository URL: https://github.com/bs00728/ocr-text-extraction"
else
    echo "❌ Repository doesn't exist yet."
    echo ""
    echo "📋 Please create the repository manually:"
    echo "1. Go to https://github.com/bs00728"
    echo "2. Click '+ New repository'"
    echo "3. Repository name: ocr-text-extraction"
    echo "4. Description: OCR API for JPG image text extraction using Google Cloud Vision API"
    echo "5. Make it Public"
    echo "6. Don't initialize with README, .gitignore, or license"
    echo "7. Click 'Create repository'"
    echo ""
    echo "Then run this script again to push the code."
fi

echo ""
echo "📊 Current project structure:"
find . -type f -name "*.py" -o -name "*.js" -o -name "*.jsx" -o -name "*.md" -o -name "*.sh" -o -name "*.jpg" | head -15

echo ""
echo "✅ Clean codebase ready:"
echo "  - FastAPI backend with Google Cloud Vision OCR"
echo "  - React frontend"
echo "  - Sample test image"
echo "  - Deployment scripts"
echo "  - Minimal documentation"
