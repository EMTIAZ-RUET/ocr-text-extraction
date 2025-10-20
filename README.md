# OCR Image Text Extraction System - Enhanced Edition

A complete, production-ready full-stack OCR (Optical Character Recognition) system that extracts text from JPG/JPEG/PNG/GIF images. Built with FastAPI backend and React frontend, using Google Cloud Vision API for high-accuracy text extraction. Features Redis caching, rate limiting, and optimized for Google Cloud Run deployment.

## 🆕 **Enhanced Features**
- **🚀 Redis Caching**: Instant responses for identical images
- **⚡ Rate Limiting**: 30 requests/minute protection with slowapi
- **🖼️ Multi-Format Support**: JPG, JPEG, PNG, GIF images
- **📊 Cache Management**: Statistics and cache clearing endpoints
- **🔒 Enhanced Security**: Improved validation and error handling
- **📈 Performance Monitoring**: Detailed logging and metrics

## 🎯 Overview

This system provides a complete solution for OCR-based text extraction:
- **Backend**: FastAPI-based REST API with Google Cloud Vision API
- **Frontend**: Modern React application with Material UI
- **Deployment**: Docker containers optimized for Google Cloud Run
- **Performance**: High-accuracy text extraction with confidence scores

## 🏗️ Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│                 │         │                  │         │                 │
│  React Frontend │────────▶│  FastAPI Backend │────────▶│ Google Cloud    │
│  (Material UI)  │         │  (Cloud Run)     │         │ Vision API      │
│                 │         │                  │         │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
```

## 📁 Project Structure

```
/
├── backend/                    # FastAPI Backend
│   ├── main.py                # Application entry point
│   ├── config.py              # Configuration settings
│   ├── requirements.txt       # Python dependencies
│   ├── Dockerfile            # Container configuration
│   ├── app/
│   │   ├── routes/
│   │   │   └── ocr_routes.py # API endpoints
│   │   ├── services/
│   │   │   └── ocr_google.py    # Google Cloud Vision
│   │   └── utils/
│   └── README.md
│
├── frontend/                  # React Frontend
│   ├── src/
│   │   ├── components/       # Reusable components
│   │   ├── pages/           # Page components
│   │   ├── services/        # API services
│   │   └── App.jsx          # Root component
│   ├── package.json
│   ├── Dockerfile
│   └── README.md
│
└── README.md                 # This file
```

## 🚀 Quick Start

### Prerequisites

- **Python 3.11+** (for backend)
- **Node.js 18+** (for frontend)
- **Docker** (optional, for containerization)
- **Google Cloud Account** (optional, for Google Cloud Vision)

### 1. Clone and Setup

```bash
# Navigate to your project directory
cd /path/to/project

# Install backend dependencies
cd backend
pip install -r requirements.txt

# Install frontend dependencies
cd ../frontend
npm install
```

### 2. Configure OCR Engine

Edit `backend/config.py`:

```python
# Choose your OCR engine
OCR_ENGINE = "tesseract"  # or "google"
```

### 3. Setup Google Cloud Vision (Optional)

If using Google Cloud Vision:

```bash
# Set credentials path
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### 4. Start Backend

```bash
cd backend
python main.py
```

Backend runs at: `http://localhost:8080`

### 5. Start Frontend

```bash
cd frontend
npm run dev
```

Frontend runs at: `http://localhost:3000`

### 6. Test the System

1. Open `http://localhost:3000` in your browser
2. Upload a JPG/JPEG image
3. Click "Extract Text"
4. View the extracted text with confidence scores

## 🔧 Configuration

### Backend Configuration

Edit `backend/config.py`:

| Setting | Description | Default |
|---------|-------------|---------|
| `OCR_ENGINE` | OCR engine: "google" or "tesseract" | "google" |
| `MAX_FILE_SIZE_MB` | Maximum upload size in MB | 10 |
| `ALLOWED_EXTENSIONS` | Allowed file extensions | {"jpg", "jpeg"} |
| `LOG_LEVEL` | Logging level | "INFO" |

### Frontend Configuration

Edit `frontend/.env`:

```bash
VITE_API_BASE_URL=http://localhost:8080/api
```

## 📡 API Documentation

### POST /api/extract-text

Extract text from an uploaded image.

