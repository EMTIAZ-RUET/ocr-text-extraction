# Step-by-Step Google Cloud Run Deployment Guide

## 🎯 Complete Deployment Instructions

This guide will walk you through deploying your OCR application to Google Cloud Run from scratch.

## ⚡ Quick Start for Ubuntu 22.04 Users

If you have Ubuntu 22.04 and want to deploy immediately, run these commands:

```bash
# 1. Install prerequisites (if not already installed)
sudo apt-get update && sudo apt-get install google-cloud-cli docker.io docker-compose
sudo usermod -aG docker $USER && newgrp docker

# 2. Authenticate and setup
gcloud auth login
export PROJECT_ID="ocr-app-$(date +%s)"
gcloud projects create $PROJECT_ID --name="OCR Application"
gcloud config set project $PROJECT_ID

# 3. Navigate to project and deploy
cd /home/bs00728/Airwork
PROJECT_ID=$PROJECT_ID ./setup-gcp.sh
PROJECT_ID=$PROJECT_ID REGION=us-central1 ./deploy-backend.sh
BACKEND_URL=$(gcloud run services describe ocr-backend --region=us-central1 --format='value(status.url)')
PROJECT_ID=$PROJECT_ID REGION=us-central1 BACKEND_URL=$BACKEND_URL ./deploy-frontend.sh

# 4. Get your live app URL
FRONTEND_URL=$(gcloud run services describe ocr-frontend --region=us-central1 --format='value(status.url)')
echo "🎉 Your OCR app is live at: $FRONTEND_URL"
```

**⚠️ Important:** You must enable billing in Google Cloud Console before deployment works.

---

## 📋 Prerequisites

### 1. Create Google Cloud Account
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Accept terms and conditions
4. **Enable billing** (required for Cloud Run)

### 2. Install Required Tools

#### For Ubuntu 22.04 LTS (Recommended)

**Install Google Cloud CLI:**
```bash
# Add Google Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update and install
sudo apt-get update && sudo apt-get install google-cloud-cli
```

**Install Docker:**
```bash
# Update package index
sudo apt-get update

# Install Docker and Docker Compose
sudo apt-get install docker.io docker-compose

# Add your user to docker group (to run docker without sudo)
sudo usermod -aG docker $USER

# Apply group changes (restart terminal or run this)
newgrp docker
```

#### For Other Systems

**macOS:**
```bash
# Install Google Cloud CLI
brew install --cask google-cloud-sdk

# Install Docker
brew install docker
# Or download Docker Desktop from docker.com
```

**Windows:**
- Download Google Cloud CLI from: https://cloud.google.com/sdk/docs/install
- Download Docker Desktop from: https://docker.com

#### Verify Installations
```bash
# Check if tools are installed correctly
gcloud --version
docker --version

# Test docker without sudo (Ubuntu only)
docker run hello-world

# If docker test fails, restart your terminal or run:
# newgrp docker
```

## 🚀 Step 1: Setup Google Cloud Project

### 1.1 Authenticate with Google Cloud
```bash
# First, authenticate with your Google account
gcloud auth login
# This will open a browser window for authentication
```

### 1.2 Create New Project
```bash
# Set your project ID (must be globally unique)
export PROJECT_ID="ocr-app-$(date +%s)"
echo "Your Project ID: $PROJECT_ID"

# Create the project
gcloud projects create $PROJECT_ID --name="OCR Application"

# Set as default project
gcloud config set project $PROJECT_ID

# Verify project is set
gcloud config get-value project
```

### 1.3 Enable Billing
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `$PROJECT_ID`
3. Go to **Billing** → **Link a billing account**
4. Create or select existing billing account

### 1.4 Run Setup Script
```bash
# Navigate to your project directory
cd /home/bs00728/Airwork

# Make setup script executable
chmod +x setup-gcp.sh

# Run setup (this enables APIs and creates service accounts)
PROJECT_ID=$PROJECT_ID ./setup-gcp.sh
```

## 🚀 Step 2: Deploy Backend to Cloud Run

### 2.1 Authenticate Docker with Google Cloud
```bash
# Configure Docker to use gcloud as credential helper
gcloud auth configure-docker
```

### 2.2 Deploy Backend
```bash
# Make deployment script executable
chmod +x deploy-backend.sh

# Deploy backend (this will take 3-5 minutes)
PROJECT_ID=$PROJECT_ID REGION=us-central1 ./deploy-backend.sh
```

