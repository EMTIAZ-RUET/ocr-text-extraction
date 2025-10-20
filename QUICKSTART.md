# Quick Start Guide

Get the OCR Image Text Extraction System running on Google Cloud Run in 5 minutes!

## 🚀 Fastest Way: Google Cloud Run Deployment

### Prerequisites
- Google Cloud account with billing enabled
- Google Cloud CLI installed
- Docker installed
- Project ID ready

### Steps

```bash
# 1. Navigate to project directory
cd /home/bs00728/Airwork

# 2. Set up Google Cloud Platform
export PROJECT_ID="your-project-id"
./setup-gcp.sh

# 3. Deploy backend to Cloud Run
./deploy-backend.sh

# 4. Deploy frontend to Cloud Run
export BACKEND_URL="https://your-backend-url"
./deploy-frontend.sh

# 5. Access your application
# Your app will be available at the provided frontend URL
```

## 🛠️ Alternative: Local Development with Docker Compose

### Prerequisites
- Docker and Docker Compose installed
- Google Cloud service account key (optional)

### Steps

```bash
# 1. Navigate to project directory
cd /home/bs00728/Airwork

# 2. Start the entire stack
docker-compose up -d

# 3. Wait for services to start (30-60 seconds)
docker-compose logs -f

# 4. Open your browser
# Frontend: http://localhost
# Backend API: http://localhost:8080
# API Docs: http://localhost:8080/docs
```

### Test It

1. Open `http://localhost` in your browser
2. Drag and drop a JPG/JPEG image
3. Click "Extract Text"
4. See the results!

### Stop Services

```bash
docker-compose down
```

---

## 🛠️ Local Development Setup

### Backend Setup (5 minutes)

```bash
# 1. Install Python dependencies
cd backend
pip install -r requirements.txt

# 2. Install Tesseract OCR
# Ubuntu/Debian:
sudo apt-get update && sudo apt-get install -y tesseract-ocr

# macOS:
brew install tesseract

# Windows: Download from https://github.com/UB-Mannheim/tesseract/wiki

# 3. Run the backend
python main.py

# Backend is now running at http://localhost:8080
```

### Frontend Setup (3 minutes)

```bash
# 1. Install Node dependencies
cd frontend
npm install

# 2. Configure backend URL
echo "VITE_API_BASE_URL=http://localhost:8080/api" > .env

# 3. Start development server
npm run dev

# Frontend is now running at http://localhost:3000
```

---

## 🧪 Quick Test

### Test Backend API

```bash
# Health check
curl http://localhost:8080/api/health

# Upload test image
curl -X POST "http://localhost:8080/api/extract-text" \
  -F "file=@your-image.jpg"
```

### Test Frontend

1. Open `http://localhost:3000`
2. Upload a JPG/JPEG image with text
3. Click "Extract Text"
4. View results with confidence score

---

## 🔧 Configuration

### Google Cloud Vision API (Default)

The application is configured to use Google Cloud Vision API by default for high-accuracy OCR processing.

For Cloud Run deployment, authentication is handled automatically.

For local development with Google Cloud Vision:

```bash
# 1. Create service account key using setup-gcp.sh
./setup-gcp.sh

# 2. Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="./credentials.json"

# 3. Restart backend
docker-compose restart backend
```

---

## 📦 What You Get

### Backend Features
- ✅ FastAPI REST API
- ✅ Google Cloud Vision API integration
- ✅ File validation (JPG/JPEG, max 10MB)
- ✅ Confidence scores
- ✅ Processing time metrics
- ✅ Comprehensive error handling
- ✅ API documentation (Swagger UI)
- ✅ Cloud Run optimized

### Frontend Features
- ✅ Modern React UI with Material UI
- ✅ Drag & drop file upload
- ✅ Image preview
- ✅ Real-time results display
- ✅ Copy to clipboard
- ✅ Backend status indicator
- ✅ Responsive design

---

## 🎯 Common Use Cases

### 1. Extract Text from Receipt

```bash
curl -X POST "http://localhost:8080/api/extract-text" \
  -F "file=@receipt.jpg"
```

### 2. Process Document Image

Upload document image through web interface at `http://localhost:3000`

### 3. Batch Processing

```bash
for file in images/*.jpg; do
  curl -X POST "http://localhost:8080/api/extract-text" \
    -F "file=@$file" >> results.json
done
```

---

## 🐛 Troubleshooting

### Backend won't start

```bash
# Check if port 8080 is available
lsof -i :8080

# Check Tesseract installation
tesseract --version

# View logs
docker-compose logs backend
```

### Frontend can't connect to backend

```bash
# Verify backend is running
curl http://localhost:8080/api/health

# Check .env file
cat frontend/.env

# Should show: VITE_API_BASE_URL=http://localhost:8080/api
```

### "Google Cloud Vision API" errors

```bash
# Ensure Vision API is enabled
gcloud services enable vision.googleapis.com

# Check authentication
gcloud auth application-default login
```

### CORS errors in browser

Edit `backend/config.py`:
```python
ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "*"  # For development only
]
```

---

## 📚 Next Steps

1. **Read Full Documentation**: See [README.md](README.md)
2. **Deploy to Cloud**: See [DEPLOYMENT.md](DEPLOYMENT.md)
3. **Run Tests**: See [TESTING.md](TESTING.md)
4. **Customize**: Edit `backend/config.py` and `frontend/src/`

---

## 💡 Tips

- **Production Ready**: Google Cloud Vision provides 95%+ accuracy
- **Cost Optimization**: First 1,000 API calls per month are free
- **Image Quality**: Higher DPI (300+) gives better results
- **File Size**: Compress large images before upload
- **Testing**: Use API docs at `http://localhost:8080/docs`
- **Monitoring**: Use Google Cloud Console for logs and metrics

---

## 🆘 Need Help?

1. Check the [CLOUD_DEPLOYMENT.md](CLOUD_DEPLOYMENT.md) for Google Cloud setup
2. Review [README.md](README.md) for detailed documentation
3. Check logs: `docker-compose logs -f` or Google Cloud Console
4. Test API directly: `http://localhost:8080/docs`

---

## ✅ Success Checklist

- [ ] Backend running at `http://localhost:8080`
- [ ] Frontend running at `http://localhost:3000`
- [ ] Health check returns `{"status":"healthy"}`
- [ ] Can upload JPG/JPEG image
- [ ] Text extraction works
- [ ] Results display correctly

---

**You're all set! Start extracting text from images! 🎉**

For Google Cloud deployment, see [CLOUD_DEPLOYMENT.md](CLOUD_DEPLOYMENT.md)
