#!/bin/bash

# Google Cloud Platform Setup Script for OCR Application
# This script sets up your GCP project for OCR deployment

set -e

echo "🚀 Setting up Google Cloud Platform for OCR Application"
echo ""

# Check if PROJECT_ID is provided
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID environment variable is required"
    echo "Usage: PROJECT_ID=your-project-id ./setup-gcp.sh"
    exit 1
fi

REGION=${REGION:-"us-central1"}

echo "📋 Configuration:"
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Authenticate with gcloud (if needed)
echo "🔐 Checking authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "Please authenticate with gcloud:"
    gcloud auth login
fi

# Set project
echo "📋 Setting project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
echo "  - Cloud Build API"
gcloud services enable cloudbuild.googleapis.com

echo "  - Cloud Run API"
gcloud services enable run.googleapis.com

echo "  - Cloud Vision API"
gcloud services enable vision.googleapis.com

echo "  - Container Registry API"
gcloud services enable containerregistry.googleapis.com

# Configure Docker for GCR
echo "🐳 Configuring Docker for Google Container Registry..."
gcloud auth configure-docker

# Create service account for local development (optional)
echo "🔑 Creating service account for local development..."
SERVICE_ACCOUNT_NAME="ocr-service-account"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Check if service account already exists
if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL &>/dev/null; then
    echo "  ℹ️  Service account already exists: $SERVICE_ACCOUNT_EMAIL"
else
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="OCR Service Account" \
        --description="Service account for OCR application"
    
    # Grant Vision API permissions
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/ml.admin"
    
    echo "  ✅ Service account created: $SERVICE_ACCOUNT_EMAIL"
fi

# Optionally create and download service account key for local development
read -p "🔑 Do you want to create a service account key for local development? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    KEY_FILE="credentials.json"
    gcloud iam service-accounts keys create $KEY_FILE \
        --iam-account=$SERVICE_ACCOUNT_EMAIL
    
    echo "  ✅ Service account key saved to: $KEY_FILE"
    echo "  📝 For local development, set: export GOOGLE_APPLICATION_CREDENTIALS=./$KEY_FILE"
fi

echo ""
echo "✅ Google Cloud Platform setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Deploy backend: PROJECT_ID=$PROJECT_ID ./deploy-backend.sh"
echo "2. Deploy frontend: PROJECT_ID=$PROJECT_ID BACKEND_URL=<backend-url> ./deploy-frontend.sh"
echo ""
echo "🔗 Useful links:"
echo "  - Cloud Console: https://console.cloud.google.com/run?project=$PROJECT_ID"
echo "  - Cloud Build: https://console.cloud.google.com/cloud-build?project=$PROJECT_ID"
echo "  - Vision API: https://console.cloud.google.com/apis/library/vision.googleapis.com?project=$PROJECT_ID"