**What happens during backend deployment:**
1. Builds Docker image with your FastAPI app
2. Pushes image to Google Container Registry
3. Deploys to Cloud Run with optimized settings
4. Configures auto-scaling (0-10 instances)
5. Sets up health checks

### 2.3 Get Backend URL
```bash
# Get your backend URL
BACKEND_URL=$(gcloud run services describe ocr-backend --region=us-central1 --format='value(status.url)')
echo "Backend URL: $BACKEND_URL"

# Test backend health
curl $BACKEND_URL/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "ocr_engine": "google"
}
```

## 🚀 Step 3: Deploy Frontend to Cloud Run

### 3.1 Deploy Frontend
```bash
# Make deployment script executable
chmod +x deploy-frontend.sh

# Deploy frontend with backend URL
PROJECT_ID=$PROJECT_ID REGION=us-central1 BACKEND_URL=$BACKEND_URL ./deploy-frontend.sh
```

**What happens during frontend deployment:**
1. Builds React app with your backend URL
2. Creates optimized production build
3. Packages with Nginx for serving
4. Deploys to Cloud Run
5. Configures caching and security headers

### 3.2 Get Frontend URL
```bash
# Get your frontend URL
FRONTEND_URL=$(gcloud run services describe ocr-frontend --region=us-central1 --format='value(status.url)')
echo "Frontend URL: $FRONTEND_URL"
echo "🎉 Your OCR app is live at: $FRONTEND_URL"
```

## 🌐 Step 4: Access Your Application

### 4.1 Open Your Application
1. Copy the frontend URL from the previous step
2. Open it in your web browser
3. You should see your OCR application interface

### 4.2 Test Your Application
1. **Upload an image**: Drag and drop a JPG/JPEG file
2. **Click "Extract Text"**: Wait for processing
3. **View results**: See extracted text with confidence score
4. **Copy text**: Use the copy button to copy extracted text

## 📊 Step 5: Monitor Your Deployment

### 5.1 View in Google Cloud Console

#### Access Cloud Run Services
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `$PROJECT_ID`
3. Navigate to **Cloud Run**
4. You'll see two services:
   - `ocr-backend` - Your FastAPI backend
   - `ocr-frontend` - Your React frontend

#### View Service Details
Click on each service to see:
- **Service URL**: Public endpoint
- **Metrics**: Request count, latency, errors
- **Logs**: Application logs
- **Revisions**: Deployment history
- **Configuration**: Memory, CPU, environment variables

### 5.2 View Logs
```bash
# Backend logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=ocr-backend" --limit=50

# Frontend logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=ocr-frontend" --limit=50

# Real-time logs
gcloud logs tail "resource.type=cloud_run_revision"
```

### 5.3 Monitor Usage
```bash
# Check service status
gcloud run services list --region=us-central1

# Get service details
gcloud run services describe ocr-backend --region=us-central1
gcloud run services describe ocr-frontend --region=us-central1
```

## 🔧 Step 6: Test API Directly

### 6.1 Test Health Endpoint
```bash
# Test backend health
curl $BACKEND_URL/api/health

# Expected response:
# {"status":"healthy","ocr_engine":"google"}
```

### 6.2 Test OCR Endpoint
```bash
# Test with a sample image (replace with your image path)
curl -X POST "$BACKEND_URL/api/extract-text" \
  -F "file=@/path/to/your/image.jpg" \
  -H "Content-Type: multipart/form-data"

# Example with a test image:
# Download a test image first
wget -O test-image.jpg "https://via.placeholder.com/400x200/000000/FFFFFF?text=Hello+World"
curl -X POST "$BACKEND_URL/api/extract-text" \
  -F "file=@test-image.jpg"
```

### 6.3 View API Documentation
```bash
# Open API documentation in browser
echo "API Docs: $BACKEND_URL/docs"
# Or visit the URL directly in your browser
```

## 💰 Step 7: Understand Costs

### Current Configuration Costs
- **Cloud Run**: Pay per request (2M requests/month free)
- **Google Vision API**: 1,000 requests/month free, then $1.50/1,000
- **Container Registry**: Storage costs (~$0.10/GB/month)

### Example Monthly Costs
- **1,000 images**: $0 (free tier)
- **10,000 images**: ~$15
- **100,000 images**: ~$150

### Monitor Costs
1. Go to **Billing** in Google Cloud Console
2. View current usage and costs
3. Set up billing alerts

## 🛠️ Step 8: Manage Your Application

### 8.1 Update Your Application
```bash
# To redeploy after code changes
./deploy-backend.sh    # Redeploy backend
./deploy-frontend.sh   # Redeploy frontend
```