**Request:**
```bash
curl -X POST "http://localhost:8080/api/extract-text" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@image.jpg"
```

**Response:**
```json
{
  "success": true,
  "ocr_engine": "google",
  "text": "Extracted text content here",
  "confidence": 0.95,
  "processing_time_ms": 1234
}
```

### GET /api/health

Health check endpoint with enhanced information.

**Response:**
```json
{
  "status": "healthy",
  "ocr_engine": "google",
  "cache_enabled": true,
  "supported_formats": ["jpg", "jpeg", "png", "gif"]
}
```

### GET /api/cache/stats

Get cache statistics and performance metrics.

**Response:**
```json
{
  "enabled": true,
  "total_keys": 42,
  "memory_usage": "2.1MB",
  "connected_clients": 3,
  "cache_ttl_seconds": 3600
}
```

### DELETE /api/cache/clear

Clear all cached OCR results (rate limited to 5/minute).

**Response:**
```json
{
  "success": true,
  "message": "Cache cleared successfully"
}
```

## 🐳 Docker Deployment

### Build and Run Backend

```bash
cd backend

# Build image
docker build -t ocr-backend .

# Run with Tesseract
docker run -p 8080:8080 -e OCR_ENGINE=tesseract ocr-backend

# Run with Google Cloud Vision
docker run -p 8080:8080 \
  -e OCR_ENGINE=google \
  -e GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json \
  -v /path/to/service-account-key.json:/app/credentials.json:ro \
  ocr-backend
```

### Build and Run Frontend

```bash
cd frontend

# Build image
docker build -t ocr-frontend .

# Run container
docker run -p 80:80 ocr-frontend
```

## ☁️ Google Cloud Run Deployment

### Deploy Backend

```bash
# Set variables
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"

# Build and push
cd backend
docker build -t gcr.io/${PROJECT_ID}/ocr-backend .
docker push gcr.io/${PROJECT_ID}/ocr-backend

# Deploy with Google Cloud Vision
gcloud run deploy ocr-backend \
  --image gcr.io/${PROJECT_ID}/ocr-backend \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --set-env-vars OCR_ENGINE=google \
  --memory 1Gi \
  --timeout 300

# Get backend URL
BACKEND_URL=$(gcloud run services describe ocr-backend \
  --platform managed \
  --region ${REGION} \
  --format 'value(status.url)')

echo "Backend URL: ${BACKEND_URL}"
```

### Deploy Frontend

```bash
cd frontend

# Build with backend URL
docker build -t gcr.io/${PROJECT_ID}/ocr-frontend \
  --build-arg VITE_API_BASE_URL=${BACKEND_URL}/api \
  .

# Push to GCR
docker push gcr.io/${PROJECT_ID}/ocr-frontend

# Deploy to Cloud Run
gcloud run deploy ocr-frontend \
  --image gcr.io/${PROJECT_ID}/ocr-frontend \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --port 80

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe ocr-frontend \
  --platform managed \
  --region ${REGION} \
  --format 'value(status.url)')

echo "Frontend URL: ${FRONTEND_URL}"
```

## 🔄 Switching OCR Engines

### Method 1: Configuration File

Edit `backend/config.py`:
```python
OCR_ENGINE = "tesseract"  # Change to "google" or "tesseract"
```

Restart the backend.

### Method 2: Environment Variable

```bash
# Local
export OCR_ENGINE=tesseract
python backend/main.py

# Docker
docker run -e OCR_ENGINE=tesseract ocr-backend

# Cloud Run
gcloud run services update ocr-backend \
  --set-env-vars OCR_ENGINE=tesseract
```

## 🧪 Testing

### Test Backend API

```bash
# Health check
curl http://localhost:8080/api/health

# Extract text
curl -X POST "http://localhost:8080/api/extract-text" \
  -F "file=@test-image.jpg"
```

### Test Frontend

1. Navigate to `http://localhost:3000`
2. Upload a test image
3. Verify text extraction works
4. Check confidence scores and processing time

## 📊 Performance Comparison

| Feature | Google Cloud Vision | Tesseract |
|---------|-------------------|-----------|
| **Accuracy** | High (95%+) | Medium (70-90%) |
| **Speed** | Fast (1-2s) | Medium (2-5s) |
| **Cost** | Pay per use | Free |
| **Internet** | Required | Not required |
| **Setup** | API key needed | Local install |
| **Best For** | Production, high accuracy | Development, offline use |

