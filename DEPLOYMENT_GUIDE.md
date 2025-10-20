# 🚀 Enhanced OCR Application - Complete Deployment Guide

This guide provides step-by-step instructions to deploy the enhanced OCR application with all new features to Google Cloud Run.

## 🆕 **What's New in Enhanced Edition**

### ⚡ **Performance Enhancements**
- **Redis Caching**: Instant responses for identical images (up to 90% faster)
- **Rate Limiting**: 30 requests/minute protection against abuse
- **Multi-Format Support**: JPG, JPEG, PNG, GIF image processing

### 📊 **New API Endpoints**
- `GET /api/cache/stats` - Cache performance metrics
- `DELETE /api/cache/clear` - Clear cached results
- Enhanced `GET /api/health` - Detailed system status

### 🔒 **Security & Reliability**
- Advanced input validation for multiple formats
- Comprehensive error handling and logging
- Rate limiting with slowapi
- Enhanced CORS configuration

---

## 🚀 **Quick Deployment (5 minutes)**

### Prerequisites
1. **Google Cloud Account** with billing enabled
2. **Google Cloud CLI** installed
3. **Docker** installed
4. **Git** for version control

### Step 1: Clone and Setup
```bash
# Clone the repository (after pushing to GitHub)
git clone https://github.com/your-username/ocr-text-extraction-enhanced.git
cd ocr-text-extraction-enhanced

# Set your Google Cloud project
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"
```

### Step 2: Deploy Enhanced Application
```bash
# Make deployment script executable
chmod +x deploy-enhanced.sh

# Deploy with all enhancements
PROJECT_ID=$PROJECT_ID REGION=$REGION ./deploy-enhanced.sh
```

### Step 3: Test Your Deployment
```bash
# Test with sample image
curl -X POST "https://your-backend-url/api/extract-text" \
  -F "file=@sample-images/simple-text.jpg"

# Check cache stats
curl "https://your-backend-url/api/cache/stats"

# Health check
curl "https://your-backend-url/api/health"
```

---

## 📋 **Detailed Setup Instructions**

### 1. **Google Cloud Project Setup**

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set project and region
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable vision.googleapis.com
gcloud services enable redis.googleapis.com
```

### 2. **Redis Cache Setup**

The deployment script automatically creates a Redis instance for caching:

```bash
# Redis instance will be created with:
# - Name: redis-cache
# - Size: 1GB
# - Version: Redis 6.x
# - Tier: Basic (suitable for development/testing)
```

For production, consider upgrading to Standard tier:
```bash
gcloud redis instances create redis-cache-prod \
  --size=5 \
  --region=$REGION \
  --redis-version=redis_6_x \
  --tier=standard_ha \
  --replica-count=1
```

### 3. **Environment Variables**

The enhanced application uses these environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `OCR_ENGINE` | OCR engine to use | `google` |
| `REDIS_URL` | Redis connection URL | `redis://localhost:6379` |
| `RATE_LIMIT_REQUESTS` | Requests per minute limit | `30` |
| `CACHE_TTL_SECONDS` | Cache expiration time | `3600` (1 hour) |
| `LOG_LEVEL` | Logging level | `INFO` |

### 4. **Manual Deployment Steps**

If you prefer manual deployment:

#### Backend Deployment
```bash
cd backend

# Build Docker image
docker build -t gcr.io/$PROJECT_ID/ocr-backend-enhanced .

# Push to Google Container Registry
docker push gcr.io/$PROJECT_ID/ocr-backend-enhanced

# Get Redis IP
REDIS_IP=$(gcloud redis instances describe redis-cache --region=$REGION --format="value(host)")

# Deploy to Cloud Run
gcloud run deploy ocr-backend-enhanced \
  --image gcr.io/$PROJECT_ID/ocr-backend-enhanced \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars "OCR_ENGINE=google,REDIS_URL=redis://${REDIS_IP}:6379,RATE_LIMIT_REQUESTS=30" \
  --memory 2Gi \
  --cpu 2 \
  --max-instances 20 \
  --timeout 300
```

#### Frontend Deployment
```bash
cd ../frontend

# Get backend URL
BACKEND_URL=$(gcloud run services describe ocr-backend-enhanced --region=$REGION --format='value(status.url)')

# Build with backend URL
docker build -t gcr.io/$PROJECT_ID/ocr-frontend-enhanced \
  --build-arg VITE_API_BASE_URL=$BACKEND_URL/api .

# Push and deploy
docker push gcr.io/$PROJECT_ID/ocr-frontend-enhanced

gcloud run deploy ocr-frontend-enhanced \
  --image gcr.io/$PROJECT_ID/ocr-frontend-enhanced \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 512Mi \
  --max-instances 10
```

---

## 🧪 **Testing the Enhanced Features**

### 1. **Test Multi-Format Support**
```bash
# Test JPG
curl -X POST "$BACKEND_URL/api/extract-text" -F "file=@sample-images/simple-text.jpg"

# Test PNG
curl -X POST "$BACKEND_URL/api/extract-text" -F "file=@sample-images/business-card.png"
```

### 2. **Test Caching Performance**
```bash
# First request (will be cached)
time curl -X POST "$BACKEND_URL/api/extract-text" -F "file=@sample-images/invoice-sample.jpg"

# Second request (should be much faster from cache)
time curl -X POST "$BACKEND_URL/api/extract-text" -F "file=@sample-images/invoice-sample.jpg"

# Check cache statistics
curl "$BACKEND_URL/api/cache/stats"
```

