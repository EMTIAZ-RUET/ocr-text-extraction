#!/bin/bash

# Google Cloud Run Deployment Script for OCR Frontend
# This script deploys the OCR frontend to Google Cloud Run

set -e

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-project-id"}
REGION=${REGION:-"us-central1"}
SERVICE_NAME="ocr-frontend"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
BACKEND_URL=${BACKEND_URL:-"https://ocr-backend-xxxxx-uc.a.run.app"}

echo "🚀 Deploying OCR Frontend to Google Cloud Run"
echo "Project ID: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Service Name: ${SERVICE_NAME}"
echo "Backend URL: ${BACKEND_URL}"
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

# Set project
echo "📋 Setting project..."
gcloud config set project ${PROJECT_ID}

# Build and push Docker image
echo "🏗️  Building Docker image..."
cd frontend
docker build -t ${IMAGE_NAME} \
    --build-arg VITE_API_BASE_URL=${BACKEND_URL}/api .

echo "📤 Pushing image to Google Container Registry..."
docker push ${IMAGE_NAME}

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME} \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 5 \
    --port 80

# Get service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region=${REGION} --format='value(status.url)')

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Frontend URL: ${SERVICE_URL}"
echo ""
echo "🎉 Your OCR application is now live!"
echo "📱 Access your app at: ${SERVICE_URL}"
