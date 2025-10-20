#!/bin/bash

# Google Cloud Run Deployment Script for OCR Backend
# This script deploys the OCR backend to Google Cloud Run

set -e

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-project-id"}
REGION=${REGION:-"us-central1"}
SERVICE_NAME="ocr-backend"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "🚀 Deploying OCR Backend to Google Cloud Run"
echo "Project ID: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Service Name: ${SERVICE_NAME}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
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
gcloud config set project ${PROJECT_ID}

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable vision.googleapis.com

# Build and push Docker image
echo "🏗️  Building Docker image..."
cd backend
docker build -t ${IMAGE_NAME} .

echo "📤 Pushing image to Google Container Registry..."
docker push ${IMAGE_NAME}

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME} \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --set-env-vars OCR_ENGINE=google \
    --memory 1Gi \
    --cpu 1 \
    --max-instances 10 \
    --timeout 300 \
    --port 8080

# Get service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region=${REGION} --format='value(status.url)')

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Backend URL: ${SERVICE_URL}"
echo "📚 API Documentation: ${SERVICE_URL}/docs"
echo "❤️  Health Check: ${SERVICE_URL}/api/health"
echo ""
echo "📝 Next steps:"
echo "1. Set up Google Cloud Vision API credentials"
echo "2. Update frontend VITE_API_BASE_URL to: ${SERVICE_URL}/api"
echo "3. Deploy frontend using deploy-frontend.sh"