### 3. **Test Rate Limiting**
```bash
# Send multiple requests quickly (should get rate limited after 30)
for i in {1..35}; do
  curl -X POST "$BACKEND_URL/api/extract-text" -F "file=@sample-images/simple-text.jpg"
  echo "Request $i completed"
done
```

### 4. **Test Cache Management**
```bash
# Clear cache
curl -X DELETE "$BACKEND_URL/api/cache/clear"

# Verify cache is empty
curl "$BACKEND_URL/api/cache/stats"
```

---

## 📊 **Performance Monitoring**

### 1. **Cloud Run Metrics**
Monitor your application in Google Cloud Console:
- Go to Cloud Run → Select your service
- View metrics for requests, latency, memory usage
- Set up alerts for high error rates or latency

### 2. **Redis Monitoring**
```bash
# Check Redis instance status
gcloud redis instances describe redis-cache --region=$REGION

# View Redis metrics in Cloud Console
# Go to Memorystore → Redis → Select instance → Monitoring
```

### 3. **Application Logs**
```bash
# View backend logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=ocr-backend-enhanced" --limit 50

# View frontend logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=ocr-frontend-enhanced" --limit 50
```

---

## 🔧 **Configuration Tuning**

### 1. **Performance Optimization**

For high-traffic scenarios:
```bash
# Update backend with more resources
gcloud run services update ocr-backend-enhanced \
  --region=$REGION \
  --memory=4Gi \
  --cpu=4 \
  --max-instances=50 \
  --concurrency=100
```

### 2. **Cache Configuration**

Adjust cache settings:
```bash
# Longer cache TTL for better performance
gcloud run services update ocr-backend-enhanced \
  --region=$REGION \
  --set-env-vars="CACHE_TTL_SECONDS=7200"

# More aggressive rate limiting
gcloud run services update ocr-backend-enhanced \
  --region=$REGION \
  --set-env-vars="RATE_LIMIT_REQUESTS=10"
```

### 3. **Redis Scaling**

For production workloads:
```bash
# Upgrade to Standard tier with high availability
gcloud redis instances create redis-cache-prod \
  --size=10 \
  --region=$REGION \
  --tier=standard_ha \
  --replica-count=1 \
  --redis-version=redis_6_x
```

---

## 🛠️ **Troubleshooting**

### Common Issues

#### 1. **Redis Connection Failed**
```bash
# Check Redis instance status
gcloud redis instances describe redis-cache --region=$REGION

# Verify VPC connector (if using)
gcloud compute networks vpc-access connectors list --region=$REGION
```

#### 2. **Rate Limiting Too Aggressive**
```bash
# Increase rate limit
gcloud run services update ocr-backend-enhanced \
  --set-env-vars="RATE_LIMIT_REQUESTS=60"
```

#### 3. **Cache Not Working**
- Check Redis connectivity in application logs
- Verify REDIS_URL environment variable
- Test Redis instance directly

#### 4. **High Memory Usage**
```bash
# Increase memory allocation
gcloud run services update ocr-backend-enhanced \
  --memory=4Gi
```

### Debug Commands
```bash
# Check service status
gcloud run services describe ocr-backend-enhanced --region=$REGION

# View recent logs with errors
gcloud logs read "resource.type=cloud_run_revision AND severity>=ERROR" --limit 20

# Test Redis connectivity
gcloud redis instances describe redis-cache --region=$REGION --format="value(host,port)"
```

---

## 🔒 **Security Best Practices**

### 1. **Production Security**
- Restrict CORS origins to your domain
- Enable Cloud Armor for DDoS protection
- Use Identity-Aware Proxy (IAP) for authentication
- Implement API key authentication

### 2. **Environment Security**
```bash
# Use Secret Manager for sensitive data
gcloud secrets create redis-password --data-file=redis-password.txt

# Update service to use secrets
gcloud run services update ocr-backend-enhanced \
  --set-env-vars="REDIS_PASSWORD_SECRET=projects/$PROJECT_ID/secrets/redis-password/versions/latest"
```

### 3. **Network Security**
- Use VPC connectors for Redis access
- Configure firewall rules
- Enable private Google access

---

## 💰 **Cost Optimization**

### 1. **Resource Right-Sizing**
- Start with minimal resources and scale up based on usage
- Use Cloud Run's automatic scaling
- Monitor and adjust based on metrics

### 2. **Redis Cost Management**
- Use Basic tier for development
- Upgrade to Standard only when needed
- Monitor memory usage and adjust size

### 3. **Expected Costs**
- **Cloud Run**: ~$0.10 per 1,000 requests
- **Redis Basic 1GB**: ~$30/month
- **Vision API**: $1.50 per 1,000 images (after free tier)

---

## 🎯 **Production Checklist**

- [ ] Redis instance created and accessible
- [ ] Environment variables configured
- [ ] Rate limiting tested and tuned
- [ ] Cache performance verified
- [ ] Monitoring and alerting set up
- [ ] Security policies implemented
- [ ] Backup and disaster recovery planned
- [ ] Documentation updated
- [ ] Team trained on new features
- [ ] Performance benchmarks established

---

## 🚀 **Next Steps**

1. **Monitor Performance**: Set up dashboards and alerts
2. **Scale Resources**: Adjust based on traffic patterns
3. **Add Features**: Consider batch processing, webhooks
4. **Optimize Costs**: Right-size resources based on usage
5. **Enhance Security**: Add authentication and authorization

---

**🎉 Your enhanced OCR application is now running on Google Cloud Run with enterprise-grade performance, caching, and security features!**

For support or questions, check the application logs or refer to the troubleshooting section above.
