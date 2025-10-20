# Google Cloud Run Deployment Guide

This guide provides step-by-step instructions to deploy the OCR application to Google Cloud Run using Google Cloud Vision API.

## 🚀 Quick Deployment (5 minutes)

### Prerequisites

1. **Google Cloud Account** with billing enabled
2. **Google Cloud CLI** installed ([Install Guide](https://cloud.google.com/sdk/docs/install))
3. **Docker** installed ([Install Guide](https://docs.docker.com/get-docker/))
4. **Project ID** - Create or use existing GCP project

### Step 1: Setup Google Cloud Project

```bash
# Set your project ID
export PROJECT_ID="your-project-id"
export REGION="us-central1"

# Authenticate with Google Cloud
gcloud auth login

# Set the project
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable vision.googleapis.com
```

### Step 2: Deploy Backend

```bash
# Make deployment script executable
chmod +x deploy-backend.sh

# Deploy backend to Cloud Run
PROJECT_ID=$PROJECT_ID REGION=$REGION ./deploy-backend.sh
```

### Step 3: Deploy Frontend

```bash
# Get backend URL from previous step
export BACKEND_URL="https://ocr-backend-xxxxx-uc.a.run.app"

# Deploy frontend
PROJECT_ID=$PROJECT_ID REGION=$REGION BACKEND_URL=$BACKEND_URL ./deploy-frontend.sh
```

### Step 4: Test Your Deployment

Your application will be available at the frontend URL provided after deployment.

---

## 📋 Detailed Setup Instructions

### 1. Google Cloud Vision API Setup

The application uses Google Cloud Vision API for OCR processing. Authentication is handled automatically when deployed to Cloud Run.

#### For Local Testing (Optional)

If you want to test locally with Google Cloud Vision:

```bash
# Create service account
gcloud iam service-accounts create ocr-service-account \
    --display-name="OCR Service Account"

# Grant Vision API permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:ocr-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/vision.admin"

# Create and download key
gcloud iam service-accounts keys create credentials.json \
    --iam-account=ocr-service-account@$PROJECT_ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="./credentials.json"
```

### 2. Manual Deployment Steps

#### Backend Deployment

```bash
# Navigate to backend directory
cd backend

# Build Docker image
docker build -t gcr.io/$PROJECT_ID/ocr-backend .

# Push to Google Container Registry
docker push gcr.io/$PROJECT_ID/ocr-backend

# Deploy to Cloud Run
gcloud run deploy ocr-backend \
    --image gcr.io/$PROJECT_ID/ocr-backend \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --set-env-vars OCR_ENGINE=google \
    --memory 1Gi \
    --cpu 1 \
    --max-instances 10 \
    --timeout 300 \
    --port 8080
```

#### Frontend Deployment

```bash
# Navigate to frontend directory
cd ../frontend

# Get backend URL
BACKEND_URL=$(gcloud run services describe ocr-backend --region=$REGION --format='value(status.url)')

# Build Docker image with backend URL
docker build -t gcr.io/$PROJECT_ID/ocr-frontend \
    --build-arg VITE_API_BASE_URL=$BACKEND_URL/api .

# Push to Google Container Registry
docker push gcr.io/$PROJECT_ID/ocr-frontend

# Deploy to Cloud Run
gcloud run deploy ocr-frontend \
    --image gcr.io/$PROJECT_ID/ocr-frontend \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 5 \
    --port 80
```

### 3. Environment Configuration

#### Backend Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OCR_ENGINE` | OCR engine to use | `google` |
| `LOG_LEVEL` | Logging level | `INFO` |
| `PORT` | Server port | `8080` |

#### Frontend Build Arguments

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | Backend API URL | `https://backend-url/api` |

---

## 🔧 Configuration Options

### Cloud Run Service Configuration

#### Backend Service
- **Memory**: 1Gi (recommended for image processing)
- **CPU**: 1 vCPU
- **Max Instances**: 10 (adjust based on expected load)
- **Timeout**: 300 seconds (for large image processing)
- **Port**: 8080

#### Frontend Service
- **Memory**: 512Mi (sufficient for static serving)
- **CPU**: 1 vCPU
- **Max Instances**: 5
- **Port**: 80

### Custom Domain (Optional)

To use a custom domain:

```bash
# Map domain to Cloud Run service
gcloud run domain-mappings create \
    --service ocr-frontend \
    --domain your-domain.com \
    --region $REGION
```

---

## 💰 Cost Estimation

### Google Cloud Run Costs
- **Backend**: ~$0.10 per 1,000 requests
- **Frontend**: ~$0.01 per 1,000 requests
- **Free Tier**: 2 million requests/month

### Google Cloud Vision API Costs
- **First 1,000 units/month**: Free
- **Additional**: $1.50 per 1,000 images

### Monthly Cost Examples
- **Low usage** (1K images): $0
- **Medium usage** (10K images): ~$15
- **High usage** (100K images): ~$150

---

## 🔍 Monitoring and Logging

### View Logs

```bash
# Backend logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=ocr-backend" --limit 50

# Frontend logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=ocr-frontend" --limit 50
```

### Monitoring Dashboard

Access Cloud Run monitoring in the Google Cloud Console:
1. Go to Cloud Run
2. Click on your service
3. View metrics, logs, and performance data

---

## 🛠️ Troubleshooting

### Common Issues

#### 1. "Permission denied" errors
```bash
# Ensure you're authenticated
gcloud auth login
gcloud auth application-default login
```

#### 2. "API not enabled" errors
```bash
# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable vision.googleapis.com
```

#### 3. "Image not found" errors
```bash
# Verify image was pushed
gcloud container images list --repository=gcr.io/$PROJECT_ID
```

#### 4. Frontend can't connect to backend
- Check CORS configuration in backend
- Verify VITE_API_BASE_URL is correct
- Ensure backend service allows unauthenticated requests

### Debug Commands

```bash
# Check service status
gcloud run services describe ocr-backend --region=$REGION
gcloud run services describe ocr-frontend --region=$REGION

# Test backend health
curl https://your-backend-url/api/health

# View recent logs
gcloud logs tail "resource.type=cloud_run_revision"
```

---

## 🔄 CI/CD with Cloud Build

### Automatic Deployment

Set up automatic deployment using Cloud Build triggers:

```bash
# Create build trigger for backend
gcloud builds triggers create github \
    --repo-name=your-repo \
    --repo-owner=your-username \
    --branch-pattern="^main$" \
    --build-config=backend/cloudbuild.yaml

# Create build trigger for frontend
gcloud builds triggers create github \
    --repo-name=your-repo \
    --repo-owner=your-username \
    --branch-pattern="^main$" \
    --build-config=frontend/cloudbuild.yaml
```

### Manual Build

```bash
# Build backend
gcloud builds submit backend/ --config=backend/cloudbuild.yaml

# Build frontend
gcloud builds submit frontend/ --config=frontend/cloudbuild.yaml
```

---

## 🔒 Security Best Practices

### 1. Service Account Permissions
- Use minimal required permissions
- Create dedicated service accounts for each service

### 2. Network Security
- Configure VPC if needed
- Use Cloud Armor for DDoS protection

### 3. Authentication
- Enable IAM authentication for production
- Use Identity-Aware Proxy (IAP) for additional security

### 4. Secrets Management
- Use Secret Manager for sensitive data
- Never hardcode credentials

---

## 📈 Scaling and Performance

### Auto-scaling Configuration

```bash
# Update scaling settings
gcloud run services update ocr-backend \
    --region=$REGION \
    --min-instances=1 \
    --max-instances=20 \
    --concurrency=80
```

### Performance Optimization

1. **Image Optimization**: Use multi-stage Docker builds
2. **Caching**: Implement Redis for frequently accessed data
3. **CDN**: Use Cloud CDN for static assets
4. **Load Balancing**: Configure load balancer for high availability

---

## 🎯 Production Checklist

- [ ] Enable billing alerts
- [ ] Set up monitoring and alerting
- [ ] Configure custom domain
- [ ] Implement proper logging
- [ ] Set up backup and disaster recovery
- [ ] Configure security policies
- [ ] Test auto-scaling behavior
- [ ] Set up CI/CD pipeline
- [ ] Document operational procedures
- [ ] Train team on Cloud Run operations

---

## 📞 Support

### Google Cloud Support
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Vision API Documentation](https://cloud.google.com/vision/docs)
- [Google Cloud Support](https://cloud.google.com/support)

### Application Support
- Check logs using `gcloud logs` commands
- Review monitoring dashboards
- Test API endpoints directly
- Verify environment variables

---

**🎉 Your OCR application is now running on Google Cloud Run with enterprise-grade scalability and reliability!**
