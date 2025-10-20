#!/bin/bash

# Enhanced Google Cloud Run Deployment Script for OCR Backend with Redis
# This script deploys the OCR backend with all enhancements to Google Cloud Run

set -e

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-project-id"}
REGION=${REGION:-"us-central1"}
SERVICE_NAME="ocr-backend-enhanced"
FRONTEND_SERVICE_NAME="ocr-frontend-enhanced"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
FRONTEND_IMAGE_NAME="gcr.io/${PROJECT_ID}/${FRONTEND_SERVICE_NAME}"

echo "🚀 Deploying Enhanced OCR Application to Google Cloud Run"
echo "Project ID: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Backend Service: ${SERVICE_NAME}"
echo "Frontend Service: ${FRONTEND_SERVICE_NAME}"
echo ""

# Check prerequisites
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    exit 1
fi

# Authenticate and set project
echo "🔐 Setting up authentication..."
gcloud config set project ${PROJECT_ID}

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable vision.googleapis.com
gcloud services enable redis.googleapis.com

# Create Redis instance for caching (if it doesn't exist)
echo "🗄️  Setting up Redis instance..."
if ! gcloud redis instances describe redis-cache --region=${REGION} &>/dev/null; then
    echo "Creating new Redis instance..."
    gcloud redis instances create redis-cache \
        --size=1 \
        --region=${REGION} \
        --redis-version=redis_6_x \
        --tier=basic \
        --async
    
    echo "⏳ Waiting for Redis instance to be ready..."
    gcloud redis instances describe redis-cache --region=${REGION} --format="value(state)" | grep -q "READY" || {
        echo "Waiting for Redis instance creation..."
        sleep 30
    }
else
    echo "Redis instance already exists"
fi

# Get Redis IP
REDIS_IP=$(gcloud redis instances describe redis-cache --region=${REGION} --format="value(host)")
REDIS_URL="redis://${REDIS_IP}:6379"

echo "Redis URL: ${REDIS_URL}"

# Build and deploy backend
echo "🏗️  Building backend Docker image..."
cd backend
docker build -t ${IMAGE_NAME} .

echo "📤 Pushing backend image..."
docker push ${IMAGE_NAME}

echo "🚀 Deploying backend to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME} \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --set-env-vars "OCR_ENGINE=google,REDIS_URL=${REDIS_URL},RATE_LIMIT_REQUESTS=30,CACHE_TTL_SECONDS=3600" \
    --memory 2Gi \
    --cpu 2 \
    --max-instances 20 \
    --timeout 300 \
    --port 8080 \
    --vpc-connector projects/${PROJECT_ID}/locations/${REGION}/connectors/redis-connector || {
        echo "VPC connector not found, deploying without Redis connection..."
        gcloud run deploy ${SERVICE_NAME} \
            --image ${IMAGE_NAME} \
            --platform managed \
            --region ${REGION} \
            --allow-unauthenticated \
            --set-env-vars "OCR_ENGINE=google" \
            --memory 2Gi \
            --cpu 2 \
            --max-instances 20 \
            --timeout 300 \
            --port 8080
    }

# Get backend URL
BACKEND_URL=$(gcloud run services describe ${SERVICE_NAME} --region=${REGION} --format='value(status.url)')

echo "✅ Backend deployed successfully!"
echo "🌐 Backend URL: ${BACKEND_URL}"

# Build and deploy frontend
echo "🏗️  Building frontend Docker image..."
cd ../frontend
docker build -t ${FRONTEND_IMAGE_NAME} \
    --build-arg VITE_API_BASE_URL=${BACKEND_URL}/api .

echo "📤 Pushing frontend image..."
docker push ${FRONTEND_IMAGE_NAME}

echo "🚀 Deploying frontend to Cloud Run..."
gcloud run deploy ${FRONTEND_SERVICE_NAME} \
    --image ${FRONTEND_IMAGE_NAME} \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --port 80

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe ${FRONTEND_SERVICE_NAME} --region=${REGION} --format='value(status.url)')

echo ""
echo "🎉 Enhanced OCR Application Deployed Successfully!"
echo "=================================="
echo "🌐 Frontend URL: ${FRONTEND_URL}"
echo "🔧 Backend URL: ${BACKEND_URL}"
echo "📚 API Docs: ${BACKEND_URL}/docs"
echo "❤️  Health Check: ${BACKEND_URL}/api/health"
echo "📊 Cache Stats: ${BACKEND_URL}/api/cache/stats"
echo ""
echo "🚀 New Features:"
echo "  ✅ Rate limiting (30 requests/minute)"
echo "  ✅ Redis caching for faster responses"
echo "  ✅ Support for JPG, PNG, GIF formats"
echo "  ✅ Cache management endpoints"
echo "  ✅ Enhanced error handling"
echo ""
echo "🧪 Test your API:"
echo "curl -X POST \"${BACKEND_URL}/api/extract-text\" -F \"file=@sample-images/simple-text.jpg\""
echo ""
echo "📝 Next steps:"
echo "1. Test the application with sample images"
echo "2. Monitor performance in Cloud Console"
echo "3. Set up custom domain (optional)"
echo "4. Configure monitoring and alerts"