## 🛠️ Troubleshooting

### Backend Issues

**Google Cloud Vision not working:**
- Verify `GOOGLE_APPLICATION_CREDENTIALS` is set
- Check service account has Vision API access
- Ensure Cloud Vision API is enabled in GCP

**Tesseract not found:**
```bash
# Ubuntu/Debian
sudo apt-get install tesseract-ocr

# macOS
brew install tesseract

# Verify installation
tesseract --version
```

### Frontend Issues

**Cannot connect to backend:**
- Check backend is running: `curl http://localhost:8080/api/health`
- Verify `VITE_API_BASE_URL` in `.env`
- Check CORS settings in backend

**Build errors:**
```bash
# Clear and reinstall
rm -rf node_modules package-lock.json
npm install
```

### CORS Issues

If you see CORS errors:
1. Backend `config.py` should include your frontend URL in `ALLOWED_ORIGINS`
2. For development: `"http://localhost:3000"`
3. For production: Your deployed frontend URL

## 🔒 Security Best Practices

1. **API Keys**: Never commit Google Cloud credentials
2. **CORS**: Restrict `ALLOWED_ORIGINS` in production
3. **File Validation**: Implemented on both client and server
4. **Rate Limiting**: Consider adding for production
5. **Authentication**: Add auth for production deployments
6. **HTTPS**: Always use HTTPS in production

## 📈 Scaling Considerations

### Backend Scaling

- **Cloud Run**: Auto-scales based on traffic
- **Memory**: Increase for large images (1-2GB recommended)
- **Timeout**: Set to 300s for complex images
- **Concurrency**: Cloud Run handles automatically

### Frontend Scaling

- **CDN**: Use CloudFront, Cloudflare, or Cloud CDN
- **Caching**: Static assets cached for 1 year
- **Compression**: Gzip enabled in nginx
- **Code Splitting**: Vite handles automatically

## 💡 Advanced Features (Optional)

### Image Preprocessing

Add to `backend/app/services/ocr_tesseract.py`:

```python
from PIL import ImageEnhance, ImageFilter

# Enhance image before OCR
image = image.convert('L')  # Grayscale
image = image.filter(ImageFilter.SHARPEN)
enhancer = ImageEnhance.Contrast(image)
image = enhancer.enhance(2)
```

### Caching

Add Redis caching for repeated images:

```python
import hashlib
import redis

# Hash image content
image_hash = hashlib.md5(image_bytes).hexdigest()

# Check cache
cached_result = redis_client.get(image_hash)
if cached_result:
    return json.loads(cached_result)
```

### Rate Limiting

Add to `backend/main.py`:

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@router.post("/extract-text")
@limiter.limit("10/minute")
async def extract_text(request: Request, file: UploadFile = File(...)):
    # ... existing code
```

## 📝 API Response Examples

### Success Response

```json
{
  "success": true,
  "ocr_engine": "google",
  "text": "Hello World\nThis is a test image\nWith multiple lines",
  "confidence": 0.96,
  "processing_time_ms": 1456
}
```

### Error Response

```json
{
  "success": false,
  "error": "Invalid file type. Only JPG/JPEG files are allowed",
  "ocr_engine": "google"
}
```

### Empty Text Response

```json
{
  "success": true,
  "ocr_engine": "tesseract",
  "text": "",
  "confidence": 0.0,
  "processing_time_ms": 892
}
```

## 🎓 Learning Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [Material UI Documentation](https://mui.com/)
- [Google Cloud Vision API](https://cloud.google.com/vision/docs)
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)

## 📄 License

MIT License - feel free to use this project for personal or commercial purposes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## 📧 Support

For issues or questions:
1. Check the troubleshooting section
2. Review backend and frontend README files
3. Check API documentation at `http://localhost:8080/docs`

## 🎉 Acknowledgments

- Google Cloud Vision API for powerful OCR capabilities
- Tesseract OCR for open-source OCR engine
- FastAPI for excellent Python web framework
- React and Material UI for beautiful frontend components

---

**Built with ❤️ for the Flexbone Coding Challenge**