### 8.2 Scale Your Application
```bash
# Update backend scaling
gcloud run services update ocr-backend \
  --region=us-central1 \
  --min-instances=1 \
  --max-instances=20 \
  --concurrency=80

# Update frontend scaling
gcloud run services update ocr-frontend \
  --region=us-central1 \
  --min-instances=0 \
  --max-instances=10
```

### 8.3 Configure Custom Domain (Optional)
```bash
# Map custom domain
gcloud run domain-mappings create \
  --service=ocr-frontend \
  --domain=your-domain.com \
  --region=us-central1
```

## 🔒 Step 9: Security & Production Settings

### 9.1 Restrict Access (Optional)
```bash
# Remove public access (require authentication)
gcloud run services remove-iam-policy-binding ocr-frontend \
  --region=us-central1 \
  --member="allUsers" \
  --role="roles/run.invoker"
```

### 9.2 Set Environment Variables
```bash
# Update backend environment variables
gcloud run services update ocr-backend \
  --region=us-central1 \
  --set-env-vars="LOG_LEVEL=WARNING"
```

## 🆘 Troubleshooting

### Common Issues for Ubuntu 22.04

#### 1. "Permission denied" errors
```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login

# For docker permission issues
sudo usermod -aG docker $USER
newgrp docker
# Or restart your terminal
```

#### 2. "Billing not enabled" errors
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **Billing** → **Link a billing account**
4. Add a payment method (required even for free tier)
5. Retry deployment

#### 3. "API not enabled" errors
```bash
# Enable required APIs manually
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable vision.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Or run the setup script again
./setup-gcp.sh
```

#### 4. "Docker not found" or "Image not found" errors
```bash
# Check docker installation
docker --version
docker run hello-world

# If docker fails, reinstall
sudo apt-get remove docker.io
sudo apt-get install docker.io
sudo usermod -aG docker $USER
newgrp docker

# Check if image was pushed
gcloud container images list --repository=gcr.io/$PROJECT_ID

# Rebuild and push manually if needed
cd backend
docker build -t gcr.io/$PROJECT_ID/ocr-backend .
docker push gcr.io/$PROJECT_ID/ocr-backend
```

#### 5. "gcloud command not found"
```bash
# Reinstall Google Cloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud --version

# Or use apt method
sudo apt-get update
sudo apt-get install google-cloud-cli
```

#### 6. Frontend can't connect to backend
```bash
# Check if both services are running
gcloud run services list --region=us-central1

# Check backend URL is correct
echo $BACKEND_URL
curl $BACKEND_URL/api/health

# Redeploy frontend with correct backend URL
BACKEND_URL=$(gcloud run services describe ocr-backend --region=us-central1 --format='value(status.url)')
PROJECT_ID=$PROJECT_ID REGION=us-central1 BACKEND_URL=$BACKEND_URL ./deploy-frontend.sh
```

### Get Help
```bash
# Check service status
gcloud run services list

# View detailed service info
gcloud run services describe ocr-backend --region=us-central1

# Check recent deployments
gcloud run revisions list --service=ocr-backend --region=us-central1
```

## 📱 Step 10: Access Your Live Application

### Your Application URLs
After successful deployment, you'll have:

1. **Frontend (Main App)**: `https://ocr-frontend-xxxxx-uc.a.run.app`
   - This is your main application URL
   - Share this with users
   - Responsive design works on mobile/desktop

2. **Backend API**: `https://ocr-backend-xxxxx-uc.a.run.app`
   - API endpoints for developers
   - Documentation at `/docs`
   - Health check at `/api/health`

### Using Your Application
1. **Open the frontend URL** in any web browser
2. **Upload an image**: Drag & drop or click to select JPG/JPEG
3. **Extract text**: Click the "Extract Text" button
4. **View results**: See extracted text, confidence score, processing time
5. **Copy text**: Use the copy button to copy extracted text

## 🎉 Congratulations!

Your OCR application is now live on Google Cloud Run with:
- ✅ **Auto-scaling**: Handles 0 to thousands of users
- ✅ **Global availability**: Accessible worldwide
- ✅ **High accuracy**: Google Cloud Vision API
- ✅ **Production-ready**: Optimized for performance and security
- ✅ **Cost-effective**: Pay only for what you use

### Next Steps
1. **Share your app**: Send the frontend URL to users
2. **Monitor usage**: Check Google Cloud Console regularly
3. **Set up alerts**: Configure billing and error alerts
4. **Customize**: Modify the code and redeploy as needed

**Your OCR application is now running in production! 🚀**
